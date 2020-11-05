import 'dart:io';

import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

/// Variable con palabras clave para filtro
String _seleccionFiltro = "";

/// Vista que muestra una lista con horarios de llamada
class HorarioLlamada extends StatefulWidget {
  const HorarioLlamada({Key key}) : super(key: key);

  @override
  _HorarioLlamadaState createState() => _HorarioLlamadaState();

  /// Vista que confirme el horario de llamada

  static Future verificar() async {
    try {
      String idEntidad = await Utilidades.readSecureStorage(key: "id_entidad");
      String contentId1 = await Utilidades.readSecureStorage(key: 'content_id_1');

      Map<String, String> bodyParams = {
        'hora_preferida': _seleccionFiltro,
      };

      var value = await Services.peticion(
          tipoPeticion: TipoPeticion.POST,
          urlPeticion: "${Constantes.urlBasePreRegistroForm}entidades/$idEntidad/verificacion",
          headers: {
            "Content-Id": contentId1,
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          },
          bodyparams: bodyParams);

      Utilidades.imprimir("Respuesta : $value");

      await Utilidades.saveSecureStorage(key: "hora_preferida", value: _seleccionFiltro);
    } catch (error) {
      Utilidades.imprimir('Error al verificar el celular: $error');
      return throw (error);
    }
  }
}

class _HorarioLlamadaState extends State<HorarioLlamada> {
  _HorarioLlamadaState();

  /// Lista de horario
  List<dynamic> _opcionesFiltro = [];

  @override
  void initState() {
    super.initState();
    obtenerEntidadesHorarios();
  }

  /// Método contiene la lista de horarios
  void obtenerEntidadesHorarios() async {
    await Services.peticion(
      tipoPeticion: TipoPeticion.GET,
      urlPeticion: "${Constantes.urlBasePreRegistroForm}entidades",
      headers: {HttpHeaders.userAgentHeader: (await Utilidades.cabeceraUserAgent()).toString()},
    ).then((response) {
      setState(() {
        _opcionesFiltro = response["horarios"];
        _seleccionFiltro = _opcionesFiltro.first["codigo"];
      });
    }).catchError((onError) {
      Utilidades.imprimir("Ocurrio un error obteniendo las entidades: $onError");
      Alertas.showToast(mensaje: "Error al obtener las entidades", danger: true);
    }).whenComplete(() {});
  }

  @override
  Widget build(BuildContext context) {
    // var screenSize = MediaQuery.of(context).size;
    // var screenHeight = screenSize.height * 0.55;

    return Container(
      // height: screenHeight, omitiendo por desbordamiento de pixeles
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        direction: Axis.vertical,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 48, right: 48),
            alignment: Alignment.bottomCenter,
            child: Container(
                padding: const EdgeInsets.all(10.0),
                constraints: BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: ColorApp.listFillCell,
                ),
                child: Text(
                  "Elige el horario en que prefieres que te contactemos para verificar tu identidad",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100, color: ColorApp.greyText),
                )),
          ),
          Container(
            height: 200,
            alignment: Alignment.center,
            child: DropdownButton(
              items: _opcionesFiltro
                  .map((
                    dynamic item,
                  ) =>
                      DropdownMenuItem<String>(
                          child: Container(
                            width: 200,
                            child: Text(
                              "${item["valor"]}", //  - ${item["codigo"]}
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                          value: item["codigo"]))
                  .toList(),
              hint: Container(width: 200, child: Text("Lista entidades")),
              disabledHint: Text('Cargando...',
                  style: TextStyle(
                    color: ColorApp.greyText,
                    fontSize: 16,
                  )),
              onChanged: (value) {
                setState(() {
                  _seleccionFiltro = value;
                  Utilidades.imprimir(_seleccionFiltro);
                });
              },
              value: _seleccionFiltro,
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Elige un horario de tu conveniencia para que nos contactemos contigo. Recuerda que la llamada será hecha en los próximos tres días hábiles.",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w100, color: ColorApp.btnBackground),
                  ),
                ),
                Image.asset(
                  "assets/images/imagen_3dias.png",
                  width: 109,
                  height: 133,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
