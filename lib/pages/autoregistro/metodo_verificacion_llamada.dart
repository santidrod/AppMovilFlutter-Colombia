import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

/// Vista con ilustraciones para indicar los requisitos de registro remoto

class MetodoVerificacionLlamadaWidget extends StatefulWidget {
  const MetodoVerificacionLlamadaWidget({Key key}) : super(key: key);

  @override
  _MetodoVerificacionLlamadaWidgetState createState() => _MetodoVerificacionLlamadaWidgetState();

  /// Método que continua con la acción siguiente
  static Future verificadoAccion() async {
    try {
      Utilidades.imprimir("Respuesta : Continuar");
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
    }
  }
}

class _MetodoVerificacionLlamadaWidgetState extends State<MetodoVerificacionLlamadaWidget> {
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
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              constraints: BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: ColorApp.listFillCell,
              ),
              child: RichText(
                strutStyle: StrutStyle(fontSize: 13),
                text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                  TextSpan(text: "Requisitos para verificar tu cuenta"),
                  TextSpan(text: " remotamente, ", style: TextStyle(color: ColorApp.blackText, fontWeight: FontWeight.w700)),
                  TextSpan(text: "a través de una "),
                  TextSpan(text: "videollamada: ", style: TextStyle(color: ColorApp.blackText, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.only(left: 48, right: 48),
            child: RichText(
              text: TextSpan(style: TextStyle(color: ColorApp.greyDarkText, fontSize: 13), children: <TextSpan>[
                TextSpan(
                    text: "• Dispositivo con cámara\n",
                    style: TextStyle(color: ColorApp.greyDarkText, fontWeight: FontWeight.w700, fontSize: 13)),
                TextSpan(
                    text: "• Permiso para acceder a la cámara del dispositivo\n",
                    style: TextStyle(color: ColorApp.greyDarkText, fontWeight: FontWeight.w700, fontSize: 13)),
                TextSpan(
                    text: "• Foto “selfie” con carnet\n",
                    style: TextStyle(color: ColorApp.greyDarkText, fontWeight: FontWeight.w700, fontSize: 13)),
                TextSpan(
                    text: "• Foto del carnet anverso\n",
                    style: TextStyle(color: ColorApp.greyDarkText, fontWeight: FontWeight.w700, fontSize: 13)),
                TextSpan(
                    text: "• Foto del carnet reverso\n",
                    style: TextStyle(color: ColorApp.greyDarkText, fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Image.asset(
                  "assets/images/imagen-ciudadania-selfie-carnet 1.png",
                  width: 109,
                  height: 133,
                ),
                Expanded(
                  child: Text(
                    "Ubícate justo al frente de la cámara frontal de tu dispositivo móvil sosteniendo tu cédula de identidad.",
                    style: TextStyle(color: ColorApp.greyText, fontSize: 11),
                  ),
                )
              ],
            ),
          ),
          /*SizedBox(
            height: 40,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: RichText(
                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                    TextSpan(text: "Asegúrate de estar dentro de los recuadros", style: TextStyle(color: ColorApp.greyText, fontSize: 11)),
                    TextSpan(text: " rojos ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 11)),
                    TextSpan(text: "sosteniendo tu CI. ", style: TextStyle(color: ColorApp.greyText, fontSize: 11)),
                  ]),
                )),
                Image.asset(
                  "assets/images/imagen.ciudadania-selfie-carnet 2.png",
                  width: 109,
                  height: 141,
                ),
              ],
            ),
          ),*/
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
