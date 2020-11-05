import 'dart:async';

import 'package:ciudadaniadigital/models/MarcadorModel.dart';
import 'package:ciudadaniadigital/models/MarcadorModelAccess.dart';
import 'package:ciudadaniadigital/pages/BuscadorTramites/detalle_tramite.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';

/// Vista que muestra una vista de busqueda de información de trámites del estado (gob.bo)

class BuscadorTramites extends StatefulWidget {
  BuscadorTramites() : super();

  @override
  State<StatefulWidget> createState() => _BuscadorTramites();
}

class _BuscadorTramites extends State<BuscadorTramites> {
  /// Controlador del campo de busqueda
  TextEditingController _searchController = TextEditingController();

  /// Lista de resultados
  List<dynamic> listTramiteData;

  /// Cantidad de resultados
  int _cantidadResultados;

  /// Página actual de la petición
  int _paginaActual;

  /// Tiempo en el que se hizo la busqueda
  double _tiempo;

  /// Trámite seleccionado
  dynamic tramite;

  /// Modelo de datos en almacenamiento seguro
  MarcadorModelAccess _marcadorModelAccess;

  /// controlador del scroll
  ScrollController _scrollController = new ScrollController();

  /// Indicador de petición activa
  bool _peticionActiva = false;

  @override
  void initState() {
    super.initState();

    inicializar();
    initBookmark();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ++_paginaActual;
        buscarTramites(isScrolling: true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _searchController.dispose();
  }

  /// Método que inicia el almacenamiento seguro y obtiene los registros guardados
  Future<void> initBookmark() async {
    _marcadorModelAccess = new MarcadorModelAccess();
    await _marcadorModelAccess.getAll();
    setState(() {});
  }

  /// Método que inicia las variables
  void inicializar() {
    tramite = null;

    _paginaActual = 1;
    _cantidadResultados = 0;
    _tiempo = 0.0;
    listTramiteData = new List();
  }

  /// Widget que muestra la lista de trámites

  Widget list() {
    return listTramiteData.length != 0
        ? ListView.builder(
            controller: _scrollController,
            itemCount: listTramiteData.length,
            itemBuilder: (BuildContext context, int index) {
              return row(index);
            },
          )
        : Center(child: Text("No se encontraron trámites"));
  }

  /// Método que abre el detalle de un trámite
  void mostrarInfoTramite(String idTramite) async {
    await Dialogo.showNativeModalBottomSheet(
        context,
        DetalleTramite(
          idTramite: idTramite,
        )).then((value) => initBookmark());
  }

  /// Item de la lista de trámites
  Widget row(int index) {
    return Card(
        margin: EdgeInsets.only(bottom: 10, left: 30, right: 30, top: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: ColorApp.listFillCell,
        shadowColor: Colors.transparent,
        child: ListTileMoreCustomizable(
          contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 5),
          horizontalTitleGap: 0.0,
          minVerticalPadding: 20.0,
          minLeadingWidth: 0.0,
          onTap: (details) async {
            // openDetailMobile(contacts[index]);
            Utilidades.imprimir("mostraremos ID: ${listTramiteData[index]['id']}");
            mostrarInfoTramite(listTramiteData[index]['id']);
          },
          title: Text(
            '${listTramiteData[index]['titulo']}',
            style: TextStyle(fontSize: 14.0, color: ColorApp.blackText, fontWeight: FontWeight.w700),
          ),
          subtitle: Column(
            children: [
              SizedBox(height: 10),
              Text(
                '${listTramiteData[index]['entidad']}',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(Utilidades.capitalize('${listTramiteData[index]['descripcion']}'),
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300)),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        centerTitle: false,
        title: Text("Gob.bo",
            style: TextStyle(fontSize: 16.0, color: ColorApp.btnBackground, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              child: Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(
                              10.0,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white60,
                        contentPadding: EdgeInsets.all(10.0),
                        hintText: '¿Qué trámite estás buscando?',
                        hintStyle: TextStyle(fontSize: 11),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.text = '';
                            inicializar();
                            setState(() {});
                          },
                        )),
                    onFieldSubmitted: (action) {
                      if (_searchController.text.isEmpty) {
                        Alertas.showToast(mensaje: 'Debes introducir términos de búsqueda', danger: true);
                        return;
                      }
                      inicializar();
                      buscarTramites();
                    },
                  ),
                ),
              ),
            ),
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Image(
                  image: AssetImage(
                    'assets/images/tramites/search.png',
                  ),
                  height: 30,
                ),
              ),
              onTap: () {
                if (_searchController.text.isEmpty) {
                  Alertas.showToast(mensaje: 'Debes introducir términos de búsqueda', danger: true);
                  return;
                }
                inicializar();
                buscarTramites();
              },
            ),
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 10),
                child: Image(
                  image: AssetImage('assets/images/tramites/pin_verde.png'),
                  color: (_marcadorModelAccess.length() > 0) ? Colors.lightGreen : ColorApp.greyBackground,
                  height: 30,
                ),
              ),
              onTap: () {
                if (_marcadorModelAccess.length() > 0) {
                  _showBookmarkDialog(context);
                } else {
                  Alertas.showToast(mensaje: 'No existen trámites guardados', danger: true);
                }
              },
            ),
          ],
        ),
        if (listTramiteData.length > 0)
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                child: Text(
                  _cantidadResultados == 0
                      ? 'No se encontraron resultados'
                      : _cantidadResultados == 1
                          ? 'Se encontro $_cantidadResultados resultado en $_tiempo segundos'
                          : 'Se encontraron $_cantidadResultados resultados en $_tiempo segundos',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
                ),
              ))
        else
          SizedBox(
            height: 20,
          ),
        cuerpo()
      ]),
    );
  }

  /// Método que reinicia las variables y busca trámites
  Future recargarLista() async {
    inicializar();
    buscarTramites();
  }

  /// Widget que muestra un indicador de recarga antes de la lista
  Widget cuerpo() {
    return Container(
        child: Expanded(
      child: RefreshIndicator(onRefresh: recargarLista, child: list()),
    ));
  }

  /// Método que hace la busqueda haciendo una petición a gob.bo

  Future<void> buscarTramites({bool isScrolling = false}) async {
    setState(() {
      _peticionActiva = true;
    });
    FocusScope.of(context).unfocus();

    await Services.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion:
                '${Constantes.urlGobBoTramites}busqueda?palabras=${_searchController.text.trim()}&page=${_paginaActual.toString()}')
        .then((responseObject) {
          if (responseObject.containsKey('finalizado') && responseObject['finalizado']) {
            List<dynamic> listaResultados = new List();
            Map<String, dynamic> resultado = new Map();

            resultado['totalPaginas'] = responseObject['datos']['totalPaginas'];
            resultado['count'] = responseObject['datos']['resultadoResumen']['count'];
            resultado['time'] = responseObject['datos']['resultadoResumen']['time'];
            for (var object in responseObject['datos']['tramites']) {
              listaResultados.add(<String, String>{
                'id': object['id'].toString(),
                'titulo': object['titulo'],
                'entidad': '${object['entidadSigla']} - ${object['entidadNombre']}',
                'descripcion': object['descripcion']
              });
            }
            resultado['tramites'] = listaResultados;

            if (isScrolling && resultado['totalPaginas'] != null) {
              setState(() {
                _scrollController.animateTo(_scrollController.position.pixels + 100,
                    curve: Curves.fastOutSlowIn, duration: Duration(milliseconds: 250));
              });
            }

            if (resultado['totalPaginas'] != null) {
              setState(() {
                listTramiteData.addAll(resultado['tramites']);
                _cantidadResultados = resultado['count'];
                _tiempo = resultado['time'];
              });
            }
          }
        })
        .catchError((onError) => {Alertas.showToast(mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true)})
        .whenComplete(() => {_peticionActiva = false});
  }

  /// Método que muestra el progreso de una petición
  Widget cargandoDatos() {
    if (_peticionActiva) {
      return Center(
        child: Elementos.indicadorProgresoCircularNativo(),
      );
    } else {
      return Container();
    }
  }

  /// Método que muestra la lista de trámites almacenados en local

  void _showBookmarkDialog(BuildContext context) {
    showDialog(context: context, barrierDismissible: true, builder: (_) => ListBookmark(_marcadorModelAccess)).then(
        (idTramite) => idTramite != null ? mostrarInfoTramite(idTramite) : {Utilidades.imprimir('se obtuvo id NULL'), initBookmark()});
  }
}

