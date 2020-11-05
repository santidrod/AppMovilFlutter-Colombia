import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';

/// Viste que muestran los puntos de registro por departamento y entidad
class PuntosRegistro extends StatefulWidget {
  /// Identificador de entidad
  final int idEntidad;

  /// Identificador del departamento
  final String departamento;

  PuntosRegistro(this.idEntidad, this.departamento);

  @override
  State<StatefulWidget> createState() => _PuntosRegistroState();
}

class _PuntosRegistroState extends State<PuntosRegistro> {
  /// Identificador del departamento
  String _seleccionDepartamento;

  int _idEntidad;

  _PuntosRegistroState();

  /// Latitud de Bolivia
  double latitudUser = -16.2901535;

  /// longitud de Bolivia
  double longitudUser = -63.5886536;

  /// Control de Mapa
  MapController mapController = MapController();

  /// Objeto openStreetMap
  static FlutterMap flutterMap;

  /// Lista de marcadores
  List<Marker> markers = [];

  /// Niveles zoom el mapa
  double zoom = 5.0;

  /// Entidad seleccionada
  String _seleccionEntidad = '';

  /// Lista de entidad
  List<dynamic> _listaEntidades = [];

  /// Lista de departamentos con latitud y longitud
  List<dynamic> _listaDeparmento = [
    {
      "nombre": "TODOS",
      "latitud": "-16.2901535",
      "longitud": "-63.5886536",
      "zoom": 5.0
    },
    {
      "nombre": "LA PAZ",
      "latitud": "-16.5",
      "longitud": "-68.1500015",
      "zoom": 12.5
    },
    {
      "nombre": "COCHABAMBA",
      "latitud": "-17.414",
      "longitud": "-66.1653",
      "zoom": 12.5
    },
    {
      "nombre": "SANTA CRUZ",
      "latitud": "-17.8146",
      "longitud": "-63.1561",
      "zoom": 12.5
    },
    {
      "nombre": "ORURO",
      "latitud": "-17.9647",
      "longitud": "-67.116",
      "zoom": 12.5
    },
    {
      "nombre": "CHUQUISACA",
      "latitud": "-19.0333195",
      "longitud": "-65.2627411",
      "zoom": 12.5
    },
    {
      "nombre": "TARIJA",
      "latitud": "-21.5214",
      "longitud": "-64.7281",
      "zoom": 12.5
    },
    {
      "nombre": "PANDO",
      "latitud": "-11.0267096",
      "longitud": "-68.7691803",
      "zoom": 12.5
    },
    {
      "nombre": "POTOSI",
      "latitud": "-19.5836115",
      "longitud": "-65.7530594",
      "zoom": 12.5
    },
    {
      "nombre": "BENI",
      "latitud": "-14.8333302",
      "longitud": "-64.9000015",
      "zoom": 12.5
    },
  ];

  /// listado temporal de todas las entidades
  /// List<dynamic> _listaTempEntidad = [];

  @override
  void initState() {
    super.initState();
    _seleccionDepartamento = widget.departamento;
    _idEntidad = widget.idEntidad;
    _obtenerPuntosRegistro(idEntidad: 0, departamento: _seleccionDepartamento);
  }

