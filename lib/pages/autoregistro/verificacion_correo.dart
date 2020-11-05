import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ciudadaniadigital/pages/autoregistro/registro_correo.dart';
import 'package:ciudadaniadigital/styles/styles.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:countdown/countdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Socket para obtener el código de verificación de correo
IO.Socket _socket;

/// Controlador del código de confirmación
final TextEditingController codigoCorreoController = TextEditingController();

/// Vista de verificación de correo
class VerificacionCorreo extends StatefulWidget {
  /// Acción de la vista principal
  final VoidCallback accion;

  const VerificacionCorreo({Key key, this.accion}) : super(key: key);

  @override
  _VerificacionCorreoState createState() => _VerificacionCorreoState();

  /// Método que verifica el correo con el código que llego mediante socket
  static Future verificarCorreo() async {
    try {
      if (codigoCorreoController.text.length == 0) {
        return throw ('Código de verificación invalido');
      }

      String correo = await Utilidades.readSecureStorage(key: "correo");

      String uiid = await Dispositivo.getId();

      Map<String, String> bodyParams = {
        'correo': correo,
        'codigo': codigoCorreoController.text,
        "code": uiid,
        "tipo": Platform.operatingSystem.toLowerCase()
      };

      var value = await Services.peticion(
          tipoPeticion: TipoPeticion.POST,
          urlPeticion: "${Constantes.urlBasePreRegistroForm}verificar/correo",
          headers: {
            HttpHeaders.userAgentHeader: (await Utilidades.cabeceraUserAgent()).toString(),
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
            "tipo": Platform.operatingSystem.toLowerCase()
          },
          bodyparams: bodyParams);

      Utilidades.imprimir("Respuesta : $value");

      await Utilidades.saveSecureStorage(key: "codigo", value: codigoCorreoController.text);
      codigoCorreoController.text = "";
      _VerificacionCorreoState.desconectar();
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
      return throw (error);
    }
  }
}

class _VerificacionCorreoState extends State<VerificacionCorreo> {
  /// Indicador de contador para solicitar otro correo
  var contador = 0;

  /// Correo ingresado
  var correo = "";

  @override
  void initState() {
    super.initState();
    codigoCorreoController.text = "";
    mostrarCorreo();
    countdown();
    certificadoSocket();
  }

