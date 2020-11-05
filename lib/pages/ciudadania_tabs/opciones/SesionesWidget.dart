import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

/// Vista que muestra las sesiones de un usuario en otros dispositivos

class SesionesWidget extends StatefulWidget {
  const SesionesWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SesionesWidgetState();
  }
}

class _SesionesWidgetState extends State<SesionesWidget> {
  _SesionesWidgetState();

  /// Lista de sesiones
  List<dynamic> sesiones = [];

  /// Indicador de petición activa
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    obtenerSesiones();
  }

  /// Método que modifica la el estado de carga
  void estadoCarga() {
    setState(() {
      cargando = !cargando;
    });
  }

  /// Método que obtiene las sesiones activas en otros dispositivos
  Future obtenerSesiones() async {
    estadoCarga();

    await Sesion.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion: '${Constantes.urlIsuer}api/v1/sessions',
            context: context)
        .then((response) {
      Utilidades.imprimir("Sesiones 📲: $response");
      setState(() {
        sesiones = response["data"];
      });
    }).catchError((onError) {
      Utilidades.imprimir("Error: $onError ");
      Alertas.showToast(
          mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true);
    }).whenComplete(
            () => {Utilidades.imprimir("Lista de sesiones"), estadoCarga()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      EdgeInsets.only(top: 40, bottom: 30, left: 30, right: 30),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.devices),
                      SizedBox(width: 20),
                      Text(
                        "Sesiones",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )),
              Container(
                height: 100,
                width: 100,
                padding:
                    EdgeInsets.only(top: 40, bottom: 30, left: 30, right: 30),
                child: InkWell(
                  child: Icon(Icons.clear),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          Container(
              padding:
                  EdgeInsets.only(top: 10, bottom: 20, left: 30, right: 30),
              child: Text(
                "A continuación, puedes ver los dispositivos en los que iniciaste sesión usando Ciudadanía Digital",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              )),
          Container(
            child: Visibility(
              visible: cargando,
              child: Elementos.indicadorProgresoLineal(),
            ),
          ),
          sesiones.length > 0
              ? list()
              : Center(
                  child: Container(
                      height: 100,
                      child: Text("No se encontraron dispositivos")))
        ],
      )),
    );
  }

  Widget list() {
    return Expanded(
      child: ListView.builder(
        itemCount: sesiones.length,
        itemBuilder: (BuildContext context, int index) {
          return row(index);
        },
      ),
    );
  }

  /// Item de la lista de sesiones
  Widget row(int index) {
    return Card(
        margin: EdgeInsets.only(bottom: 10, left: 30, right: 30, top: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: ColorApp.listFillCell,
        shadowColor: Colors.transparent,
        child: ListTile(
          contentPadding:
              EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
          dense: true,
          trailing: sesiones[index]["type_device"] == "tablet"
              ? Icon(Icons.tablet)
              : sesiones[index]["type_device"] == "desktop"
                  ? Icon(Icons.desktop_windows)
                  : sesiones[index]["type_device"] == "mobile"
                      ? Icon(Icons.phone_iphone)
                      : Icon(Icons.computer),
          title: Text(
            "${sesiones[index]["navigator_platform"]} - ${sesiones[index]["browser"]}",
            maxLines: 2,
            style: TextStyle(
                fontSize: 12.0,
                color: ColorApp.blackText,
                fontWeight: FontWeight.w500),
          ),
          subtitle: RichText(
            text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey),
                children: <TextSpan>[
                  TextSpan(text: sesiones[index]["date"]),
                ]),
          ),
        ));
  }
}
