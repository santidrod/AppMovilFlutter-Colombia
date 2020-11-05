import 'dart:io';

import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Variable que indica si el usuario a decidido continuar con verificación remota o presencial
int selectedRadioTile = 0;

/// Vista que muestra opciones para continuar con verificación remoto o presencial
class MetodoVerificacionOpcionesWidget extends StatefulWidget {
  const MetodoVerificacionOpcionesWidget({Key key}) : super(key: key);

  @override
  _MetodoVerificacionOpcionesWidgetState createState() =>
      _MetodoVerificacionOpcionesWidgetState();

  /// Función que retorna sin usuario ha escogido continuar con verificación remoto o presencial
  static bool verificacionPresencial() {
    return selectedRadioTile == 0;
  }

  static Future<bool> finalizarRegistro() async {
    try {
      if (verificacionPresencial()) {
        // Se notifica al backend que se terminó el auto registro
        String contentId =
            await Utilidades.readSecureStorage(key: 'content_id_1');
        if (contentId != null) {
          Utilidades.imprimir('Finalizando registro..  ✅');
          var response = await Services.peticion(
              tipoPeticion: TipoPeticion.POST,
              urlPeticion: "${Constantes.urlBasePreRegistroForm}concluido",
              headers: {
                'Content-Id': contentId,
                "tipo": Platform.operatingSystem.toLowerCase(),
                HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8'
              });
          Utilidades.imprimir(
              'respuesta finalizacion de registro: ${response.toString()}');

          return verificacionPresencial();
        } else {
          Utilidades.imprimir(
              'No se tiene un Content-Id 🚨 para finalizar el auto registro');
          return throw ('No se tiene un Content-Id 🚨 para finalizar el auto registro');
        }
      }
      return verificacionPresencial();
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
      return throw (error);
    }
  }
}

class _MetodoVerificacionOpcionesWidgetState
    extends State<MetodoVerificacionOpcionesWidget> {
  /// Fecha límite definido en los siguientes tres días
  String fechaLimite;

  /// Formato de fecha
  final DateFormat formatter =
      DateFormat('dd/MM/yyyy'); // DateFormat('dd-MM-yyyy kk:mm');

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedRadioTile = 1;
    });
    obtieneFechaLimite();
  }

  Future<void> obtieneFechaLimite() async {
    fechaLimite = await Utilidades.readSecureStorage(key: 'fecha_vigencia');
    setState(() {});
  }

  /// Método que cambia el estado de la variable que define si el usuario a decidido continuar con verificación presencial o remota
  void setSelectedRadio(int val) {
    Utilidades.imprimir("✅ $val");
    setState(() {
      selectedRadioTile = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: 40,
          ),
          Container(
              constraints: BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.only(right: 30, left: 30),
              alignment: Alignment.bottomCenter,
              child: RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              "Necesitamos verificar tu registro en Ciudadanía Digital hasta el "),
                      TextSpan(
                          text: fechaLimite,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: ", puedes hacerlos de dos maneras:",
                          style: TextStyle(color: Colors.black)),
                    ]),
              )),
          SizedBox(
            height: 60,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: RadioListTile(
              title: RichText(
                text: TextSpan(
                    style: TextStyle(color: ColorApp.greyDarkText),
                    children: <TextSpan>[
                      TextSpan(text: "Verificar tu cuenta "),
                      TextSpan(
                          text: "presencialmente",
                          style: TextStyle(
                              color: ColorApp.blackText,
                              fontWeight: FontWeight.w700)),
                      TextSpan(text: " en una de las "),
                      TextSpan(
                          text: "oficinas de registro.",
                          style: TextStyle(
                              color: ColorApp.blackText,
                              fontWeight: FontWeight.w700)),
                    ]),
              ),
              onChanged: (value) {
                setSelectedRadio(value);
              },
              value: 0,
              groupValue: selectedRadioTile,
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: RadioListTile(
              title: RichText(
                text: TextSpan(
                    style: TextStyle(color: ColorApp.greyDarkText),
                    children: <TextSpan>[
                      TextSpan(text: "Verificar tu cuenta "),
                      TextSpan(
                          text: "remotamente,",
                          style: TextStyle(
                              color: ColorApp.blackText,
                              fontWeight: FontWeight.w700)),
                      TextSpan(text: " a través de una "),
                      TextSpan(
                          text: "videollamada.",
                          style: TextStyle(
                              color: ColorApp.blackText,
                              fontWeight: FontWeight.w700)),
                    ]),
              ),
              onChanged: (value) {
                setSelectedRadio(value);
              },
              value: 1,
              groupValue: selectedRadioTile,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            child: FlatButton(
              onPressed: () {
                Dialogo.mostrarDialogoNativo(
                    context,
                    "La seguridad de tu información es nuestra prioridad",
                    Text(
                        "\nSi no completas tu verificación hasta la fecha establecida borraremos toda la información de tu registro y tendrás que volver a llenar este formulario."),
                    "Aceptar",
                    () {});
              },
              child: Text(
                "¿Qué pasa si no verifico mi cuenta en el plazo establecido?",
                style: TextStyle(color: ColorApp.alert, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
