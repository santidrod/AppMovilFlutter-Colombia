import 'dart:async';

import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Vista que muestra una vista web para ver los servicios disponibles con ciudadanía digital
class ServiciosVistaWeb extends StatefulWidget {
  /// Indicador para bloquear la vista
  final bool bloquear;

  const ServiciosVistaWeb({Key key, this.bloquear}) : super(key: key);

  @override
  _ServiciosVistaWebState createState() => _ServiciosVistaWebState();
}

class _ServiciosVistaWebState extends State<ServiciosVistaWeb> {
  /// Token para mostrar la vista web
  String token = "";

  /// Controlador de la vista web
  WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  /// Método que inicializa la vista web enviando el access_token

  Future<void> inicializar() async {
    token = await Sesion.verificarObtenerToken(context);

    _webViewController.loadUrl('${Constantes.urlCiudadaniaServiciosDigitales}?t=$token');
    setState(() {});
    Utilidades.imprimir("token: $token");
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
        floatingActionButton: Container(
          width: 150,
          color: Colors.white,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                if (await _webViewController.canGoBack()) {
                  _webViewController.goBack();
                } else {
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("Historial vacio")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                if (await _webViewController.canGoForward()) {
                  _webViewController.goForward();
                } else {
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("Historial vacio")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                // _webViewController.reload();
                _webViewController.loadUrl('${Constantes.urlCiudadaniaServiciosDigitales}?t=$token');
              },
            ),
          ]),
        ),
        body: CustomScrollView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Elementos.cabeceraLogos3(),
            ),
            SliverFillRemaining(
              child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController controller) {
                  _webViewController = controller;
                  inicializar();
                },
                onPageFinished: (String url) {
                  Utilidades.imprimir("Pagina cargada ✅");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
