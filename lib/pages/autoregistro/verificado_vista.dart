import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

/// Vista que muestra que una determinada validación fue ejecutada correctamente
class VerificadoVista extends StatefulWidget {
  /// Mensaje de confirmación
  final String mensaje;

  /// indicador en caso de error
  final bool error;

  const VerificadoVista({Key key, this.error, this.mensaje}) : super(key: key);

  @override
  _VerificadoVistaState createState() => _VerificadoVistaState();

  /// Método que válida la acción
  static Future verificadoAccion() async {
    try {
      Utilidades.imprimir("Respuesta : Continuar");
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
    }
  }
}

class _VerificadoVistaState extends State<VerificadoVista> {
  _VerificadoVistaState();

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height * 0.46;

    return Container(
      height: screenHeight,
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: 20,
          ),
          widget.error
              ? Image.asset(
                  "assets/images/icon_correct_blue.png",
                  width: 133,
                )
              : Image.asset(
                  "assets/images/icon_correct_blue.png",
                  width: 133,
                ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(right: 30, left: 30),
            alignment: Alignment.bottomCenter,
            child: Text(
              widget.mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
