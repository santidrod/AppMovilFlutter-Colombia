import 'dart:async';

import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vista que muestra información acerca de por que no se puede ejecutar la aplicación
class AlertaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AlertaPage();
  }
}

class _AlertaPage extends State<AlertaPage> {
  /// Tiempo en el que se cerrara la aplicación
  final int tiempoCerrar = 5; // segundos
  /// Mensaje de por qué no se puede ejecutar la aplicación
  String mensaje = "";

  @override
  void initState() {
    super.initState();
    finalizarApp();
  }

  /// Método que cierra la aplicación
  Future<void> finalizarApp() async {
    if (await Dispositivo.esRooteado()) {
      setState(() {
        mensaje = 'No puede utilizar la aplicación, el dispositivo se encuentra rooteado 🚨';
      });
    }
    if (await Dispositivo.almacenamientoExterno()) {
      setState(() {
        mensaje = 'No puede utilizar la aplicación en una memoria externa 🚨';
      });
    }

    /*if (await Dispositivo.sslPiningInsecure()) {
      setState(() {
        mensaje = 'No puede utilizar la aplicación, se detectó un potencial riesgo de seguridad🚨';
      });
    }*/
    Utilidades.imprimir(mensaje);
    Timer(Duration(seconds: tiempoCerrar), () {
      Utilidades.imprimir('CERRANDO APLICACION');
      SystemNavigator.pop(animated: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.listFillCell,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Container(
          child: FlexibleSpaceBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Image.asset(
                    "assets/images/logo_ciudadania2.png",
                    width: 170,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10, bottom: 30, left: 30, right: 30),
        child: Center(
          child: Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorApp.btnBackground, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
