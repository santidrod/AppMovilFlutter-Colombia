import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'colores.dart';

/// Clase que contiene métodos que muestran alertas
class Alertas {
  /// Método que muestra una alerta con un mensaje
  static void showToast({String mensaje, bool danger = false}) {
    Utilidades.imprimir("Mostrando mensaje 🖖: $mensaje");
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: danger ? ColorApp.error : ColorApp.success,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
