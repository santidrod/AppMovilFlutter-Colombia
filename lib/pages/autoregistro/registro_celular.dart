import 'dart:io' show HttpHeaders, Platform;

import 'package:ciudadaniadigital/styles/styles.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:ciudadaniadigital/utilidades/validaciones.dart';
import 'package:flutter/material.dart';

/// Controlador de Número de celular
final TextEditingController numeroCelularController = TextEditingController();

/// Vista del formulario de auto registro que pide el número de celular
class RegistroCelular extends StatefulWidget {
  /// Acción que se ejecutara en la vista principal
  final VoidCallback accion;

  const RegistroCelular({Key key, this.accion}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegistroCelularState();

  /// Método que registra el número de celular
  static Future registarCelular(String celular) async {
    if (celular == null || celular.length == 0) {
      if (numeroCelularController.text.length < 8 ||
          !Validar.telefono(numeroCelularController.text)) {
        return throw ('Debe ingresar un número de teléfono válido');
      }
    } else {
      numeroCelularController.text = celular;
    }

    String uiid = await Dispositivo.getId();
    try {
      Map<String, String> bodyParams = {
        'celular': numeroCelularController.text.trim(),
        'code': uiid,
        "tipo": Platform.operatingSystem.toLowerCase()
      };

      var value = await Services.peticion(
        tipoPeticion: TipoPeticion.POST,
        urlPeticion: "${Constantes.urlBasePreRegistroForm}validar/celular",
        headers: {
          HttpHeaders.userAgentHeader:
              (await Utilidades.cabeceraUserAgent()).toString(),
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "tipo": Platform.operatingSystem.toLowerCase()
        },
        bodyparams: bodyParams,
      );
      Utilidades.imprimir("Respuesta RegistarCelular: $value");

      await Utilidades.saveSecureStorage(
          key: "celular", value: numeroCelularController.text.trim());
      numeroCelularController.text = "";
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
      return throw (error);
    }
  }
}

class _RegistroCelularState extends State<RegistroCelular> {
  _RegistroCelularState();

  @override
  void initState() {
    super.initState();
    numeroCelularController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    // var screenSize = MediaQuery.of(context).size;
    // var screenHeight = screenSize.height;

    return Container(
      padding: EdgeInsets.only(left: 30, right: 30),
      constraints: BoxConstraints(maxWidth: 500),
      // height: screenHeight * 0.46,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            constraints: BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: ColorApp.listFillCell,
            ),
            child: Container(
              child: ListTile(
                title: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Para poder registrarte debes contar con ',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ColorApp.greyText)),
                      TextSpan(
                          text: "un número de celular",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ColorApp.blackText)),
                      TextSpan(
                          text: " y ",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ColorApp.blackText)),
                      TextSpan(
                          text: " un correo electrónico personal,",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ColorApp.blackText)),
                      TextSpan(
                          text: " ambos válidos.",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ColorApp.blackText)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            alignment: Alignment.centerLeft,
            child: Text(
              "Número de celular",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            margin: EdgeInsets.only(bottom: 20),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            height: 60,
            child: TextFormField(
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                Utilidades.imprimir("value: $value");
                widget.accion.call();
              },
              controller: numeroCelularController,
              textAlign: TextAlign.center,
              decoration: Estilos.entrada2(hintText: "Ej. 77777777"),
              keyboardType: TextInputType.phone,
              maxLength: 8,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            child: Text(
              "Te enviaremos un código de verificación por SMS.",
              style: TextStyle(
                  color: ColorApp.greyText,
                  fontSize: 13,
                  fontWeight: FontWeight.w300),
            ),
          )
        ],
      ),
      alignment: Alignment(0.0, 0.0),
    );
  }
}
