import 'dart:io';

import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

/// Seleccion de entidad con la que se hará el registro
String _seleccionFiltro = "";

/// Vista que muestra las entidades registradoras, con opción de escoger una
class OpcionEntidadRegistradora extends StatefulWidget {
  const OpcionEntidadRegistradora({Key key}) : super(key: key);

  @override
  _OpcionEntidadRegistradoraState createState() => _OpcionEntidadRegistradoraState();

  /// Método que guarda una entidad
  static Future verificar() async {
    if (_seleccionFiltro.length == 0)
      return throw "Debe seleccionar un item";
    else {
      await Utilidades.saveSecureStorage(key: "id_entidad", value: _seleccionFiltro);
    }
  }
}

class _OpcionEntidadRegistradoraState extends State<OpcionEntidadRegistradora> {
  _OpcionEntidadRegistradoraState();

  /// Lista de entidades
  List<dynamic> _opcionesFiltro = [];

  @override
  void initState() {
    super.initState();
    obtenerEntidadesHorarios();
  }

  /// Método que obtiene la lista de entidades
  void obtenerEntidadesHorarios() async {
    await Services.peticion(
      tipoPeticion: TipoPeticion.GET,
      urlPeticion: "${Constantes.urlBasePreRegistroForm}entidades",
      headers: {HttpHeaders.userAgentHeader: (await Utilidades.cabeceraUserAgent()).toString()},
    ).then((response) {
      _opcionesFiltro = response["datos"];
      _seleccionFiltro = _opcionesFiltro.first["codigo"];
      setState(() { });
    }).then((_) => Services.peticion(tipoPeticion: TipoPeticion.GET, urlPeticion: '${Constantes.urlGobBoTramites}entidad'))
    .then((listado) {
      // agregamos sigla a las entidades (si esta disponible)
      if (listado["datos"] != null && listado["datos"].length > 0) {
        List<dynamic> listadoEntidades = listado["datos"];
        _opcionesFiltro = _opcionesFiltro.map((element) {
          List<dynamic> entidades = listadoEntidades.where((e) => e["id_entidad"].toString().compareTo(element["codigo"]) == 0).toList();
          if (entidades.length == 1 && entidades[0]["sigla"] != null) {
            element["nombre"] = '${entidades[0]["sigla"]} - ${element["nombre"]}';
          }
          return element;
        }).toList();
      }
      setState(() { });
    })
    .catchError((onError) {
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
                  "A continuación, elige una entidad de registro remoto relacionada con el servicio para el que deseas obtener tu ciudadanía digital:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100, color: ColorApp.greyText),
                )),
          ),
          Container(
            height: 180,
            alignment: Alignment.center,
            child: DropdownButton(
              items: _opcionesFiltro
                  .map((dynamic item) => DropdownMenuItem<String>(
                      child: Container(
                        width: 200,
                        child: Text(
                          item["nombre"],
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
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(right: 48, left: 48),
            alignment: Alignment.bottomCenter,
            child: Text(
              "Si ninguna de estas entidades está relacionada con el motivo de tu registro en Ciudadanía digital, o no sabes cuál deberías elegir, selecciona la AGETIC.",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100, color: ColorApp.btnBackground),
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
