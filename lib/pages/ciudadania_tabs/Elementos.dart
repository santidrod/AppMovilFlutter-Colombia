import 'dart:io';

import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/ConfiguracionesWidget.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

/// Clase que guarda diferentes tipos de cabeceras

class Elementos {
  /// Función que retorta una interfaz con el logo de la aplicación y un icono para mostrar otro boton para abrir las opciones de la aplicación
  static PreferredSize cabeceraOpciones(context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(150),
      child: Container(
        child: FlexibleSpaceBar(
          title: Container(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  child: Image.asset(
                    "assets/images/logo_ciudadania2.png",
                    width: 170,
                  ),
                ),
                Container(
                  child: InkWell(
                    child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Icon(
                          Icons.menu,
                          color: ColorApp.btnBackground,
                        )),
                    onTap: () async {
                      await Dialogo.showNativeModalBottomSheet(context, ConfiguracionesWidget());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Función que agrega un banner a la aplicación para entornos de test y pre producción
  static Widget bannerEntorno({Widget child}) {
    return Constantes.ambiente == Ambiente.PROD
        ? child
        : Banner(child: child, location: BannerLocation.topStart, message: describeEnum(Constantes.ambiente));
  }

  /// Función que retorta una interfaz con el logo de la aplicación y el del ministerio de la presidencia en un sliverAppbar
  static SliverAppBar cabeceraLogos2() {
    return SliverAppBar(
      pinned: false,
      snap: true,
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 20.0),
        title: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  "assets/images/logo_ciudadania2.png",
                  width: 75,
                ),
              ),
              Container(
                child: Image.asset(
                  "assets/images/logo_bo.png",
                  width: 43,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Función que retorta una interfaz con el logo de la aplicación y el del ministerio de la presidencia en un contenedor
  static Widget cabeceraLogos3() {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.only(top: 30, left: 30, right: 30),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset(
            'assets/images/logo_ciudadania2.png',
            // width: 135,
            // height: 223,
          ),
          Image.asset(
            'assets/images/logo_bo.png',
          ),
        ],
      ),
    );
  }

  /// Función que retorta una interfaz con el logo de la aplicación y el del ministerio de la presidencia en un PreferredSize
  static Widget cabeceraLogos(context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Container(
        color: Colors.white,
        child: FlexibleSpaceBar(
          title: Container(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  child: Image.asset(
                    "assets/images/logo_ciudadania2.png",
                    width: 114,
                  ),
                ),
                Container(
                  child: Image.asset(
                    "assets/images/logo_bo.png",
                    width: 63,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Función que retorta una interfaz con el logo de la aplicación y el del ministerio de la presidencia en un Appbar
  static Widget cabeceraLogosModal(context) {
    return AppBar(
        title: Container(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: Image.asset(
                  "assets/images/logo_ciudadania2.png",
                  width: 114,
                ),
              ),
              Container(
                child: Image.asset(
                  "assets/images/logo_bo.png",
                  width: 63,
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Dialogo.dialogoCancelar(context, "¿Está seguro de cerrar el buzón de notificaciones?");
            },
            child: Text(
              "Cancelar",
              style: new TextStyle(fontSize: 12.0, color: ColorApp.greyText),
            ),
          ),
        ]);
  }

  /// Widget que muestra la el nivel de seguridad de la contraseña
  ///
  static Widget seguridad(int passwordScore, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: 270),
          height: 30,
          child: Row(
            children: <Widget>[
              RichText(
                text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                  TextSpan(text: "Seguridad: "),
                  TextSpan(
                      text: Utilidades.seguridadContrasenia[passwordScore]['mensaje'],
                      style: TextStyle(color: Utilidades.seguridadContrasenia[passwordScore]['color']))
                ]),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: 270),
          child: StepProgressIndicator(
            totalSteps: 4,
            padding: 0,
            selectedColor: Utilidades.seguridadContrasenia[passwordScore]['color'],
            currentStep: passwordScore,
          ),
        ),
        Container(
          constraints: BoxConstraints(maxWidth: 270),
          child: FlatButton(
            onPressed: () {
              Dialogo.mostrarDialogoNativo(
                  context,
                  "¿Cómo es una contraseña segura?",
                  Text(
                    "Las contraseñas deben tener 6 caracteres o más. Las buenas contraseñas son difíciles de adivinar y usan palabras, números, símbolos y letras mayúsculas poco comunes.",
                    textAlign: TextAlign.start,
                  ),
                  "Aceptar",
                  () {},
                  firstActionStyle: ActionStyle.important);
            },
            child: Text(
              "¿Cómo es una contraseña segura ?",
              style: TextStyle(color: ColorApp.btnBackground, fontSize: 12),
            ),
          ),
        )
      ],
    );
  }

  static Widget switchNativo({bool value, Function(bool) onChanged, Color activeColor}) {
    return Platform.isIOS
        ? CupertinoSwitch(
            onChanged: (bool value) {
              onChanged(value);
            },
            value: value,
            activeColor: activeColor,
          )
        : Switch(
            value: value,
            onChanged: (bool value) {
              onChanged(value);
            },
            activeColor: activeColor,
          );
  }

  static LinearProgressIndicator indicadorProgresoLineal() {
    return const LinearProgressIndicator(backgroundColor: Color(0xFF449935), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8FD300)));
  }

  static Widget indicadorProgresoCircularNativo() {
    return Platform.isIOS ? CupertinoActivityIndicator(radius: 20) : CircularProgressIndicator();
  }
}
