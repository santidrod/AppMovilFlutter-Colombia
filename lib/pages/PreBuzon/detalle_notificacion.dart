import 'dart:io';
import 'dart:typed_data';

import 'package:ciudadaniadigital/models/NotificacionModel.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Vista que muestra el detalle de una notificación de trámite
class DetalleNotificacion extends StatefulWidget {
  /// Identificador del ciudadano
  final String idCiudadano;

  /// token de acceso
  final String token;

  /// Modelo de notificación
  final NotificacionModel notificacion;

  /// Indicador de buzón de notificaciones
  final bool esPreBuzon;

  DetalleNotificacion(
      {this.idCiudadano, this.token, this.notificacion, this.esPreBuzon});

  @override
  State<StatefulWidget> createState() => _DetalleNotificacion();
}

class _DetalleNotificacion extends State<DetalleNotificacion> {
  /// token de acceso
  String token;

  /// Controlador de la vista web
  WebViewController _webViewController;

  /// Fecha de notificación
  String fechaNotificacion;

  /// Indicador de petición activa
  bool peticionActiva = false;

  /// Variables que definen la ruta base
  String _rutaBase;

  _DetalleNotificacion();

  @override
  void initState() {
    super.initState();
    _rutaBase = widget.esPreBuzon
        ? Constantes.urlBasePreBuzon
        : Constantes.urlNotificacionesBandeja;
    token = widget.token;
    obtieneNotificacion();
  }

