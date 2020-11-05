import 'dart:io';
import 'dart:ui' as ui;

import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/ConfiguracionNotificaciones.dart';
import 'package:ciudadaniadigital/utilidades/HelperModal.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Tipos de alertas
enum ActionStyle { normal, destructive, important, important_destructive }

/// Clase que define diferentes diálogos en la aplicación
class Dialogo {
  /// Color por defecto
  static Color _normal = ColorApp.btnBackground;

  /// Color de alerta
  static Color _destructive = Colors.red;

  /// Dialogo Personalizado
  static Future mostrarDialogoConfirmacion(BuildContext context, String title,
      Function() onPressed, String message) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return HelperModal.modalConfirmation(
              context: context,
              title: title,
              message: message,
              onPressed: onPressed);
        });
  }

  /// Dialogo Personalizado
  static Future mostrarDialogoPersonalizado(BuildContext context,
      EntidadRow entidad, Function() onPressed, TramiteRow tramite) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return HelperModal.modalElement(
              entidad: entidad,
              context: context,
              onPressed: onPressed,
              tramite: tramite);
        });
  }

  /// Dialogo nativo
  static Future mostrarDialogoNativo(BuildContext context, String title,
      Widget message, String firstButtonText, Function firstCallBack,
      {ActionStyle firstActionStyle = ActionStyle.normal,
      String secondButtonText,
      Function secondCallback,
      ActionStyle secondActionStyle = ActionStyle.normal}) {
    Utilidades.imprimir("🚨 alerta ${Platform.operatingSystem}: $message");
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return _iosDialog(
              context, title, message, firstButtonText, firstCallBack,
              firstActionStyle: firstActionStyle,
              secondButtonText: secondButtonText,
              secondCallback: secondCallback,
              secondActionStyle: secondActionStyle);
        } else {
          return _androidDialog(
              context, title, message, firstButtonText, firstCallBack,
              firstActionStyle: firstActionStyle,
              secondButtonText: secondButtonText,
              secondCallback: secondCallback,
              secondActionStyle: secondActionStyle);
        }
      },
    );
  }

  /// Dialogo en Android
  static Widget _androidDialog(BuildContext context, String title,
      Widget message, String firstButtonText, Function firstCallBack,
      {ActionStyle firstActionStyle = ActionStyle.normal,
      String secondButtonText,
      Function secondCallback,
      ActionStyle secondActionStyle = ActionStyle.normal}) {
    List<FlatButton> actions = [];
    actions.add(FlatButton(
      child: Text(
        firstButtonText,
        style: TextStyle(
            color: (firstActionStyle == ActionStyle.important_destructive ||
                    firstActionStyle == ActionStyle.destructive)
                ? _destructive
                : _normal,
            fontWeight:
                (firstActionStyle == ActionStyle.important_destructive ||
                        firstActionStyle == ActionStyle.important)
                    ? FontWeight.bold
                    : FontWeight.normal),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        firstCallBack();
      },
    ));

    if (secondButtonText != null) {
      actions.add(FlatButton(
        child: Text(secondButtonText,
            style: TextStyle(
                color:
                    (secondActionStyle == ActionStyle.important_destructive ||
                            firstActionStyle == ActionStyle.destructive)
                        ? _destructive
                        : _normal)),
        onPressed: () {
          Navigator.of(context).pop();
          secondCallback();
        },
      ));
    }

    return AlertDialog(
      title: Text(title),
      content: message,
      actions: actions,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
    );
  }

  /// dialogo en iOS
  static Widget _iosDialog(BuildContext context, String title, Widget message,
      String firstButtonText, Function firstCallback,
      {ActionStyle firstActionStyle = ActionStyle.normal,
      String secondButtonText,
      Function secondCallback,
      ActionStyle secondActionStyle = ActionStyle.normal}) {
    List<CupertinoDialogAction> actions = [];
    actions.add(
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.of(context).pop();
          firstCallback();
        },
        child: Text(
          firstButtonText,
          style: TextStyle(
              color: (firstActionStyle == ActionStyle.important_destructive ||
                      firstActionStyle == ActionStyle.destructive)
                  ? _destructive
                  : _normal,
              fontWeight:
                  (firstActionStyle == ActionStyle.important_destructive ||
                          firstActionStyle == ActionStyle.important)
                      ? FontWeight.bold
                      : FontWeight.normal),
        ),
      ),
    );

    if (secondButtonText != null) {
      actions.add(
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
            secondCallback();
          },
          child: Text(
            secondButtonText,
            style: TextStyle(
                color:
                    (secondActionStyle == ActionStyle.important_destructive ||
                            secondActionStyle == ActionStyle.destructive)
                        ? _destructive
                        : _normal,
                fontWeight:
                    (secondActionStyle == ActionStyle.important_destructive ||
                            secondActionStyle == ActionStyle.important)
                        ? FontWeight.bold
                        : FontWeight.normal),
          ),
        ),
      );
    }

    return CupertinoAlertDialog(
      title: Text(title),
      content: message,
      actions: actions,
    );
  }

  /// Vista de acción modal
  static void actionSheet(String texto, List<OpcionActionSheet> acciones, context) {
    if (Platform.isIOS) {
      List<Widget> listaAcciones = [];
      for (var accion in acciones) {
        listaAcciones.add(new CupertinoActionSheetAction(
          child: Text(accion.titulo),
          onPressed: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(seconds: 1));
            accion.accion.call();
          },
        ));
      }

      final act = CupertinoActionSheet(
        title: Text(texto),
        actions: listaAcciones,
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancelar"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );

      showCupertinoModalPopup(
          context: context, builder: (BuildContext context) => act);
    }

    if (Platform.isAndroid) {
      List<Widget> listaAcciones = [];
      for (var accion in acciones) {
        listaAcciones.add(new ListTile(
          title: Text(accion.titulo),
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(seconds: 1));
            accion.accion.call();
          },
          leading: accion.icon,
        ));
      }

      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return Container(
              child: new Wrap(children: listaAcciones),
            );
          });
    }
  }

  /// Dialogo para ejecutar o cancelar una acción

  static void dialogoCancelar(BuildContext context, String texto) {
    Dialogo.mostrarDialogoNativo(context, "Alerta", Text(texto), "Aceptar",
        () async {
      Navigator.pop(context);
    },
        secondButtonText: "Cancelar",
        secondCallback: () {},
        secondActionStyle: ActionStyle.important);
  }

  /// Dialogo a pantalla completa
  static Future showFullScreen(context, Widget widget) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => widget,
      ),
    );
  }

  /// Dialogo a pantalla completa nativa
  static Future showNativeModalBottomSheet(context, Widget widget) async {
    double screenHeight =
        ui.window.physicalSize.height / ui.window.devicePixelRatio;
    return Dispositivo.esTablet()
        ? await showGeneralDialog(
            barrierLabel: "",
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 300),
            context: context,
            pageBuilder: (context, anim1, anim2) {
              return Align(
                alignment: Alignment.center,
                child: Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 20),
                  height: screenHeight * 0.9,
                  width: 600,
                  child: SizedBox.expand(child: widget),
                  margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return SlideTransition(
                position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
                    .animate(anim1),
                child: child,
              );
            },
          )
        : Platform.isIOS
            ? await showCupertinoModalBottomSheet(
                expand: true,
                enableDrag: false,
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context, scrollController) => widget,
                isDismissible: false,
              )
            : await showMaterialModalBottomSheet(
                context: context,
                enableDrag: false,
                isDismissible: false,
                builder: (context, scrollController) => widget);
  }
}

/// clase que define opciones en la vista de acción modal
class OpcionActionSheet {
  final String titulo;
  final VoidCallback accion;
  final Icon icon;

  OpcionActionSheet(this.titulo, this.accion, this.icon);
}
