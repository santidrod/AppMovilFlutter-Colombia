import 'dart:io';

import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/ServiciosDetalleWeb.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Vista que muestra una vista web para ver los servicios disponibles con ciudadanía digital

class ServiciosWidget extends StatefulWidget {
  /// Indicador para bloquear la vista
  final bool bloquear;

  /// Texto iniciar que viene de la vista home
  final String texto;

  const ServiciosWidget({Key key, this.bloquear, this.texto}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ServiciosWidgetState();
  }
}

class _ServiciosWidgetState extends State<ServiciosWidget> {
  /// Lista de servicios disponibles
  List<dynamic> serviciosDisponibles = [];

  /// Indicador de petición activa
  bool cargando = false;

  /// token
  String token = "";

  /// Patrón para terminaciones de archivo con .svg, .jpg, .png
  final RegExp svgRegEx = RegExp(r"\.(svg)$");
  final RegExp imgRegEx = RegExp(r"\.(jpg|jpeg|png)$");

  @override
  void initState() {
    super.initState();
    obtenerServiciosDigitales(context: context);
  }

  void estadoCarga({bool estadoCarga}) {
    setState(() {
      cargando = estadoCarga;
    });
  }

  /// Método que obtiene las sesiones activas en otros dispositivos
  Future obtenerServiciosDigitales(
      {BuildContext context, bool mostrarCarga = true}) async {
    if (mostrarCarga) estadoCarga(estadoCarga: true);
    String accesToken = await Sesion.verificarObtenerToken(context);
    await Services.peticion(
      tipoPeticion: TipoPeticion.GET,
      urlPeticion:
          '${Constantes.urlCiudadaniaServiciosDigitalesApiRest}/api/public/validarToken?t=$accesToken',
    ).then((response) {
      setState(() {
        token = response["token"];
        serviciosDisponibles =
            (new List<dynamic>.from(response["services"])).map((element) {
          element['icon_url'] =
              '${Constantes.urlCiudadaniaServiciosDigitales}images/${element['imagen']}';
          return element;
        }).toList();
        /*serviciosDisponibles.insert(0, {
          "titulo": "gob.bo",
          "descripcion_corta": "Portal de trámites, toda la información que necesitas e Instituciones Públicas",
          "icon_url": "https://st2.depositphotos.com/1027309/6176/v/450/depositphotos_61767321-stock-illustration-map-bolivia.jpg",
          "accion": () async {
            await Dialogo.showNativeModalBottomSheet(context, BuscadorTramites());
          }
        });*/ // Agregando Gob.bo al principio
      });
      Utilidades.imprimir(
          "${serviciosDisponibles.length} Servicios digitales 💡: $response");
    }).catchError((onError) {
      Utilidades.imprimir("Error: $onError ");
      Alertas.showToast(
          mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true);
    }).whenComplete(() => {
          Utilidades.imprimir("Lista de Servicios digitales 💡"),
          estadoCarga(estadoCarga: false)
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Platform.isAndroid
          ? RefreshIndicator(
              onRefresh: () async {
                await obtenerServiciosDigitales(
                    context: context, mostrarCarga: false);
              },
              child: contenido())
          : contenido(),
    );
  }

  Widget contenido() {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              await obtenerServiciosDigitales(
                  context: context, mostrarCarga: false);
            },
          ),
          SliverToBoxAdapter(
            child: Elementos.cabeceraLogos3(),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[indicaciones()],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Visibility(
                visible: cargando,
                child: Elementos.indicadorProgresoLineal(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
                alignment: Alignment.center,
                child: Container(
                    constraints: BoxConstraints(maxWidth: 700),
                    child: lista(screenSize))),
          ),
        ],
      ),
    );
  }

  /// Widget que muestra indicaciones acerca de la vista
  Widget indicaciones() {
    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
        child: Text(
          "Estos son los servicios digitales del Estado Plurinacional de Bolivia a los que puedes acceder:",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
        ));
  }

  Widget lista(Size screenSize) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: serviciosDisponibles.length,
        itemBuilder: (BuildContext context, int index) {
          return row(index);
        },
      ),
    );
  }

  /// Item de la lista de servicios
  Widget row(int index) {
    return Card(
        margin: EdgeInsets.only(bottom: 10, left: 30, right: 30, top: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: ColorApp.listFillCell,
        shadowColor: Colors.transparent,
        child: ListTile(
          contentPadding:
              EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          onTap: () async {
            if (serviciosDisponibles[index]["accion"] != null) {
              serviciosDisponibles[index]["accion"].call();
            } else {
              await Dialogo.showNativeModalBottomSheet(
                  context,
                  ServicioDetalle(
                      titulo: serviciosDisponibles[index]["titulo"],
                      url: obtieneUrl(serviciosDisponibles[index])));
            }
          },
          leading: _obtieneIcono(serviciosDisponibles[index]["icon_url"] ?? ""),
          title: Text(
            "${serviciosDisponibles[index]["titulo"]}",
            maxLines: 2,
            style: TextStyle(
                fontSize: 14.0,
                color: ColorApp.btnBackground,
                fontWeight: FontWeight.w500),
          ),
          subtitle: RichText(
            text: TextSpan(
                style: TextStyle(fontSize: 10, color: ColorApp.greyDarkText),
                children: <TextSpan>[
                  TextSpan(
                    text: "${serviciosDisponibles[index]["descripcion_corta"]}"
                        .toString(),
                  ),
                ]),
          ),
        ));
  }

  Widget _obtieneIcono(String iconUrl) {
    if (svgRegEx.hasMatch(iconUrl)) {
      // formato SVG
      return SvgPicture.network(
        iconUrl,
        width: 50,
      );
    } else if (imgRegEx.hasMatch(iconUrl)) {
      // formato JPG o PNG
      return Image.network(
        iconUrl, // Agregar iconos
        errorBuilder:
            (BuildContext context, Object exception, StackTrace stackTrace) {
          return Text('🖼');
        },
        width: 50,
      );
    } else
      return Text('');
  }

  String obtieneUrl(dynamic servicio) {
    if (servicio["codigo"] == "GOBBO") return servicio["url"];
    return "${Constantes.urlCiudadaniaServiciosDigitalesApiRest}${servicio["url"]}?t=$token";
  }
}