  /// Método que muestra el correo
  void mostrarCorreo() async {
    correo = await Utilidades.readSecureStorage(key: "correo");
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Contador para solicitar otro código de confirmación
  void countdown() async {
    if (mounted) {
      try {
        var cd = new CountDown(new Duration(seconds: 60));
        await for (var v in cd.stream) {
          setState(() => contador = v.inSeconds);
        }
      } catch (error) {
        Utilidades.imprimir("error con contador: $error");
      }
    } else {
      Utilidades.imprimir("El Widget no esta montado, contador detenido");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 40, right: 40),
        constraints: BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/images/icon_mail.png",
              height: 120,
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: ColorApp.listFillCell,
              ),
              child: ListTile(
                title: InkWell(
                    onTap: abrirCorreo,
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Revisa la bandeja de entrada de tu correo electrónico ',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: ColorApp.greyText)),
                          TextSpan(text: "$correo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          TextSpan(
                              text: " y haz click en el enlace.",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: ColorApp.greyText)),
                        ],
                      ),
                    )),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Visibility(
              visible: false,
              child: Column(
                children: [
                  Container(
                      height: 60,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ingresar código",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 60,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: codigoCorreoController,
                      onFieldSubmitted: (value) {
                        widget.accion.call();
                      },
                      decoration: Estilos.entrada2(hintText: ""),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: contador == 0
                  ? CupertinoButton(
                      onPressed: () async {
                        String correo = await Utilidades.readSecureStorage(key: "correo");

                        await RegistroCorreo.registarCorreo(correo, context)
                            .then((value) => countdown())
                            .catchError((onError) => {Alertas.showToast(mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true)})
                            .whenComplete(() => {});
                      },
                      child: Center(
                        child: Text(
                          "Solicitar otro correo de confirmación",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: ColorApp.btnBackground, fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  : Text(
                      "Solicitar código nuevamente en $contador seg.",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColorApp.btnBackground),
                    ),
            ),
          ],
        ));
  }

  /// Método que muestra una lista de clientes de correo
  void abrirCorreo() async {
    var result = await OpenMailApp.openMailApp();
    if (!result.didOpen && result.canOpen) {
      showDialog(
          context: context,
          builder: (_) => MailAppPickerDialog(
                mailApps: result.options,
              ));
    } else if (!result.didOpen && !result.canOpen) {
      Alertas.showToast(mensaje: 'No se encontraron clientes de correo', danger: true);
    }
  }

  /// Método que obtiene el certificado SSL
  void certificadoSocket() {
    Services.peticion(tipoPeticion: TipoPeticion.GET, urlPeticion: Constantes.socketCertURi).then((response) {
      Uint8List byteData = response;
      conexionSocket(byteData);
    }).catchError((onError) {
      Utilidades.imprimir('error obteniendo certificado ${onError.toString()}');
      rootBundle.load('assets/raw/identrust_root_ca_x3.pem').then((byteData) => conexionSocket(byteData.buffer.asUint8List()));
    });
  }

  /// Método que conecta el socket y espera el código de confirmación
  Future<void> conexionSocket(Uint8List dataCert) async {
    Utilidades.imprimir('INICIANDO CONEXION SOCKET......');
    SecurityContext clientContext = SecurityContext.defaultContext;
    // clientContext.setTrustedCertificatesBytes(dataCert);

    try {
      if (_socket != null) {
        _socket.dispose();
      }
      _socket = IO.io(Constantes.urlSocket, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'webSocketFactory': clientContext,
        'path': Constantes.urlPathSocket,
        'port': 443,
        'secure': true,
        'forceNew': false,
        'autoConnect': false
      });
    } catch (e) {
      Utilidades.imprimir('excepcion en conexion, reintentamos 1 vez...');
      clientContext.setTrustedCertificatesBytes(dataCert);
      _socket = IO.io(Constantes.urlSocket, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'webSocketFactory': clientContext,
        'path': Constantes.urlPathSocket,
        'port': 443,
        'secure': true,
        'forceNew': false,
        'autoConnect': false
      });
    }
    String idDispositivo = await Dispositivo.getId();
    Map<String, String> deviceData = await Utilidades.readAllSecureStorage();
    Utilidades.imprimir('DATOS SEGUROS ENCONTRADOS: ${deviceData.toString()}');

    _socket.on('connect_error', (data) {
      Utilidades.imprimir('ERROR CONECTANDO: ${data.toString()}');
    });

    // en conexión exitosa se envían datos de autoregistro
    _socket.on('connect', (data) {
      Utilidades.imprimir('conectado exitosamente, registrando conexión');
      _socket.emit(
          'sign-in',
          jsonEncode(<String, String>{
            "id": idDispositivo,
            "numero_celular": deviceData['celular'],
            "codigo_sms": deviceData['codigo_sms'],
            "correo": deviceData['correo']
          }));
    });

    // evento de confirmación exitosa de correo
    _socket.on('check-correo', (data) async {
      Utilidades.imprimir('CONFIRMACION CORREO: ${data.toString()}');

      Map<String, dynamic> dataObject = jsonDecode(data);
      if (dataObject['finalizado'] ?? false) {
        String codigoCorreo = dataObject['codigo'].toString();
        Utilidades.imprimir("Código para probar $codigoCorreo");
        codigoCorreoController.text = codigoCorreo;
        setState(() {});
        widget.accion.call();
        desconectar();
      } else {
        Utilidades.imprimir("Error en la confirmación de correo ❌");
      }
    });

    _socket.on('client-error', (data) {
      Utilidades.imprimir('ERROR DE CLIENTE: ${data.toString()}');
    });

    _socket.on('disconnect', (data) {
      Utilidades.imprimir('SOCKET DESCONECTADO 🚫');
    });

    _socket.connect();
  }

  /// Método que desconecta el socket

  static void desconectar() {
    if (_socket != null && _socket.connected) {
      _socket.disconnect();
      _socket.close();
      _socket.dispose();
    }
  }
}
