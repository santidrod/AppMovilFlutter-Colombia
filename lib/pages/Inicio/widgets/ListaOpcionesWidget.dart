import 'package:ciudadaniadigital/pages/BuscadorTramites/buscador_tramites.dart';
import 'package:ciudadaniadigital/pages/PreBuzon/pre_buzon_main.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/ServiciosDetalleWeb.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:flutter/material.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';

/// Widget que contiene la lista de servicios de la aplicación

class ListaOpciones {
  /// Contexto de la aplicación
  final BuildContext context;

  /// Servicios disponibles
  static List<dynamic> serviciosDisponibles = [];

  ListaOpciones(this.context);

  /// Widget que contiene la lista de servicios disponibles
  static List<Widget> opciones(context, {bool habilitar}) {
    List<Widget> lista = [];

    serviciosDisponibles = [
      {
        "title": "Identidad digital",
        "subtitle":
            "Una sola cuenta para acceder a todos los servicios digitales del Estado",
        "icon": "icon_user.png",
      },
      {
        "title": "gob.bo",
        "subtitle":
            "Portal de trámites, toda la información que necesitas e Instituciones Públicas",
        "icon": "icon_file.png",
        "accion": () async {
          await Dialogo.showNativeModalBottomSheet(context, BuscadorTramites());
        }
      },
      {
        "title": "Servicios digitales",
        "subtitle":
            "Trámites o servicios públicos que podrás gestionar en línea y de manera sencilla",
        "icon": "icon_file.png",
        "accion": () async {
          await Dialogo.showNativeModalBottomSheet(
              context,
              ServicioDetalle(
                titulo: "Servicios Digitales",
                url: Constantes.urlDirectorioServicios,
              ));
        }
      },
      {
        "title": "Notificaciones electrónicas",
        "subtitle": "Manténte informado, recibe notificaciones en línea",
        "icon": "icon_notification.png",
        "subtitle2": "Acceder sin Ciudadanía Digital",
        "accion": () async {
          await Dialogo.showNativeModalBottomSheet(context, PreBuzonMain());
        }
      }
    ];

    serviciosDisponibles.forEach((element) => lista
        .add(row(registro: element, context: context, habilitar: habilitar)));
    return lista;
  }

  /// Widget que contiene un item de la lista de servicios
  static Widget row({dynamic registro, BuildContext context, bool habilitar}) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side:
                BorderSide(width: 1, color: ColorApp.btnBackgroundLightBorder)),
        color: Colors.white,
        child: ListTileMoreCustomizable(
          contentPadding:
              EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 10),
          dense: true,
          onTap: habilitar
              ? (details) {
                  if (registro["accion"] != null) {
                    registro["accion"].call();
                  }
                }
              : null,
          horizontalTitleGap: 0.0,
          minVerticalPadding: 0.0,
          minLeadingWidth: 40.0,
          title: Text(
            "${registro["title"]}".toString(),
            maxLines: 2,
            style: TextStyle(
                fontSize: 12.0,
                color: ColorApp.blackText,
                fontWeight: FontWeight.w500),
          ),
          leading: Image.asset(
            'assets/images/${registro["icon"]}',
            width: 23,
            color: ColorApp.btnBackground,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: ColorApp.bg,
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "${registro["subtitle"]}".toString(),
                style: TextStyle(color: ColorApp.greyText),
              ),
              registro["subtitle2"] == null
                  ? Text("")
                  : Text(
                      "${registro["subtitle2"]}".toString(),
                      style: TextStyle(
                          fontSize: 12,
                          color: ColorApp.buttons,
                          fontWeight: FontWeight.w500),
                    ),
            ],
          ),
        ));
  }
}