  /// Método que cambia el indicador del estado de una petición activa
  void estadoCarga({bool valor}) {
    setState(() {
      peticionActiva = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Container(
            alignment: Alignment.topLeft,
            width: screenSize.width,
            child: fechaNotificacion == null
                ? Text("")
                : Text(
                    'Notificado: $fechaNotificacion',
                    style: TextStyle(
                        fontSize: 12.0,
                        color: ColorApp.btnBackground,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal),
                  ),
          ),
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
          ],
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (fechaNotificacion != null) Text(""),
                Expanded(
                  child: WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onPageStarted: (url) {
                      estadoCarga(valor: true);
                    },
                    navigationDelegate: (request) async {
                      Utilidades.imprimir("navigationDelegate: ${request.url}");
                      if (!request.url.contains('enlaces/page') &&
                          await canLaunch(request.url)) {
                        Utilidades.imprimir(
                            '================= DESCARGA DE ADJUNTO: ${request.url}');
                        if (peticionActiva) {
                          Alertas.showToast(
                              mensaje:
                                  'Por favor espera a que termine la descarga del adjunto',
                              danger: true);
                        } else
                          await descargaAdjuntoPdf(request.url);
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                    onPageFinished: (String url) {
                      estadoCarga(valor: false);
                    },
                    // initialUrl: _loadHtmlFromString('html'),
                  ),
                ),
                if (!peticionActiva)
                  Container(
                    width: screenSize.width,
                    height: 70,
                    child: Align(
                      child: RaisedButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Descarga el documento pdf.',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: ColorApp.bg,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.file_download,
                              color: ColorApp.bg,
                            )
                          ],
                        ),
                        color: ColorApp.budget,
                        onPressed: () {
                          obtieneNotificacion(descargarPDF: true);
                        },
                      ),
                    ),
                  )
                else
                  Container()
              ],
            ),
            if (peticionActiva)
              Center(child: Elementos.indicadorProgresoCircularNativo())
          ],
        ));
  }

  /// Método que hace una petición para hacer el flujo de notificación

  Future<void> cierraFlujo() async {
    if (!widget.notificacion.getFinalizado) {
      try {
        String urlBase = widget.esPreBuzon
            ? Constantes.urlBasePortalNotPreBuzon
            : Constantes.urlNotificacionesConfiguracion;
        if (!widget.esPreBuzon) {
          token = await Sesion.verificarObtenerToken(context);
        }

        await Services.peticion(
            tipoPeticion: TipoPeticion.PUT,
            urlPeticion: '${urlBase}flujo/${widget.notificacion.getId}/cerrar',
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $token',
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            }).then((value) {
          Utilidades.imprimir("Flujo cerrado: $value 🔒");
          widget.notificacion.setFinalizado(value: true);
        }).catchError((onError) {
          Alertas.showToast(
              mensaje:
                  'No se pudo cerrar el flujo debido a un error, intenta más tarde',
              danger: true);
        }).whenComplete(() {});
      } catch (e) {
        Utilidades.imprimir('EXCEPCION CERRANDO DOCUMENTO => ${e.toString()}');
        Alertas.showToast(mensaje: e.toString(), danger: false);
      }
    }
  }

  /// Método que obtiene información de la notificación
  Future<void> obtieneNotificacion({bool descargarPDF = false}) async {
    Utilidades.imprimir("Obteniendo notificación..");
    estadoCarga(valor: true);
    try {
      String urlPeticion =
          '${_rutaBase}reportes_pdf/documento/${widget.notificacion.getId}?format=${descargarPDF ? 'pdf' : 'html'}&id_flujo=${widget.notificacion.getId}&render=partial&max_chars=3000';

      if (!widget.esPreBuzon) {
        token = await Sesion.verificarObtenerToken(context);
      }
      await Services.peticion(
              tipoPeticion: TipoPeticion.GET,
              urlPeticion: urlPeticion,
              headers: getHeaders())
          .then((response) async {
            if (descargarPDF) {
              descargaReportePdf(response);
            } else {
              if (mounted) {
                fechaNotificacion = response["datos"]['timestamp'];
                Utilidades.imprimir("fechaNotificacion 📆: $fechaNotificacion");
                _webViewController.loadUrl(Utilidades.loadHtmlFromString(
                    response["datos"]['htmlContent']));
                setState(() {});
                cierraFlujo();
              } else {
                Utilidades.imprimir(
                    "Widget no montado, no se completara notificación: $response");
              }
            }
          })
          .catchError((onError) => {
                Alertas.showToast(
                    mensaje: Utilidades.obtenerMensajeRespuesta(onError),
                    danger: true)
              })
          .whenComplete(() {
            estadoCarga(valor: false);
          });
    } catch (e) {
      // ocurrio un error e.toString();
    }
  }

  /// Método que configuran las cabeceras
  Map<String, String> getHeaders() {
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token'
    };
    if (widget.esPreBuzon) {
      headers.addAll({'usuario': widget.idCiudadano});
    }
    return headers;
  }

  /// Método que descargue la notificación de un trámite en PDF
  Future<void> descargaReportePdf(Uint8List data, {String nombre = ""}) async {
    final location = await getApplicationDocumentsDirectory();
    String nombrePdf = nombre.isEmpty ? widget.notificacion.getId : nombre;
    String pathPdf = '${location.path}/notificacion_$nombrePdf.pdf';
    Utilidades.imprimir('RUTA RESULTANTE $pathPdf');
    estadoCarga(valor: false);
    File(pathPdf).writeAsBytes(data.toList()).then((file) async {
      Utilidades.imprimir('REPORTE GUARDADO, VISUALIZANDO...');
      final resultOpdnPdf = await OpenFile.open(pathPdf);
      if (resultOpdnPdf.type == ResultType.noAppToOpen) {
        Alertas.showToast(
            mensaje: "No tiene ninguna aplicación para abrir el documento",
            danger: true);
      }
    });
  }

  Future<void> descargaAdjuntoPdf(String url) async {
    estadoCarga(valor: true);
    String nombreArchivo = '';
    url.split('/').forEach((element) {
      if (element.contains('.pdf')) {
        nombreArchivo = element;
        int index = nombreArchivo.indexOf('.pdf');
        nombreArchivo =
            nombreArchivo.replaceRange(index, nombreArchivo.length, '.pdf');
      }
    });
    if (nombreArchivo.isEmpty)
      nombreArchivo = "adjunto_${widget.notificacion.getId}.pdf";
    await Services.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion: Uri.encodeFull(url),
            headers: {HttpHeaders.contentTypeHeader: 'application/pdf'})
        .then((value) => descargaReportePdf(value, nombre: nombreArchivo))
        .catchError((onError) {
      Utilidades.imprimir('error descargando adjunto: ${onError.toString()}');
      estadoCarga(valor: false);
    });
  }
}
