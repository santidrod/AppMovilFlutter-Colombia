import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

/// Vista informativa con ilustraciones de carnet de identidad
class InformacionCarnet extends StatefulWidget {
  const InformacionCarnet({Key key}) : super(key: key);

  @override
  _InformacionCarnetState createState() => _InformacionCarnetState();

  /// Método para continuar a la siguiente vista

  static Future verificadoAccion() async {
    try {
      Utilidades.imprimir("Respuesta : Continuar");
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
    }
  }
}

class _InformacionCarnetState extends State<InformacionCarnet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: RichText(
                text: TextSpan(style: TextStyle(color: ColorApp.greyText, fontWeight: FontWeight.w300, fontSize: 12), children: <TextSpan>[
                  TextSpan(
                    text:
                        "A continuación, deberás sacar una foto del anverso de tu cédula de identidad y posteriormente, una del reverso del mismo C.I.",
                    style: TextStyle(color: ColorApp.greyText, fontSize: 12),
                  ),
                ]),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Image.asset(
                "assets/images/imagen_carnet_anverso.png",
                width: 200,
                height: 133,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            height: 40,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Text(
              "Anverso de la cédula de identidad",
              style: TextStyle(color: ColorApp.greyText, fontSize: 11),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Image.asset(
                "assets/images/image_carnet_reverso.png",
                width: 200,
                height: 141,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            height: 40,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Text(
              "Reverso de la cédula de identidad",
              style: TextStyle(color: ColorApp.greyText, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