  /// Método que obtiene puntos de registro
  Future<void> _obtenerPuntosRegistro(
      {int idEntidad, String departamento}) async {
    try {
      String urlPeticion =
          '${Constantes.urlBasePreRegistroEntidadesSucursales}?idEntidad=$idEntidad&departamento=${Uri.encodeFull(departamento)}';
      var data = await Services.peticion(
          tipoPeticion: TipoPeticion.GET, urlPeticion: urlPeticion);
      Utilidades.imprimir("direcciones: $data");

      List<dynamic> direcciones = data["data"]["rows"];

      Utilidades.imprimir("tenemos: ${direcciones.length}");

      var entidadesGobBo = await Services.peticion(
          tipoPeticion: TipoPeticion.GET,
          urlPeticion: '${Constantes.urlGobBoTramites}entidad');

      markers.clear();

      List<Marker> list1 = [];
      if (direcciones.length > 0) {
        _listaEntidades.clear();
        direcciones.forEach((element) {
          list1.add(new Marker(
            width: 220.0,
            height: 145.0,
            point: new LatLng(
              double.parse(element["latitud"]),
              double.parse(element["longitud"]),
            ),
            builder: (ctx) => new Container(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: Colors.white,
                      ),
                      child: Text(
                        element["nombre"],
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                    new Icon(
                      Icons.location_on,
                      color: ColorApp.title,
                    )
                  ],
                ),
              ),
            ),
          ));

          _listaEntidades.add({
            'idEntidad': element['id_entidad'],
            'nombre': '${element['nombre']}',
            'horario': element['horario']
          });
        });
        if (entidadesGobBo['datos'] != null &&
            entidadesGobBo['finalizado'] != null &&
            entidadesGobBo['finalizado']) {
          List<dynamic> listaEntidadesGobBo = entidadesGobBo['datos'];
          _listaEntidades = _listaEntidades.map((element) {
            List<dynamic> entidades = listaEntidadesGobBo
                .where((e) => e["id_entidad"] == element["idEntidad"])
                .toList();
            if (entidades != null &&
                entidades.length == 1 &&
                entidades[0]["sigla"] != null) {
              element["nombre"] =
                  '${entidades[0]["sigla"]} - ${element["nombre"]}';
            }
            return element;
          }).toList();
        }
        if (idEntidad == 0) {
          _seleccionEntidad = _listaEntidades.first['nombre'] ?? '';
        }
      }
      markers = list1;
      setState(() {});
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
      return throw (error);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    flutterMap = new FlutterMap(
      options: new MapOptions(
          center: new LatLng(latitudUser, longitudUser),
          interactive: true,
          zoom: zoom),
      layers: [
        new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            tileProvider: NonCachingNetworkTileProvider()),
        MarkerLayerOptions(markers: markers),
      ],
      mapController: mapController,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: screenWidth * 0.95,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ListTileMoreCustomizable(
                    horizontalTitleGap: 10.0,
                    minVerticalPadding: 0.0,
                    minLeadingWidth: 0.0,
                    leading: Image.asset('assets/images/compass_outline.png',
                        height: 20, width: 20),
                    title: Text('Ciudad', style: TextStyle(fontSize: 10)),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: DropdownButton(
                    isExpanded: true,
                    items: _listaDeparmento
                        .map((dynamic item) => DropdownMenuItem<String>(
                            child: Container(
                              width: 120,
                              child: Text(
                                item["nombre"],
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                            value: item["nombre"]))
                        .toList(),
                    hint: Container(child: Text("Listado de departamentos")),
                    onChanged: (value) {
                      setState(() {
                        _seleccionDepartamento = value;
                        _obtenerPuntosRegistro(
                            idEntidad: _idEntidad,
                            departamento: _seleccionDepartamento);
                        _reubicarMapa(value);
                      });
                    },
                    value: _seleccionDepartamento,
                  ),
                  flex: 2,
                ),
              ],
            ),
          ),
          Container(
            width: screenWidth * 0.95,
            child: Row(
              children: [
                Expanded(
                  child: ListTileMoreCustomizable(
                    horizontalTitleGap: 10.0,
                    minVerticalPadding: 0.0,
                    minLeadingWidth: 0.0,
                    leading: Image.asset('assets/images/building_outine.png',
                        height: 20, width: 20),
                    title: Text('Entidad', style: TextStyle(fontSize: 10)),
                  ),
                  flex: 1,
                ),
                Expanded(
                    child: DropdownButton(
                      isExpanded: true,
                      items: _listaEntidades.length >
                              0
                          ? _listaEntidades
                              .map((dynamic item) => DropdownMenuItem<String>(
                                  child: Container(
                                    child: Text(
                                      item["nombre"],
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  value: item["nombre"]))
                              .toList()
                          : null,
                      hint: Container(
                          child: Text("Lista entidades",
                              style: TextStyle(fontSize: 10))),
                      disabledHint: Text('No hay sucursales...',
                          style: TextStyle(
                            color: ColorApp.greyText,
                            fontSize: 10,
                          )),
                      onChanged: (value) {
                        setState(() {
                          _seleccionEntidad = value;
                          _idEntidad = _getIdEntidad(_seleccionEntidad);
                          _obtenerPuntosRegistro(
                              idEntidad: _idEntidad,
                              departamento: _seleccionDepartamento);
                        });
                      },
                      value: _seleccionEntidad,
                    ),
                    flex: 2),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                flutterMap,
                Positioned(
                  right: 20.0,
                  bottom: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      Utilidades.imprimir("obteniendo ubicación");
                      _getCurrentLocation();
                    },
                    child: Icon(
                      Icons.gps_fixed,
                      color: Theme.of(context).primaryColor,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 20.0,
                  child: Column(
                    children: [
                      InkWell(
                          onTap: () {
                            _setZoom(0.5);
                          },
                          child:
                              Image.asset('assets/images/icon_zoom_plus.png')),
                      SizedBox(height: 10),
                      InkWell(
                          onTap: () {
                            _setZoom(-0.5);
                          },
                          child:
                              Image.asset('assets/images/icon_zoom_minus.png')),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }

  /// Método que obtiene posición actual
  Future<void> _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 5))
        .then((Position position) async {
      Utilidades.imprimir("Ubicación obtenida📍: $position");
      latitudUser = position.latitude;
      longitudUser = position.longitude;
      zoom = 16.0;
      mapController.move(LatLng(position.latitude, position.longitude), zoom);
    }).catchError((e) {
      Utilidades.imprimir("Error al obtener la ubicación 📍: $e");
    });
  }

  /// Método que ajusta el zoom del mapa
  void _setZoom(double delta) {
    zoom += delta;
    mapController.move(mapController.center, zoom);
  }

  int _getIdEntidad(String nombreEntidad) {
    var elemento = _listaEntidades
        .where((element) =>
            element['nombre'].toString().compareTo(nombreEntidad) == 0)
        .first;
    return elemento['idEntidad'];
  }

  /// Método que reubica el mapa
  void _reubicarMapa(String departamento) {
    var objDepartamento = _listaDeparmento
        .where((element) =>
            element['nombre'].toString().compareTo(departamento) == 0)
        .first;
    Utilidades.imprimir('cambiando posicion a ${objDepartamento.toString()}');
    setState(() {
      zoom = double.parse(objDepartamento['zoom'].toString());
      mapController.move(
          LatLng(double.parse(objDepartamento['latitud'].toString()),
              double.parse(objDepartamento['longitud'].toString())),
          zoom);
    });
  }
}