/// Vista que muestra la lista de marcadores almacenados en local

class ListBookmark extends StatefulWidget {
  /// Módelo de datos de trámites en local
  final _tramiteModelAccess;

  ListBookmark(this._tramiteModelAccess);

  @override
  State<StatefulWidget> createState() => new _ListBookmark();
}

class _ListBookmark extends State<ListBookmark> {
  /// Médidas del dialogo
  final _dialogHeights = [0.0, 0.20, 0.40, 0.60, 0.70];

  _ListBookmark();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      title: Text('Trámites guardados'),
      content: listBookmark(screenSize),
      actions: <Widget>[
        FlatButton(
          child: Text('Cerrar'),
          onPressed: () => cerrarModal(context, null),
        ),
      ],
    );
  }

  /// Lista de marcadores almacenados en local
  Widget listBookmark(Size screenSize) {
    double heightFactor = widget._tramiteModelAccess.length() < 4
        ? _dialogHeights[widget._tramiteModelAccess.length()]
        : _dialogHeights[_dialogHeights.length - 1];
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: screenSize.height * heightFactor,
            width: screenSize.width * 0.85,
            child: ListView.builder(
              itemCount: widget._tramiteModelAccess.length(),
              itemBuilder: (BuildContext context, int index) {
                return rowBookmark(widget._tramiteModelAccess.getByPosition(index));
              },
            ),
          )
        ],
      ),
    );
  }

  /// Item de trámite almacenado en local

  Widget rowBookmark(MarcadorModel bookmark) {
    return Card(
        clipBehavior: Clip.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: ColorApp.greyLightText,
        shadowColor: Colors.transparent,
        child: ListTile(
            contentPadding: EdgeInsets.all(5),
            onTap: () {
              // mostrar tramite seleccionado
              cerrarModal(context, bookmark.idTramite);
              // obtenerTramite(bookmark.idTramite);
            },
            title: Text(
              bookmark.titulo,
              style: TextStyle(fontSize: 12.0, color: ColorApp.blackText, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              bookmark.sigla,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
            leading: Image(
              image: AssetImage('assets/images/tramites/bookmark.png'),
              height: 35,
            ),
            trailing: InkWell(
              child: Image(
                image: AssetImage('assets/images/tramites/borrar.png'),
                height: 35,
              ),
              onTap: () async {
                widget._tramiteModelAccess.deleteById(bookmark.idTramite);
                await widget._tramiteModelAccess.save();
                setState(() {});
                if (widget._tramiteModelAccess.length() == 0) {
                  Navigator.pop(context);
                }
              },
            )));
  }

  /// Método que cierra la vista del detalle del trámite
  void cerrarModal(BuildContext context, String idTramite) {
    Navigator.of(context).pop(idTramite);
  }
}
