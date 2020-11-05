import 'dart:async';
import 'dart:io' show HttpHeaders, Platform;

import 'package:ciudadaniadigital/pages/autoregistro/registro_celular.dart';
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
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

/// Campo para código de 4 digitos
final TextEditingController _pinPutController = TextEditingController();

/// vista para ingresar el código de verificación
class VerificacionCelular extends StatefulWidget {
  /// Acción desde vista principal
  final VoidCallback accion;

  const VerificacionCelular({Key key, this.accion}) : super(key: key);

  @override
  _VerificacionCelularState createState() => _VerificacionCelularState();

  /// Método que verifica el número de celular
  static Future verificarCelular() async {
    try {
      if (_pinPutController.text.length != 4) {
        return throw ('Código de verificación invalido');
      }

      String celular = await Utilidades.readSecureStorage(key: "celular");

      String uiid = await Dispositivo.getId();

      Map<String, String> bodyParams = {'celular': celular, 'codigo_sms': _pinPutController.text, "code": uiid};

      var value = await Services.peticion(
          tipoPeticion: TipoPeticion.POST,
          urlPeticion: "${Constantes.urlBasePreRegistroForm}verificar/celular",
          headers: {
            HttpHeaders.userAgentHeader: (await Utilidades.cabeceraUserAgent()).toString(),
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
            "tipo": Platform.operatingSystem.toLowerCase()
          },
          bodyparams: bodyParams);
      Utilidades.imprimir("Respuesta : $value");

      await Utilidades.saveSecureStorage(key: "codigo_sms", value: _pinPutController.text);
      _pinPutController.text = "";
    } catch (error) {
      Utilidades.imprimir('Error al verificar el celular: $error');
      return throw (error);
    }
  }
}

class _VerificacionCelularState extends State<VerificacionCelular> {
  /// Tamaño de caracteres para el código
  int _otpCodeLength = 4;

  /// Código de uso de una sola vez
  String _otpCode = "";

  /// indicador de contador para reenviar un código
  var contador = 0;

  /// Número de celular
  String celular = "";

  /// Indicador de boton para volver a solicitar mensaje de confirmación
  bool habilitado = true;

  _VerificacionCelularState();

  @override
  void initState() {
    super.initState();
    _pinPutController.text = "";
    mostrarCelular();
    Dispositivo.mostrarSignature();
    countdown();
  }

  /// Mostrar número de celular
  void mostrarCelular() async {
    celular = await Utilidades.readSecureStorage(key: "celular");
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// contador para pedir otro código
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

  Future<void> accionSolicitarSMSConfirmacion() async {
    String celular = await Utilidades.readSecureStorage(key: "celular");
    setState(() {
      habilitado = false;
    });
    await RegistroCelular.registarCelular(celular)
        .then((value) => countdown())
        .catchError((onError) => {Alertas.showToast(mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true)})
        .whenComplete(() => {
              setState(() {
                habilitado = true;
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;
    return Center(
        child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.only(left: 30, right: 30),
            height: screenHeight * 0.47,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: ColorApp.listFillCell,
                  ),
                  child: ListTileMoreCustomizable(
                    leading: Image.asset(
                      'assets/images/icon_sms.png',
                      width: 23,
                    ),
                    horizontalTitleGap: 0.0,
                    minVerticalPadding: 0.0,
                    minLeadingWidth: 40.0,
                    title: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Revisa tus ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: ColorApp.greyText)),
                          TextSpan(text: "mensajes de texto. ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          TextSpan(
                              text: "Te enviamos un código a tu número de celular ",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: ColorApp.greyText)),
                          TextSpan(text: celular, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                    height: 60,
                    constraints: BoxConstraints(maxWidth: 300),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Código de verificación",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    )),
                if (Platform.isIOS)
                  Container(
                    height: 60,
                    constraints: BoxConstraints(maxWidth: 300),
                    child: TextFormField(
                      maxLength: 4,
                      onFieldSubmitted: (value) {
                        Utilidades.imprimir("value: $value");
                        widget.accion.call();
                      },
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      controller: _pinPutController,
                      textAlign: TextAlign.center,
                      decoration: Estilos.entrada2(hintText: "Ej. 1234"),
                    ),
                  ),
                if (Platform.isAndroid)
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: TextFieldPin(
                      filled: true,
                      filledColor: Colors.grey[100],
                      codeLength: _otpCodeLength,
                      filledAfterTextChange: true,
                      borderStyle: OutlineInputBorder(),
                      borderStyeAfterTextChange: OutlineInputBorder(),
                      boxSize: 43,
                      onOtpCallback: (code, isAutofill) => _onOtpCallBack(code, isAutofill),
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  alignment: Alignment.bottomLeft,
                  child: contador == 0
                      ? CupertinoButton(
                          onPressed: habilitado
                              ? () async {
                                  accionSolicitarSMSConfirmacion();
                                }
                              : null,
                          child: Center(
                              child: Text(
                            "Solicitar otro mensaje de confirmación",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: ColorApp.btnBackground, fontWeight: FontWeight.w700),
                          )),
                        )
                      : Text(
                          "Solicitar código nuevamente en $contador seg.",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColorApp.btnBackground),
                        ),
                ),
              ],
            )));
  }

  /// Metodo que se ejecutara cuando llegue un sms con un código de un solo uso
  void _onOtpCallBack(String otpCode, bool isAutofill) {
    setState(() {
      this._otpCode = otpCode;
    });
    _pinPutController.text = this._otpCode;

    Utilidades.imprimir("CODE: ${otpCode.length}");

    if (otpCode.length == 4) {
      Utilidades.imprimir("Completado automaticamente");
      widget.accion.call();
    }
  }
}
