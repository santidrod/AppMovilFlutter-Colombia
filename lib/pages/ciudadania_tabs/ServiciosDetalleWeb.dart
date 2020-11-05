import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Elementos.dart';

/// Vista que muestra una vista web para ver los servicios disponibles con ciudadanía digital

class ServicioDetalle extends StatefulWidget {
  /// Indicador para bloquear la vista
  final bool bloquear;

  /// Url inicial que viene de la vista home
  final String url;

  /// Texto iniciar que viene de la vista home
  final String titulo;

  const ServicioDetalle({Key key, this.bloquear, this.titulo, this.url})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ServicioDetalleState();
  }
}

class _ServicioDetalleState extends State<ServicioDetalle> {
  /// Indicador de petición activa
  bool cargando = false;

  /// Controlador de la vista web
  InAppWebViewController _webViewController;

  // url inicial
  String url = "";

  _ServicioDetalleState();

  @override
  void initState() {
    super.initState();

    /// verificar que se cuente con un token
    /*
    Uri uri = Uri.dataFromString(widget.url);
    String token = uri.queryParameters["token"];
    url = token == null ? Constantes.urlGobBoWeb : widget.url;

    */ // deshabilitado, hasta que el portal v2 tenga una vista de directorio de servicios digitales

    url = widget.url;
  }

  void estadoCarga({bool estado}) {
    setState(() {
      cargando = estado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          Utilidades.imprimir("atras normal");
          await _webViewController.goBack();
          return false;
        } else {
          Utilidades.imprimir("No se puede ir atras");
          return true;
        }
      },
      child: Scaffold(
          appBar: new AppBar(
              title: Text(widget.titulo,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: ColorApp.btnBackground,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal)),
              centerTitle: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.clear,
                    color: ColorApp.greyDarkText,
                  ),
                ),
              ]),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              InAppWebView(
                initialUrl: url,
                initialHeaders: {},
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      debuggingEnabled: true,
                      useOnDownloadStart: true,
                      javaScriptEnabled: true),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onLoadHttpError: (InAppWebViewController controller, String url,
                    int statusCode, String description) {
                  Utilidades.imprimir("Error en URL 🌍: $url : $statusCode");
                },
                onLoadStart: (InAppWebViewController controller, String url) {
                  estadoCarga(estado: true);
                  Utilidades.imprimir("Cargando URL 🌍 : $url");
                },
                onLoadStop: (InAppWebViewController controller, String url) {
                  estadoCarga(estado: false);
                },
                onDownloadStart: (controller, url) async {
                  Utilidades.imprimir("Iniciando descarga 🌍 $url");

                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    Utilidades.imprimir('No se puede abrir la URL: $url');
                    Alertas.showToast(mensaje: 'No se puede abrir la URL');
                  }
                },
                onCreateWindow: (InAppWebViewController controller,
                    CreateWindowRequest createWindowRequest) async {
                  Utilidades.imprimir(
                      'Intentando abrir 🚪: ${Uri.encodeFull(createWindowRequest.url)}');
                  await Utilidades.abrirURL(
                      Uri.encodeFull(createWindowRequest.url));
                  return false;
                },
              ),
              cargando
                  ? Center(
                      child: Elementos.indicadorProgresoCircularNativo(),
                    )
                  : Stack(),
            ],
          )),
    );
  }
}
