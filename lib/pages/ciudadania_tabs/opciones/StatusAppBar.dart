import 'dart:async';
import 'dart:io';

import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';

/// Variable que indica si mostra u ocultar el AppBar
var ocultarAppBar = true;

/// Vista que muestra mensajes en un Appbar en caso de que no haya internet o

class StatusAppbar extends StatefulWidget implements PreferredSizeWidget {
  /// Función que se ejecutara al cambiar el estado del AppBar
  final void Function({bool habilitado, bool actualizar})
      accionCambioStatusAppBar;

  const StatusAppbar({Key key, this.accionCambioStatusAppBar})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatusAppbarState();
  }

  @override
  Size get preferredSize {
    return new Size.fromHeight(ocultarAppBar ? 0 : 40);
  }
}

class StatusAppbarState extends State<StatusAppbar> {
  /// Indicador del estado de la conexión
  StreamSubscription<DataConnectionStatus> listener;

  /// Mensaje que ira en el appbar
  var statusAppBarDescription = "Verificando conexión 🌍";

  /// Función que se ejecutara al presionar el appBar
  void Function() accionTapAppBar;

  /// Variable que indica si el internet se ha recuperado
  bool internetDisponibleRecuperado = true;

  @override
  void initState() {
    super.initState();
    checkInternet();
    verificarVersion();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(ocultarAppBar ? 0 : 40),
        child: GestureDetector(
          onTap: () {
            if (accionTapAppBar != null)
              accionTapAppBar.call();
            else
              Utilidades.imprimir(
                  "No hay una función definida para el AppBar 🔝");
          },
          child: AppBar(
            backgroundColor: ocultarAppBar ? Colors.white : Colors.red,
            title: Container(
              child: Center(
                  child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  statusAppBarDescription,
                  style: TextStyle(fontSize: 16),
                ),
              )),
            ),
            elevation: 0,
            brightness: ocultarAppBar ? Brightness.light : Brightness.dark,
          ),
        ));
  }

  /// Método que verifica la conexión a internet
  Future checkInternet() async {
    Utilidades.imprimir(statusAppBarDescription);
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          statusAppBarDescription = "Cuenta con conexión a internet 🌎";

          setState(() {
            ocultarAppBar = true;
            widget.accionCambioStatusAppBar.call(
                habilitado: ocultarAppBar,
                actualizar: !internetDisponibleRecuperado);
          });
          internetDisponibleRecuperado = true;
          Utilidades.imprimir('Cuenta con conexión a internet 🌎');
          break;
        case DataConnectionStatus.disconnected:
          statusAppBarDescription = "No cuenta con conexión a internet 🌎";

          setState(() {
            ocultarAppBar = false;
            widget.accionCambioStatusAppBar.call(
                habilitado: ocultarAppBar,
                actualizar: !internetDisponibleRecuperado);
          });
          internetDisponibleRecuperado = false;
          Utilidades.imprimir('No cuenta con conexión a internet 🌎');
          break;
      }
    });
    return await DataConnectionChecker().connectionStatus;
  }

  /// Método que verifica la versión de la aplicación
  Future verificarVersion() async {
    try {
      dynamic response = await Services.peticion(
          tipoPeticion: TipoPeticion.GET,
          urlPeticion: Constantes.urlVerificarVersion);

      Utilidades.imprimir("Respuesta 🧩: $response");

      String versionServicio =
          response[Platform.isAndroid ? "android" : "ios"]["version"];
      bool urgente =
          response[Platform.isAndroid ? "android" : "ios"]["urgente"];

      Utilidades.imprimir(
          "version de aplicación en servicio 🌍: $versionServicio : $urgente");
      String versionLocal = await Utilidades.versionAplicacion();
      Utilidades.imprimir("version de aplicación en local 📱: $versionLocal");

      if (Utilidades.versionMenorQue(versionLocal, versionServicio)) {
        statusAppBarDescription = "Hay una nueva versión de la aplicación";
        setState(() {
          ocultarAppBar = false;
          widget.accionCambioStatusAppBar.call(
              habilitado: ocultarAppBar,
              actualizar: !internetDisponibleRecuperado);
        });

        accionTapAppBar = () {
          Utilidades.abrirURL(Constantes.urlStore);
        };

        if (urgente) {
          widget.accionCambioStatusAppBar.call(
              habilitado: ocultarAppBar,
              actualizar: !internetDisponibleRecuperado);
          Dialogo.mostrarDialogoNativo(
              context,
              "Alerta",
              Text(
                  "Hay una nueva versión de la aplicación, debe actualizar antes de continuar"),
              "Actualizar", () {
            Utilidades.imprimir("llamando a la función: $accionTapAppBar");
            Utilidades.abrirURL(Constantes.urlStore);
          }, firstActionStyle: ActionStyle.important);
        }
      } else {
        Utilidades.imprimir("La aplicación esta actualizada 🙌");
      }
    } catch (error) {
      Utilidades.imprimir("Error al verificar la versión: $error");
    }
  }
}
