import 'dart:io';

import 'package:ciudadaniadigital/models/NotificacionModel.dart';
import 'package:ciudadaniadigital/pages/PreBuzon/detalle_notificacion.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/styles/styles.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';

/// Vista que muestra interfaces de buzón de notificaciones para ciudadanos aún no habilitados
///
class PreBuzonMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PreBuzonMain();
}

class _PreBuzonMain extends State<PreBuzonMain> {
  /// Lista de notificaciones
  List<NotificacionModel> _listNotificaciones;

  /// Identificador de ciudadano
  String _idCiudadano;

  /// Token de acceso
  String _token;

  /// Lista de filtros para las notificaciones
  List<dynamic> _arrayFiltro = [
    {'text': 'Todos', 'icon': 'icon_inbox.png'},
    {'text': 'Leídos', 'icon': 'icon_mail_read.png'},
    {'text': 'Sin Leer', 'icon': 'icon_unread.png'}
  ];

  /// Opción seleccionada del filtro
  String _opcionFiltro;

  /// Indicador de petición activa
  bool _peticionActiva = false;

  /// Foco del campo de carnet
  FocusNode cedulaFocus = FocusNode();

  /// Foco del campo de código
  FocusNode codigoFocus = FocusNode();

  /// controlador del campo carnet
  final TextEditingController _cedulaController = TextEditingController();

  /// Controlador del campo código
  final TextEditingController _codigoController = TextEditingController();

