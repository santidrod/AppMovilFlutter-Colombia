import 'dart:async';
import 'dart:io';

import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/servicios/MessageBus.dart';
import 'package:ciudadaniadigital/utilidades/servicios/ServiceLocator.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:dart_otp/dart_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'Elementos.dart';

/// Vista que mostrará la vista que generara el código TOTP y la lista de sesiones abiertas en otros dispositivos

class AccesoWidget extends StatefulWidget {
  /// Indicador para bloquear la vista
  final bool bloquear;

  /// Texto iniciar que viene de la vista home
  final String texto;

  const AccesoWidget({Key key, this.bloquear, this.texto}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AccesoWidgetState();
  }
}

class _AccesoWidgetState extends State<AccesoWidget>
    with WidgetsBindingObserver {
  /// Texto iniciar que viene de la vista home
  var secret = "";

  /// Secret obtenido al iniciar sesión para generar el código TOTP
  String code;

  /// Invervalo en segundos para avanzar en el contador
  int interval = 1;

  /// Hora del servidor en milisegundos
  int horaServidor = 0;

  /// Temporizador
  Timer _timer;

  /// Indicador del avance del tiempo en segundos
  int intervaloSegundos = 10;

  /// Controlador del Scroll
  var scrollController = ScrollController();

  /// Arreglo para mostrar la lista de sesiones
  List<dynamic> sesiones = [];

  /// Indicador si hay una acción en curso (obteniendo sesiónes, etc)
  bool cargando = false;

  /// Variable para obtener los mensajes del bus
  ButtonMessageBus _messageBus = locator<ButtonMessageBus>();

  /// Suscripcion para id's de pestaña seleccionada entrantes
  StreamSubscription<int> messageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    iniciarTOTP();
    // suscribe el 'listener' para id de pestaña entrante
    messageSubscription = _messageBus.idStream.listen(_idReceived);
  }

  /// Método que recibe los id recibidos de las pestañas seleccionadas
  void _idReceived(int id) {
    if (id == 3) {
      // pestaña TOTP - sesiones activa
      obtenerSesiones();
    }
  }

  /// Método que obtiene el secret guardado en local, obtiene la hora del servidor y llama a otro método para generar el código TOTP
  void iniciarTOTP() async {
    secret = await Utilidades.readSecureStorage(key: "secret");
    Utilidades.imprimir("Secret guardado 🔐: $secret");
    // secret = base32.encodeString(secret);

    if (await Services.conexionInternet()) {
      Services.peticion(
              tipoPeticion: TipoPeticion.GET,
              urlPeticion: "${Constantes.urlCiudadania}")
          .then((result) {
        horaServidor = int.parse(result["date"].toString());
        Utilidades.imprimir("Hora del servidor: $horaServidor");
        generarTOTP(horaServidor);
      }).catchError((onError) {
        Utilidades.imprimir("Error al obtener hora del servidor ⏳: $onError");
        generarTOTP(DateTime.now().millisecondsSinceEpoch);
      }).whenComplete(() => {
                Utilidades.imprimir("Sincronizada hora del servidor 🕚"),
              });
    } else {
      int horaLocal = DateTime.now().millisecondsSinceEpoch;
      Utilidades.imprimir("Hora local: $horaLocal");

      generarTOTP(horaLocal);
    }
  }

  /// Método que genera el código TOTP y actualiza la vista cambiando de estado
  void generarTOTP(int hora) {
    if (mounted) {
      setState(() {
        DateTime horaAjustada =
            DateTime.fromMillisecondsSinceEpoch(hora * 1000, isUtc: false);

        Utilidades.imprimir(horaAjustada.toIso8601String());

        intervaloSegundos = horaAjustada.second;

        Utilidades.imprimir("_start: $intervaloSegundos");
        if (intervaloSegundos > 30) {
          intervaloSegundos = intervaloSegundos - 30;
          Utilidades.imprimir("intervalo - 30: $intervaloSegundos");
        }
      });
      actualizarTOTP(hora: hora);
      contador();
    } else {
      Utilidades.imprimir("No se actualizara el contador, widget no montado ⏳");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    messageSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        Utilidades.imprimir("state ⏳: resumed");
        if (this.mounted) {
          iniciarTOTP();
        } else {
          Utilidades.imprimir("Widget no montado ⏳");
        }
        break;
      case AppLifecycleState.inactive:
        Utilidades.imprimir("state ⏳: inactive");
        break;
      case AppLifecycleState.paused:
        Utilidades.imprimir("Cancelando temporizador ⏲");
        _timer.cancel();
        Utilidades.imprimir("state ⏳: paused");
        break;
      case AppLifecycleState.detached:
        Utilidades.imprimir("state ⏳: detached");
        break;
    }
  }

  /// Método que copia el código generado en el portapapeles
  void copiarPortapapeles() {
    Clipboard.setData(
            new ClipboardData(text: Utilidades.completarZeroIzquierda(code, 6)))
        .then((value) {
      final snackBar = SnackBar(
        content: Text('Código copiado a portapaleles '),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  /// Contador que avanza y actualiza el TOTP cada 30 segundos
  void contador() async {
    try {
      const oneSec = const Duration(seconds: 1);
      if (_timer != null) {
        Utilidades.imprimir("El temporizador estaba instanciado 🚨");
        _timer.cancel();
      }
      _timer = new Timer.periodic(oneSec, (Timer timer) {
        if (this.mounted) {
          horaServidor = horaServidor + 1;
          // Utilidades.imprimir("intervalo en segundos ⏱: $intervaloSegundos");
          if (intervaloSegundos >= 30) {
            actualizarTOTP(hora: horaServidor);
            intervaloSegundos = 1;
          } else {
            intervaloSegundos = intervaloSegundos + 1;
          }
          setState(() {});
        } else {
          Utilidades.imprimir("Widget no montado, desactivando contador ⏳");
          timer.cancel();
        }
      });
    } catch (error) {
      Utilidades.imprimir("Error actualizando contador ⏱: $error");
    }
  }

  /// Método que actualiza el código TOTP de 6 dígitos con la hora actual
  void actualizarTOTP({@required int hora}) {
    Utilidades.imprimir(
        "generando código con secret: $secret, current_milis: $hora e interval: $interval");

    // code = OTP.generateTOTPCode(secret, new DateTime.now().millisecondsSinceEpoch, length: 6);
    code = TOTP(secret: secret, interval: 30, digits: 6)
        .value(date: DateTime.fromMillisecondsSinceEpoch(hora * 1000));
    Utilidades.imprimir("code 🕑: $code");
  }

  /// Método que cambia el estado del inidicador de carga
  void estadoCarga() {
    setState(() {
      cargando = !cargando;
    });
  }

  /// Método que obtiene la lista de sesiones en un arreglo para mostrarlo en la interfaz
  Future obtenerSesiones() async {
    estadoCarga();

    await Sesion.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion: '${Constantes.urlIsuer}api/v1/sessions',
            context: context)
        .then((response) {
      Utilidades.imprimir("Sesiones 📲: $response");
      setState(() {
        sesiones = response["data"];
      });
    }).catchError((onError) {
      Utilidades.imprimir("Error al buscar sesiones: $onError ");
      Alertas.showToast(
          mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true);
    }).whenComplete(
            () => {Utilidades.imprimir("Lista de sesiones"), estadoCarga()});
  }

  /// Widget que contiene el código de verificación
  Widget codigoVerificacion() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
          child: Text(
            "Código de verificación",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        GestureDetector(
          onTap: () {
            copiarPortapapeles();
          },
          child: Container(
            width: 274,
            decoration: BoxDecoration(
              color: ColorApp.listFillCell,
              borderRadius: BorderRadius.all(
                  Radius.circular(11.0) //         <--- border radius here
                  ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  code ?? "Generando código..",
                  style: TextStyle(
                      fontSize: 35,
                      color: ColorApp.blackText,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(maxWidth: 200),
          child: Text(
            "Un nuevo código de verificación aparecerá cada 30 segundos.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Image.asset(
                    "assets/images/icon_copy.png",
                    height: 20,
                  ),
                ),
                Text(
                  "Copiar",
                  style: TextStyle(
                      fontSize: 10.0,
                      color: ColorApp.btnBackground,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            onTap: () {
              copiarPortapapeles();
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 2.0,
          reverse: false,
          percent: intervaloSegundos / 30,
          center: new Text("$intervaloSegundos"),
          progressColor: ColorApp.btnBackground,
        ),
      ],
    );
  }

  Container vistaDispositivos() {
    return Container(
      constraints: BoxConstraints(maxWidth: 600),
      child: Card(
        margin: EdgeInsets.only(bottom: 10, left: 25, right: 25, top: 30),
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          // side: BorderSide(color: ColorApp.colorGrisClaro),
        ),
        child: Column(
          children: <Widget>[
            Container(
                padding:
                    EdgeInsets.only(top: 20, bottom: 11, left: 25, right: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Tus Dispositivos",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )),
            Container(
                padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                child: Text(
                  "Actualmente has iniciado sesión con tu Ciudadanía Digital en estos dispositivos",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                )),
            sesiones.length > 0
                ? Column(
                    children: list(),
                  )
                : Center(
                    child: Card(
                    margin: EdgeInsets.only(
                        bottom: 10, left: 10, right: 10, top: 10),
                    shape: RoundedRectangleBorder(
                        // side: BorderSide(color: ColorApp.colorGrisClaro),
                        borderRadius: BorderRadius.circular(12.0)),
                    color: ColorApp.listFillCell,
                    shadowColor: Colors.transparent,
                    child: Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: Text("No se encontraron dispositivos")),
                  ))
          ],
        ),
      ),
    );
  }

  Widget vistaPortrait() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Flex(direction: Axis.vertical, children: <Widget>[
              codigoVerificacion(),
              vistaDispositivos(),
            ]),
          ],
        ),
      ),
    );
  }

  /// Vista de interfaz en modo horizontal
  Widget vistaLanscape() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Center(
                child: SingleChildScrollView(child: codigoVerificacion()))),
        Expanded(
            child: Center(
                child: SingleChildScrollView(
          child: vistaDispositivos(),
        ))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Platform.isAndroid
            ? RefreshIndicator(
                onRefresh: () async {
                  await obtenerSesiones();
                },
                child: contenido())
            : contenido());
  }

  /// Vista principal para el contenido
  Widget contenido() {
    return CustomScrollView(slivers: <Widget>[
      CupertinoSliverRefreshControl(
        onRefresh: () async {
          await obtenerSesiones();
        },
      ),
      SliverToBoxAdapter(
        child: Elementos.cabeceraLogos3(),
      ),
      SliverToBoxAdapter(
        child: OrientationBuilder(builder: (_, orientation) {
          if (orientation == Orientation.portrait)
            return vistaPortrait(); // if orientation is portrait, show your portrait layout
          else
            return vistaLanscape();
        }),
      )
    ]);
  }

  /// Widget que muestra la lista de sesiones
  List<Widget> list() {
    List<Widget> lista = [];

    sesiones.forEach((element) => lista.add(row(element, context)));
    return lista;
  }

  /// Widget que muestra una fila de la lista de sesiones
  Widget row(dynamic element, context) {
    return Card(
        margin: EdgeInsets.only(bottom: 10, /*left: 25, right: 25, */ top: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: ColorApp.listFillCell,
        shadowColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: ListTile(
              contentPadding:
                  EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
              dense: true,
              onTap: () {},
              leading: iconDevice(element["type_device"]),
              title: Text(
                "${element["navigator_platform"]} - ${element["browser"]}",
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12.0,
                  color: ColorApp.greyText,
                ),
              ),
              subtitle: RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 12, color: ColorApp.greyText),
                    children: <TextSpan>[
                      TextSpan(
                        text: Utilidades.parseHoraFecha(
                          fechaInicial: element["date"],
                          mesNumerico: true
                        ),
                      ),
                    ]),
              ),
            ),
            /*secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Eliminar',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  Utilidades.imprimir("Proximamente"); 
                  Alertas.showToast(mensaje: "En desarrollo 🔨");
                },
              ),
            ],*/
          ),
        ));
  }

  Widget iconDevice(String typeDevice) {
    if (typeDevice == 'tablet') {
      // return Icon(Icons.tablet);
      return Image.asset(
        'assets/images/icon_tablet.png',
        width: 58,
        height: 40,
      );
    }
    if (typeDevice == 'desktop') {
      return Image.asset(
        'assets/images/icon_macbook.png',
        width: 58,
        height: 40,
      );
    }
    if (typeDevice == 'mobile') {
      return Image.asset(
        'assets/images/icon_mobile.png',
        width: 58,
        height: 49,
      );
    }
    return Text('');
    /*return typeDevice == "tablet"
        ? Icon(Icons.tablet)
        : typeDevice == "desktop"
        ? Icon(Icons.desktop_windows)
        : typeDevice == "mobile" ? Icon(Icons.phone_iphone) : Icon(Icons.computer);*/
  }
}
