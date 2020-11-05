import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import 'package:recase/recase.dart';

import 'actualizar_datos.dart';

/// Vista que mostrara un formulario para cambiar la contraseña

class InformacionPersonal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InformacionPersonalState();
  }
}

class _InformacionPersonalState extends State<InformacionPersonal> {
  _InformacionPersonalState();

  final TextEditingController nombreCompletoController =
      TextEditingController();
  final TextEditingController fechaNacimientoController =
      TextEditingController();
  final TextEditingController carnetIdentidadController =
      TextEditingController();
  final TextEditingController contraseniaController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  String nombreCompleto = "-";
  String fechaNacimiento = "-";
  String carnetIdentidad = "-";
  String contrasenia = "-";
  String correo = "-";
  String telefono = "-";

  bool cargando = false;

  @override
  void initState() {
    super.initState();
    obtenerPerfil();
  }

  Future obtenerPerfil() async {
    estadoCarga(valor: true);

    await Sesion.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion: '${Constantes.urlIsuer}me',
            context: context)
        .then((response) {
      Utilidades.imprimir("Respuesta perfil 👤: $response");
      setState(() {
        nombreCompleto =
            "${response["profile"]["nombre"]["nombres"]} ${response["profile"]["nombre"]["primer_apellido"]} ${response["profile"]["nombre"]["segundo_apellido"]}"
                .titleCase;
        fechaNacimiento = response["fecha_nacimiento"];
        carnetIdentidad =
            "${response["profile"]["documento_identidad"]["tipo_documento"]} ${response["profile"]["documento_identidad"]["numero_documento"]}";
        contrasenia = "*******";
        correo = response["email"];
        telefono = response["celular"];
      });
    }).catchError((onError) {
      Utilidades.imprimir("Error runtimeType: ${onError.runtimeType} ");
      Utilidades.imprimir("Error: $onError ");
      Alertas.showToast(
          mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true);
    }).whenComplete(() {
      Utilidades.imprimir("Perfil completo");
      estadoCarga(valor: false);
    });
  }

  Widget campoValor({String campo, String valor, VoidCallback accion}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 0.5,
            ),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          height: 70,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  campo ?? "",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                child: ListTileMoreCustomizable(
                    title: Text(valor, style: TextStyle(fontSize: 14)),
                    contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                    onTap: (details) {
                      if (accion != null) accion.call();
                    },
                    horizontalTitleGap: 0.0,
                    trailing: accion != null
                        ? Image.asset(
                            "assets/images/icon_edit.png",
                            width: 20,
                          )
                        : null),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget seccionValor({String campo}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Container(
        alignment: Alignment.centerLeft,
        height: 60,
        child: Text(
          campo ?? "",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void estadoCarga({bool valor}) {
    setState(() {
      cargando = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Text(""),
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.clear,
                color: ColorApp.greyDarkText,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                    child: Text("Información personal",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500))),
                Container(
                    padding: EdgeInsets.only(left: 30, right: 30, top: 10),
                    child: Text(
                        "Información básica y de contacto que utilizas en los servicios de Ciudadanía Digital",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300))),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Visibility(
                    visible: cargando,
                    child: Elementos.indicadorProgresoLineal(),
                  ),
                ),
                seccionValor(campo: "Perfil"),
                campoValor(campo: "Nombre", valor: nombreCompleto),
                campoValor(
                    campo: "Fecha de Nacimiento", valor: fechaNacimiento),
                campoValor(campo: "Documento", valor: carnetIdentidad),
                campoValor(
                    campo: "Contraseña",
                    valor: contrasenia,
                    accion: () async {
                      await Dialogo.showNativeModalBottomSheet(
                              context,
                              ActualizarDatosWidget(
                                  tipoDeActualizacion:
                                      tipoActualizacion.PASSWORD))
                          .then((value) => obtenerPerfil());
                    }),
                seccionValor(campo: "Información de contacto"),
                campoValor(
                    campo: "Correo electrónico",
                    valor: correo,
                    accion: () async {
                      await Dialogo.showNativeModalBottomSheet(
                              context,
                              ActualizarDatosWidget(
                                  tipoDeActualizacion: tipoActualizacion.EMAIL))
                          .then((value) => obtenerPerfil());
                    }),
                campoValor(
                    campo: "Télefono",
                    valor: telefono,
                    accion: () async {
                      await Dialogo.showNativeModalBottomSheet(
                              context,
                              ActualizarDatosWidget(
                                  tipoDeActualizacion: tipoActualizacion.PHONE))
                          .then((value) => obtenerPerfil());
                    }),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
