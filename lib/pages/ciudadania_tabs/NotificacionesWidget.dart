import 'dart:async';
import 'dart:io';

import 'package:ciudadaniadigital/models/NotificacionModel.dart';
import 'package:ciudadaniadigital/pages/PreBuzon/detalle_notificacion.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/ConfiguracionesWidget.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/servicios/MessageBus.dart';
import 'package:ciudadaniadigital/utilidades/servicios/ServiceLocator.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import 'package:recase/recase.dart';

import 'Elementos.dart';

/// Vista que muestra las notificaciones de trámites que recibio el usuario

class NotificacionesWidget extends StatefulWidget {
  /// Indicador para bloquear la vista
  final bool bloquear;

  /// Texto que viene de la vista Home
  final String texto;

  const NotificacionesWidget({Key key, this.bloquear, this.texto})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NotificacionesWidgetState();
  }
}

class _NotificacionesWidgetState extends State<NotificacionesWidget> {
  /// Indicador de petición correcta
  bool _peticionCorrecta = true;

  /// Lista de notificaciones
  List<NotificacionModel> _notificacionesDisponibles = new List();

  /// Lista id`s de trámites destacados
  List<String> _listIdDestacados = new List();

  /// Variable que se usara de filtro
  String _seleccionFiltro;

  /// Opciones para filtrar las notificaciones
  List<Map> _opcionesFiltro = [
    {"id": 1, "name": "Todo"},
    {"id": 2, "name": "Destacados"},
    {"id": 4, "name": "Sin leer"},
    {"id": 3, "name": "Leídos"},
  ];

  /// Indicador de petición activa
  bool _peticionActiva = false;

  /// Indicador para mostrar progreso
  bool _mostrarProgreso = false;

  /// Valor de la palabra filtro
  String valorFiltro = "";

  /// Limite de notificaciones por defecto
  final int _limiteDefault = 50;

  /// Cantidad de notificaciones por pagina
  int _limite;

  /// página actual de notificaciones
  int _paginaActual = 1;

  /// cantidad total de páginas
  int _totalPaginas = 0;

  /// total de notificaciones
  int _total = 0;

  /// ancho de pantalla
  double _screenWidth;

  /// Variable para obtener los mensajes del bus
  ButtonMessageBus _messageBus = locator<ButtonMessageBus>();

  /// Suscripcion para id's de pestaña seleccionada entrantes
  StreamSubscription<int> messageSubscription;

  @override
  void initState() {
    super.initState();
    valorFiltro = _opcionesFiltro[0]['name'];
    _seleccionFiltro = valorFiltro;
    _limite = _limiteDefault;
    inicializaDatos();

    // suscribe el 'listener' para id de pestaña entrante
    messageSubscription = _messageBus.idStream.listen(_idReceived);
  }

  @override
  void dispose() {
    messageSubscription.cancel();
    super.dispose();
  }

  void inicializaDatos() {
    _paginaActual = 1;
    _total = 0;
  }

  /// Método que recibe los id recibidos de las pestañas seleccionadas
  void _idReceived(int id) {
    if (id == 1) {
      // pestaña notificaciones activa
      obtieneNotificaciones(mostrarCarga: true);
    }
  }

