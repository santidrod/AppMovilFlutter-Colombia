import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:flutter/material.dart';

/// Clase que contiene de los campos de la aplicación

class Estilos {
  /// Estilo con un borde inferior
  static InputDecoration entrada({String hintText}) {
    return new InputDecoration(
        hintText: hintText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: ColorApp.btnBackground),
          //  when the TextFormField in unfocused
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: ColorApp.btnBackground),
          //  when the TextFormField in focused
        ),
        border: UnderlineInputBorder());
  }

  /// Estilo con borde en el campo
  static InputDecoration entrada2({String hintText}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorApp.greyBackground, width: 1.0),
      ),
      hintText: hintText,
      counter: SizedBox.shrink(),
      hintStyle: TextStyle(fontSize: 14.0, color: ColorApp.greyBackground),
    );
  }

  /// Estilo para entrada de contraseña con opción de mostrar el texto
  static InputDecoration entradaSegura2({String hintText, bool estado, VoidCallback accion}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorApp.greyLightText, width: 1.5),
      ),
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12),
      counter: SizedBox.shrink(),
      suffixIcon: IconButton(
        icon: Icon(
            // Based on passwordVisible state choose the icon
            estado ? Icons.visibility : Icons.visibility_off,
            color: ColorApp.greyBackground),
        onPressed: () {
          accion.call();
        },
      ),
    );
  }
}
