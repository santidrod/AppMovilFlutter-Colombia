import 'dart:io' show HttpHeaders, Platform;

import 'package:ciudadaniadigital/styles/styles.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:ciudadaniadigital/utilidades/validaciones.dart';
import 'package:flutter/material.dart';

/// Controlador del texto donde se ingresa el correo
final TextEditingController correoController = TextEditingController();

/// contexto de la vista
BuildContext contextoCorreo;

class RegistroCorreo extends StatefulWidget {
  /// Método que se ejecutara en la vista principal
  final VoidCallback accion;

  const RegistroCorreo({Key key, this.accion}) : super(key: key);

  /// Método que hace el registro de correo haciendo una validación de no ser un correo institucional
  static Future registarCorreo(String correo, BuildContext context) async {
    try {
      if (correo == null || correo.length == 0) {
        if (!Validar.isEmail(correoController.text)) {
          return throw ("Debe ingresar un correo válido");
        }
      } else {
        correoController.text = correo; // solo funciona cuando el widget es visible
      }
      bool estaSeguro = false;
      bool esCorreoInst = Validar.esInstitucional(correoController.text);
      if (esCorreoInst) {
        await Dialogo.mostrarDialogoNativo(
            context,
            "Alerta",
            Text(
                'Parece que tratas de usar un correo electrónico institucional en lugar de un correo personal.\n\n¿Quieres continuar de todos modos?'),
            "SI",
            () async {
              estaSeguro = true;
            },
            secondButtonText: "NO",
            secondCallback: () {
              estaSeguro = false;
            },
            secondActionStyle: ActionStyle.important);
      }

      if (esCorreoInst && !estaSeguro) {
        return throw ('Introduce un correo no institucional');
      }

      String celular = await Utilidades.readSecureStorage(key: "celular");
      String codigoSMS = await Utilidades.readSecureStorage(key: "codigo_sms");

      String uiid = await Dispositivo.getId();

      Map<String, String> bodyParams = {'correo': correoController.text.trim(), 'celular': celular, 'codigo_sms': codigoSMS, 'code': uiid};
      if (esCorreoInst) {
        bodyParams.addAll({'institucional': 'true'});
      }

      await Services.peticion(
              tipoPeticion: TipoPeticion.POST,
              urlPeticion: "${Constantes.urlBasePreRegistroForm}validar/correo/",
              headers: {
                HttpHeaders.userAgentHeader: (await Utilidades.cabeceraUserAgent()).toString(),
                HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
                "tipo": Platform.operatingSystem.toLowerCase()
              },
              bodyparams: bodyParams)
          .then((value) async {
        Utilidades.imprimir("Respuesta : $value");
        await Utilidades.saveSecureStorage(key: "correo", value: correoController.text.trim());
        correoController.text = "";
      }).catchError((onError) {
        return throw (onError);
      });
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
      return throw (error);
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _RegistroCorreoState();
  }
}

class _RegistroCorreoState extends State<RegistroCorreo> {
  @override
  void initState() {
    super.initState();
    correoController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          padding: EdgeInsets.only(left: 40, right: 40),
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 5,
              ),
              Text(
                'Ingresa tu correo electrónico',
                style: TextStyle(color: ColorApp.greyText, fontWeight: FontWeight.w300, fontSize: 12),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Correo electrónico",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  )),
              SizedBox(
                height: 15,
              ),
              Container(
                child: TextFormField(
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) {
                      Utilidades.imprimir("value: $value");
                      widget.accion.call();
                    },
                    textAlign: TextAlign.center,
                    decoration: Estilos.entrada2(hintText: "Ej. ciudadano@gob.bo"),
                    keyboardType: TextInputType.emailAddress,
                    controller: correoController),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Te enviaremos un enlace de verificación por correo electrónico.",
                style: TextStyle(color: ColorApp.greyText, fontSize: 13, fontWeight: FontWeight.w300),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Recuerda que tienes un límite de 2 intentos para cambiar tu correo electrónico.",
                style: TextStyle(color: ColorApp.greyText, fontSize: 13, fontWeight: FontWeight.w300),
              )
            ],
          )),
    );
  }
}