  /// Método que cambia el estado de una petición activa
  void estadoCarga({bool peticionActiva, bool mostrarProgreso}) {
    setState(() {
      _peticionActiva = peticionActiva;
      _mostrarProgreso = mostrarProgreso;
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Platform.isAndroid
            ? RefreshIndicator(
                onRefresh: () async {
                  if (!_peticionActiva) {
                    inicializaDatos();
                    await obtieneNotificaciones(mostrarCarga: false);
                  }
                },
                child: contenido(),
              )
            : contenido());
  }

  /// Widget que muestra la bandeja principal

  Widget bandejaPrincipal() {
    if (_peticionCorrecta) {
      if (_notificacionesDisponibles.length == 0) {
        String mensaje = 'No tiene notificaciones disponibles en su bandeja';
        if (_seleccionFiltro != _opcionesFiltro[0]['name']) {
          mensaje =
              mensaje.replaceAll('disponibles', _seleccionFiltro.toLowerCase());
        }
        return SliverToBoxAdapter(
          child: Container(
            constraints: BoxConstraints(maxWidth: 700),
            child: Card(
                margin:
                    EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
                shape: RoundedRectangleBorder(
                    // side: BorderSide(color: ColorApp.colorGrisClaro),
                    borderRadius: BorderRadius.circular(12.0)),
                color: ColorApp.listFillCell,
                shadowColor: Colors.transparent,
                child: Container(
                  alignment: Alignment.center,
                  height: 100,
                  child: Text(
                    mensaje,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: ColorApp.blackText,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )),
          ),
        );
      } else {
        return SliverToBoxAdapter(
          child: Container(
              alignment: Alignment.center,
              child: Container(
                  constraints: BoxConstraints(maxWidth: 700), child: lista())),
        );
      }
    } else {
      return SliverToBoxAdapter(
        child: Card(
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            color: ColorApp.listFillCell,
            shadowColor: Colors.transparent,
            child: ListTile(
                contentPadding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 5),
                title: Column(
                  children: [
                    Text(
                      'No se pudo obtener las notificaciones',
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: ColorApp.blackText,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    InkWell(
                      onTap: () => _peticionActiva
                          ? null
                          : obtieneNotificaciones(mostrarCarga: true),
                      child: Column(
                        children: [
                          /*Icon(Icons.update),*/
                          Image.asset(
                            'assets/images/refresh.png',
                            width: 25,
                          ),
                          Text('intentar de nuevo')
                        ],
                      ),
                    )
                  ],
                ))),
      );
    }
  }

  Widget lista() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _notificacionesDisponibles.length,
        itemBuilder: (BuildContext context, int index) {
          return row(index);
        },
      ),
    );
  }

  /// Widget que muestra el contenido de la vista en un scroll
  Widget contenido() {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverRefreshControl(
          onRefresh: _peticionActiva
              ? null
              : () async {
                  await obtieneNotificaciones(mostrarCarga: false);
                },
        ),
        SliverToBoxAdapter(
          child: Elementos.cabeceraLogos3(),
        ),
        SliverToBoxAdapter(
          child: Container(
              alignment: Alignment.center,
              child: Container(
                  constraints: BoxConstraints(maxWidth: 700), child: filtro())),
        ),
        SliverToBoxAdapter(
          child: Container(
            width: 200,
            child: Visibility(
              visible: _mostrarProgreso,
              child: Elementos.indicadorProgresoLineal(),
            ),
          ),
        ),
        bandejaPrincipal()
      ],
    );
  }

  /// Widget que muestra el filtro de la aplicación de las notificaciones
  Widget filtro() {
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 0, left: 30, right: 30),
        alignment: Alignment.topLeft,
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Notificaciones",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: ColorApp.colorBlackClaro),
              ),
            ),
            SizedBox(height: 20),
            controlesFiltro(),
          ],
        ));
  }

  Widget controlesFiltro() {
    if (_screenWidth < 362) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [selectorFiltro(), SizedBox(height: 10), paginacionFiltro()],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [selectorFiltro(), paginacionFiltro()],
      );
    }
  }

  Widget selectorFiltro() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          child: InkWell(
            onTap: () {
              inicializaDatos();
              obtieneNotificaciones(mostrarCarga: true);
            },
            child: Image.asset(
              "assets/images/refresh.png",
              width: 18,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: ColorApp.colorGrisClaro),
              borderRadius: BorderRadius.circular(32.0)),
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: DropdownButton(
              icon: Icon(Icons.keyboard_arrow_down),
              isDense: true,
              items: _opcionesFiltro.map((item) {
                return DropdownMenuItem(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(item['name'],
                          style: TextStyle(
                            color: ColorApp.greyText,
                            fontSize: 12,
                          )),
                    ),
                    value: item['name']);
              }).toList(),
              disabledHint: Text('Cargando...',
                  style: TextStyle(
                    color: ColorApp.greyText,
                    fontSize: 12,
                  )),
              onChanged: _peticionActiva
                  ? null
                  : (value) {
                      setState(() {
                        valorFiltro = value;
                        _paginaActual = 1;
                      });
                      obtieneNotificaciones(mostrarCarga: true);
                    },
              value: _seleccionFiltro,
            ),
          ),
        ),
      ],
    );
  }

  Widget paginacionFiltro() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          child: Text(
            actualizaTextoPaginacion(),
            style: TextStyle(fontSize: 10),
          ),
        ),
        InkWell(
          onTap: () {
            if (_paginaActual > 1) {
              _paginaActual--;
              obtieneNotificaciones(mostrarCarga: true);
            }
          },
          child: Container(
            padding: EdgeInsets.all(5),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                gradient: RadialGradient(
                    colors: [Colors.transparent, ColorApp.colorGrisClaro],
                    stops: [0.9, 0.1]),
                shape: BoxShape.circle),
            child: Image.asset(
              'assets/images/icon_previous.png',
              color: ColorApp.colorGrisClaro,
            ),
          ),
        ),
        SizedBox(width: 10),
        InkWell(
          onTap: () {
            if (_paginaActual < _totalPaginas) {
              _paginaActual++;
              obtieneNotificaciones(mostrarCarga: true);
            }
          },
          child: Container(
              padding: EdgeInsets.all(5),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  gradient: RadialGradient(
                      colors: [Colors.transparent, ColorApp.colorGrisClaro],
                      stops: [0.9, 0.1]),
                  shape: BoxShape.circle),
              child: Image.asset(
                'assets/images/icon_next.png',
                color: ColorApp.colorGrisClaro,
              )),
        ),
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.all(5),
          child: InkWell(
            onTap: _peticionActiva
                ? null
                : () async {
                    if (await Services.conexionInternet()) {
                      await Dialogo.showNativeModalBottomSheet(
                          context, ConfiguracionesWidget());
                    } else {
                      Alertas.showToast(
                          mensaje: "No tiene conexión a internet 🌍",
                          danger: true);
                    }
                  },
            child: Container(
              padding: EdgeInsets.all(5),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  gradient: RadialGradient(
                      colors: [Colors.transparent, ColorApp.colorGrisClaro],
                      stops: [0.9, 0.1]),
                  shape: BoxShape.circle),
              child: Image.asset('assets/images/icon_settings.png'),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget que muestra un item de la lista de notificaciones
  Widget row(int index) {
    NotificacionModel element = _notificacionesDisponibles[index];
    return Card(
        margin: EdgeInsets.only(bottom: 10, left: 25, right: 25, top: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: ColorApp.listFillCell,
        shadowColor: Colors.transparent,
        child: ListTileMoreCustomizable(
            contentPadding: EdgeInsets.only(left: 15, right: 15),
            horizontalTitleGap: 0.0,
            minVerticalPadding: 10.0,
            minLeadingWidth: 0.0,
            onTap: (details) {
              abreNotificacion(element);
            },
            title: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetDestacado(index),
                    detalleFechaNotificacion(element.getUpdateAt),
                    detalleRecibidoNotificacion(finalizado: element.getFinalizado)
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    element.getInstitucion.titleCase,
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 14.0,
                        color: ColorApp.blackText,
                        fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
            subtitle: Column(
              children: [
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    element.getNombreFlujo.titleCase,
                    maxLines: 2,
                    style: TextStyle(fontSize: 12.0, color: ColorApp.greyText),
                  ),
                ),
              ],
            )));
  }

  Widget detalleFechaNotificacion(String fecha) {
    return Text(
      Utilidades.parseHoraFecha(
          fechaInicial: fecha, horaRequerida: false, mesNumerico: true),
      style: TextStyle(fontSize: 10, color: ColorApp.greyText),
    );
  }

  Widget detalleRecibidoNotificacion({bool finalizado}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Icon(
            Icons.fiber_manual_record,
            color: !finalizado ? ColorApp.btnBackground : ColorApp.buttons,
            size: 10,
          ),
        ),
        SizedBox(width: 6),
        Container(
          child: Text(
            finalizado ? "Leído" : "Recibido",
            style: TextStyle(
              color: !finalizado ? ColorApp.btnBackground : ColorApp.buttons,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget que muestra el indicador de trámite destacado
  Widget widgetDestacado(int index) {
    NotificacionModel element = _notificacionesDisponibles[index];
    return InkWell(
      onTap: () async {
        bool flag = element.getDestacado;
        var result = await Sesion.peticion(
            tipoPeticion: flag ? TipoPeticion.DELETE : TipoPeticion.PUT,
            urlPeticion:
                '${Constantes.urlNotificacionesConfiguracion}notificaciones/destacados/${element.getId}',
            context: context);
        Utilidades.imprimir(
            'RESPUESTA PETICION DESTACADO: ${result.toString()}');
        obtieneNotificaciones(mostrarCarga: true);
        if (result['message'] != null) {
          element.setDestacado(value: !flag);
          _notificacionesDisponibles.removeAt(index);
          _notificacionesDisponibles.insert(index, element);
          setState(() {});
        }
      },
      child: Icon(
        element.getDestacado ? Icons.star : Icons.star_border,
        size: 25,
      ),
    );
  }

  /// Método que abre el detalle de una notificación

  Future<void> abreNotificacion(NotificacionModel notificacion) async {
    bool nuevo = !notificacion.getFinalizado;
    await Dialogo.showNativeModalBottomSheet(
        context,
        DetalleNotificacion(
          idCiudadano: null,
          token: null,
          notificacion: notificacion,
          esPreBuzon: false,
        ));
    if (nuevo) obtieneNotificaciones(mostrarCarga: true);
  }

  /// Método que obtiene las notificaciones
  Future<void> obtieneNotificaciones({bool mostrarCarga}) async {
    _seleccionFiltro = valorFiltro;
    _listIdDestacados.clear();
    _limite = _limiteDefault;

    String bandeja = '';
    switch (_seleccionFiltro) {
      case 'Leídos':
        bandeja = '&bandeja=HISTORICOS';
        break;
      case 'Sin leer':
        bandeja = '&bandeja=PENDIENTES';
        break;
    }

    List<NotificacionModel> resultado = new List();
    estadoCarga(mostrarProgreso: true, peticionActiva: mostrarCarga);

    await obtieneDestacados()
        .then((lista) {
          lista.forEach((e) => _listIdDestacados.add(e.toString()));
          _peticionCorrecta = true;
        })
        .then((_) => Sesion.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion:
                '${Constantes.urlNotificacionesBandeja}flujos/pendientes_historico_v1?limit=$_limite&page=$_paginaActual&order=-updateAt$bandeja',
            context: context))
        .then((responseObject) {
          _notificacionesDisponibles.clear();
          if (responseObject.containsKey('finalizado') &&
              responseObject['finalizado']) {
            _total = _seleccionFiltro == _opcionesFiltro[1]['name']
                ? _listIdDestacados.length
                : responseObject['datos']['total'];
            if (_total < _limite && _total != 0) {
              _limite = _total;
            }
            _totalPaginas = (_total / _limite).ceil();
            for (var object in responseObject['datos']['listado']) {
              bool esDestacado = _listIdDestacados.contains(object['_id']);
              resultado.add(new NotificacionModel(
                  id: object['_id'],
                  titulo: object['titulo'] != null ? object['titulo'] : '',
                  institucion: object['institucion'] != null
                      ? object['institucion']
                      : '',
                  updateAt:
                      object['updateAt'] != null ? object['updateAt'] : '',
                  finalizado: object['finalizado'] != null
                      ? object['finalizado']
                      : false,
                  nombreFlujo: object['nombreFlujo'] != null
                      ? object['nombreFlujo']
                      : '',
                  destacado: esDestacado));
              if (_seleccionFiltro == _opcionesFiltro[1]['name'] &&
                  !esDestacado) {
                resultado.removeLast();
              }
            }
            setState(() {
              Utilidades.imprimir("${resultado.length} notificaciones");
              _notificacionesDisponibles = resultado;
            });
          }
        })
        .catchError((onError) {
          Utilidades.imprimir(
              'ERROR OBTENIENDO NOTIFICACIONES: ${onError.toString()}');

          Alertas.showToast(
              mensaje: Utilidades.obtenerMensajeRespuesta(onError),
              danger: true);
          _peticionCorrecta = false;
        })
        .whenComplete(() {
          if (mostrarCarga) estadoCarga(mostrarProgreso: false, peticionActiva: false);
        });
  }

  /// Método que obtiene el identificador de los trámites destacados
  Future<List<dynamic>> obtieneDestacados() async {
    Utilidades.imprimir('Obteniendo destacados....');

    var result = await Sesion.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion:
                '${Constantes.urlNotificacionesConfiguracion}notificaciones/destacados',
            context: context)
        .catchError((onError) {
      _peticionCorrecta = false;
    }).whenComplete(() {
      estadoCarga(mostrarProgreso: false, peticionActiva: false);
    });
    if (result != null && result['destacados'] != null) {
      return result['destacados'];
    }
    return new List();
  }

  String actualizaTextoPaginacion() {
    int i0 = ((_paginaActual - 1) * _limite) + 1;
    int i1 = _paginaActual * _limite;
    if (i1 > _total) i1 = _total;
    return '$i0 - $i1 de $_total';
  }
}
