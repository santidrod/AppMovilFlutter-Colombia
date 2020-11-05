import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// vista que muestra los terminos y condiciones
class TerminosCondiciones extends StatefulWidget {
  const TerminosCondiciones({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TerminosCondicionesState();
  }
}

class _TerminosCondicionesState extends State<TerminosCondiciones> {
  _TerminosCondicionesState();

  /// Lista de sesiones
  List<dynamic> sesiones = [];

  /// Indicador de estado de carga
  bool cargando = false;

  /// Contenido html
  String contenido = "";

  /// Indicador de petición activa
  bool _peticionActiva = false;

  /// controlador de la vista web
  WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  /// Método que cambia el indicador del estado de una petición activa
  void estadoCarga({bool valor}) {
    setState(() {
      _peticionActiva = valor;
    });
  }

  /// Método que obtiene los terminos y condiciones  y los muestra en una vista web
  void configurar() async {
    estadoCarga(valor: true);
    await Services.peticion(tipoPeticion: TipoPeticion.GET, urlPeticion: Constantes.urlBasePreTerminosCondiciones).then((response) async {
      contenido = response["terminos"];
      await _webViewController.loadUrl(Utilidades.loadHtmlFromString(contenido));
      setState(() {});
    }).catchError((onError) {
      Alertas.showToast(mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true);
    }).whenComplete(() {
      Utilidades.imprimir("Se muestra términos y condiciones");
      estadoCarga(valor: false);
    });

    Utilidades.imprimir("version $contenido");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Términos y Condiciones",
            style: TextStyle(fontSize: 16.0, color: ColorApp.btnBackground, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal)),
        elevation: 0,
        backgroundColor: Colors.white,
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
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: WebView(
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                    configurar();
                  },
                  onPageFinished: (String url) {
                    Utilidades.imprimir("Pagina cargada ✅");
                  },
                  // initialUrl: _loadHtmlFromString('html'),
                ),
              ),
            ],
          ),
          if (_peticionActiva) Center(child: Elementos.indicadorProgresoCircularNativo()),
        ],
      ),
    );
  }
}
