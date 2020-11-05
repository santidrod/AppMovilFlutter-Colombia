import 'package:ciudadaniadigital/pages/autoregistro/widgets/mapaPuntosRegistro.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

/// Vista que muestra pasos para terminar el registro presencial
class FinalizadoVista extends StatefulWidget {
  @override
  _FinalizadoVistaState createState() => _FinalizadoVistaState();
}

class _FinalizadoVistaState extends State<FinalizadoVista> {
  /// latitud Bolivia
  double latitudUser = -16.2901535;

  /// longitud Bolivia
  double longitudUser = -63.5886536;

  /// Controlador de Mapas
  MapController mapController = MapController();

  /// Instancia de OpenStreetMap
  static FlutterMap flutterMap;

  /// Lista de marcadores
  List<Marker> markers = [];

  /// Nivel de Zoom
  double zoom = 5.0;
  int _idEntidad = 0;

  /// selector de de
  String _seleccionDepartamento = 'TODOS';

  /// Lista de entidades
  List<dynamic> _listaEntidades = [];

  @override
  void initState() {
    super.initState();
    _obtenerPuntosRegistro(idEntidad: 0, departamento: 'TODOS');
  }

  @override
  Widget build(BuildContext context) {
    flutterMap = new FlutterMap(
      options: new MapOptions(center: new LatLng(latitudUser, longitudUser), interactive: false, zoom: zoom),
      layers: [
        new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            tileProvider: NonCachingNetworkTileProvider()),
        MarkerLayerOptions(markers: markers),
      ],
      mapController: mapController,
    );

    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(top: 5, bottom: 0, left: 40, right: 40),
          child: Text(
            "Aproxímate a las oficinas de una entidad de registro de ciudadanía digital, llevando tu cédula de identidad vigente. Un operador de registro tomará una fotografía tuya y hará lectura de tu huella digital.",
            style: TextStyle(fontSize: 12),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(top: 5, bottom: 20, left: 30, right: 30),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                onTap: () {
                  Utilidades.imprimir("click");
                },
                leading: Image.asset(
                  'assets/images/icon_home.png',
                  height: 30,
                ),
                title: Text(
                  "En el mapa podrás encontrar las oficinas de registro de ciudadanía digital a las que puedes ir",
                  maxLines: 6,
                  style: TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.w300),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                onTap: () {
                  Utilidades.imprimir("click");
                },
                leading: Image.asset(
                  'assets/images/icon_id.png',
                  height: 25,
                ),
                title: Text(
                  "Solo necesitas presentar tu cédula de identidad con el operador para finalizar tu registro",
                  maxLines: 4,
                  style: TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.w300),
                ),
                subtitle: Text(
                  "¡No necesitas fotocopia!",
                  style: TextStyle(fontSize: 10.0, color: Colors.black, fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 5),
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Toque el mapa para visualizar en pantalla completa ',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ),
              Image.asset('assets/images/arrow_expand_all.png', width: 20, height: 20)
            ],
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            await Dialogo.showNativeModalBottomSheet(context, PuntosRegistro(_idEntidad, _seleccionDepartamento));
          },
          child: Container(
            height: 300,
            child: Stack(
              children: [
                flutterMap,
                Positioned(
                  bottom: 10,
                  right: 20.0,
                  child: FloatingActionButton(
                    onPressed: () async {
                      await Dialogo.showNativeModalBottomSheet(context, PuntosRegistro(_idEntidad, _seleccionDepartamento));
                    },
                    child: Icon(
                      Icons.open_with,
                      color: Theme.of(context).primaryColor,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }

  /// Método de obtiene puntos de registro
  Future<void> _obtenerPuntosRegistro({int idEntidad, String departamento}) async {
    try {
      String urlPeticion =
          '${Constantes.urlBasePreRegistroEntidadesSucursales}?idEntidad=$idEntidad&departamento=${Uri.encodeFull(departamento)}';
      var data = await Services.peticion(tipoPeticion: TipoPeticion.GET, urlPeticion: urlPeticion);
      Utilidades.imprimir("direcciones: $data");

      List<dynamic> direcciones = data["data"]["rows"];

      Utilidades.imprimir("tenemos: ${direcciones.length}");

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

          _listaEntidades.add({'idEntidad': element['id_entidad'], 'nombre': element['nombre'], 'horario': element['horario']});
        });
      }
      markers = list1;
      setState(() {});
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
      return throw (error);
    }
  }
}