  /// Estado del formulario
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    inicializaDatos(_arrayFiltro[0]['text']);
  }

  /// Método que inicializa las opciones
  void inicializaDatos(String opcion) {
    _opcionFiltro = opcion;

    _listNotificaciones = new List();
  }

  /// Lista de notificaciones
  List<Widget> list(Size screenSize) {
    Utilidades.imprimir("mostrando ${_listNotificaciones.length} notificaciones");
    List<Widget> lista = [];
    _listNotificaciones.forEach((element) => lista.add(row(element)));
    return lista;
  }

  /// Item de la lista
  Widget row(NotificacionModel element) {
    return InkWell(
        child: Card(
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            color: ColorApp.listFillCell,
            elevation: 0,
            child: ListTileMoreCustomizable(
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 5),
              horizontalTitleGap: 0.0,
              minVerticalPadding: 20.0,
              minLeadingWidth: 0.0,
              onTap: (details) {
                abreNotificacion(element);
              },
              trailing: Container(
                alignment: Alignment.topRight,
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 30,
                    ),
                    Container(
                      child: Icon(
                        Icons.fiber_manual_record,
                        color: element.getFinalizado ? ColorApp.buttons : ColorApp.btnBackground,
                        size: 10,
                      ),
                    ),
                    Container(
                      child: Text(
                        element.getFinalizado ? "Leido" : "Sin Leer",
                        style: TextStyle(color: element.getFinalizado ? ColorApp.buttons : ColorApp.btnBackground, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    element.getUpdateAt,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "${element.getTitulo}".toString(),
                    maxLines: 2,
                    style: TextStyle(fontSize: 12.0, color: ColorApp.blackText, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              subtitle: RichText(
                text: TextSpan(style: TextStyle(fontSize: 12, color: Colors.grey), children: <TextSpan>[
                  TextSpan(
                    text: "${element.getInstitucion}".toString(),
                  ),
                ]),
              ),
            )));
  }

  /// Opciones de filtro en dropdown
  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    if (_peticionActiva) return null;
    List<DropdownMenuItem<String>> lista = new List();

    _arrayFiltro.forEach((filtro) {
      lista.add(DropdownMenuItem(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
//            Image.asset(
//              'assets/images/buzon/${filtro['icon']}',
//              width: 32,
//              height: 32,
//            ),
            SizedBox(width: 10),
            Text(filtro['text'],
                style: TextStyle(
                  color: ColorApp.greyText,
                  fontSize: 14,
                ))
          ],
        ),
        value: filtro['text'],
      ));
    });

    return lista;
  }

  /// Campo carnet
  Widget cedula() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            constraints: BoxConstraints(maxWidth: 285),
            alignment: Alignment.centerLeft,
            child: Text(
              "Cédula de identidad",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w500),
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: 285),
          height: 60,
          child: TextFormField(
            controller: _cedulaController,
            focusNode: cedulaFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (String value) {
              FocusScope.of(context).requestFocus(codigoFocus);
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Ingresa tu nro. de CI';
              }
              return null;
            },
            decoration: Estilos.entrada2(hintText: "Ingresa tu nro. de CI"),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  /// Campo de contraseña (código de acceso)
  Widget contrasena() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            constraints: BoxConstraints(maxWidth: 285),
            alignment: Alignment.centerLeft,
            child: Text(
              "Código de acceso",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w500),
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: 285),
          height: 60,
          child: TextFormField(
            controller: _codigoController,
            focusNode: codigoFocus,
            textInputAction: TextInputAction.send,
            validator: (value) {
              if (value.isEmpty) {
                return 'Ingresa tu código de acceso';
              }
              return null;
            },
            onFieldSubmitted: (value) {
              Utilidades.imprimir("value: $value");
              if (_formKey.currentState.validate()) {
                loginPreBuzon();
              }
            },
            decoration: Estilos.entrada2(hintText: "Ingresa tu código de acceso"),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Center(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: WillPopScope(
          onWillPop: () async {
            Utilidades.imprimir("intentando ir atras");
            return Dialogo.mostrarDialogoNativo(
                context,
                "Alerta",
                Text("¿Está seguro de cerrar el buzón de notificaciones?"),
                "Aceptar",
                () async {
                  Navigator.pop(context);
                  Utilidades.imprimir("regresando true");
                  return true;
                },
                secondButtonText: "Cancelar",
                secondCallback: () {
                  Utilidades.imprimir("regresando false");
                  return false;
                },
                secondActionStyle: ActionStyle.important);
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: new AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Dialogo.dialogoCancelar(context, "¿Está seguro de cerrar el buzón de notificaciones?");
                  },
                  child: Text(
                    "Cerrar",
                    style: new TextStyle(fontSize: 12.0, color: ColorApp.greyText),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Elementos.cabeceraLogos3(),
                  if (_idCiudadano == null && _token == null)
                    Form(
                      key: _formKey,
                      child: Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            'Buzón de notificaciones',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 30, left: 30),
                            child: Text(
                              'Acá encontrarás las notificaciones que hayas recibido, sin estar registrado en Ciudadanía Digital.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          cedula(),
                          contrasena(),
                          Container(
                            constraints: BoxConstraints(maxWidth: screenSize.width * 0.9),
                            child: FlatButton(
                              onPressed: () {
                                Dialogo.mostrarDialogoNativo(
                                    context,
                                    "Información",
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Text(
                                            "\nLa cédula de identidad equivale a su usuario en Ciudadanía Digital, si en su cédula de identidad tiene impreso su complemento de la forma 1234567-XX debe ingresar también el complemento tal cual se ve en su documento.\n",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            "\n¿Dónde obtengo el código de acceso?",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "\nPara obtener el código de acceso solicitelo a la entidad responsable la cual le asignará un único código de acceso.",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    "Aceptar",
                                    () {},
                                    firstActionStyle: ActionStyle.important);
                              },
                              child: Text(
                                "Saber más sobre estos campos",
                                style: TextStyle(color: ColorApp.btnBackground, fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      )),
                    ),
                  if (_idCiudadano == null && _token == null)
                    Container(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: SizedBox(
                          width: 221,
                          height: 40,
                          child: RaisedButton(
                            child: Text(
                              'Ingresar',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: ColorApp.bg, fontWeight: FontWeight.w500),
                            ),
                            color: ColorApp.buttons,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42.0)),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                loginPreBuzon();
                              }
                            },
                          ),
                        )),
                  if (_token != null)
                    Container(
                        margin: EdgeInsets.only(bottom: 20.0, left: 10.0, right: 10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 20),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Image.asset(
                                    "assets/images/icon_filter.png",
                                    width: 18,
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  child: DropdownButton(
                                    value: _opcionFiltro,
                                    items: getOpcionesDropdown(),
                                    disabledHint: Text('Cargando...',
                                        style: TextStyle(
                                          color: ColorApp.greyText,
                                          fontSize: 14,
                                        )),
                                    onChanged: (opcion) {
                                      inicializaDatos(opcion);
                                      setState(() {});
                                      obtieneNotificaciones();
                                    },
                                    isExpanded: true,
                                  ),
                                )
                              ],
                            ),
                            if (!_peticionActiva)
                              RefreshIndicator(
                                onRefresh: recargarLista,
                                child: Column(
                                  children: list(screenSize),
                                ),
                              ),
                          ],
                        )),
                  Container(
                    padding: EdgeInsets.only(top: 20, bottom: 5),
                    width: 200,
                    child: _peticionActiva
                        ? Elementos.indicadorProgresoLineal()
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  // if (_peticionActiva) Center(child: Elementos.indicadorProgresoCircularNativo())
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Método que recarga la lista
  Future<void> recargarLista() async {
    inicializaDatos(_arrayFiltro[0]['text']);
    setState(() {});
    obtieneNotificaciones();
  }

  /// Método que obtiene las  notificaciones
  Future<void> obtieneNotificaciones() async {
    peticion(estado: true);

    String bandeja = '';
    switch (_opcionFiltro) {
      case 'Leídos':
        bandeja = '&bandeja=HISTORICOS';
        break;
      case 'Sin Leer':
        bandeja = '&bandeja=PENDIENTES';
        break;
    }

    List<NotificacionModel> resultado = new List();

    await Services.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion: '${Constantes.urlBasePreBuzon}flujos/pendientes_historico_v1?limit=50&page=1&order=-updateAt$bandeja',
            headers: {HttpHeaders.authorizationHeader: 'Bearer $_token'})
        .then((responseObject) {
          if (responseObject.containsKey('finalizado') && responseObject['finalizado']) {
            for (var object in responseObject['datos']['listado']) {
              resultado.add(new NotificacionModel(
                id: object['_id'],
                titulo: object['titulo'] != null ? object['titulo'] : '',
                institucion: object['institucion'] != null ? object['institucion'] : '',
                updateAt: object['updateAt'] != null ? object['updateAt'] : '',
                finalizado: object['finalizado'] != null ? object['finalizado'] : false,
                nombreFlujo: object['nombreFlujo'] != null ? object['nombreFlujo'] : '',
              ));
            }
            setState(() {
              Utilidades.imprimir("${resultado.length} notificaciones");
              _listNotificaciones = resultado;
            });
          }
        })
        .catchError((onError) => {Alertas.showToast(mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true)})
        .whenComplete(() {
          peticion(estado: false);
        });
  }

  /// Método que abre el detalle de una notificación
  Future<void> abreNotificacion(NotificacionModel notificacion) async {
    await Dialogo.showNativeModalBottomSheet(
        context,
        DetalleNotificacion(
          idCiudadano: _idCiudadano,
          token: _token,
          notificacion: notificacion,
          esPreBuzon: true,
        ));
  }

  /// Método que obtiene un token para acceder al pre buzón
  Future<void> loginPreBuzon() async {
    peticion(estado: true);
    await Services.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion: '${Constantes.urlBasePreBuzonLogin}${_cedulaController.text.trim()}/${_codigoController.text.trim()}')
        .then((response) async {
          Utilidades.imprimir("respuesta $response");
          setState(() {
            _idCiudadano = response['idCiudadano'];
            _token = response['token'];
          });
          await obtieneNotificaciones();
        })
        .catchError((onError) => {
              Alertas.showToast(mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true),
            })
        .whenComplete(() => peticion(estado: false));
  }

  /// Método que ajusta el estado de una petición activa
  void peticion({bool estado}) {
    setState(() {
      _peticionActiva = estado;
    });
  }
}
