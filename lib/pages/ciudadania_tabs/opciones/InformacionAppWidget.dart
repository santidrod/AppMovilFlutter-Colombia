import 'dart:io';

import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

/// Vista que muestra información de la aplicación

class InformacionApp extends StatefulWidget {
  const InformacionApp({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InformacionAppState();
  }
}

class _InformacionAppState extends State<InformacionApp> {
  _InformacionAppState();
  /// Versión de la aplicación
  String version = "";

  @override
  void initState() {
    super.initState();
    configurar();
  }

  /// Método que obtiene la versión de la aplicación desde las utilidades
  void configurar() async {
    version = await Utilidades.versionAplicacion();
    setState(() {});
    Utilidades.imprimir("version $version");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/logo_ciudadania2.png",
            width: 170,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Versión $version para ${Platform.isIOS ? "iOS" : "Android "}"),
                Icon(Platform.isIOS ? Icons.phone_iphone : Icons.phone_android),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Image.asset(
            "assets/images/logo_agetic.png",
            width: 70,
          ),
        ],
      )),
    );
  }
}
