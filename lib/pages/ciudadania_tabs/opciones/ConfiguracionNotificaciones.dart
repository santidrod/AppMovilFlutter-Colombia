import 'dart:async';

import 'package:ciudadaniadigital/models/EntidadTramiteModel.dart';
import 'package:ciudadaniadigital/models/TramiteModel.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

/// Vista que muestra la configuración de notificaciones de trámites

class ConfiguracionNotificaciones extends StatefulWidget {
  ConfiguracionNotificaciones({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfiguracionNotificaciones();
}

/// Clase que contiene un temporizador

class Debouncer {
  /// Tiempo en milisegundos
  final int milliseconds;

  /// Acción a ejecutar
  VoidCallback action;

  /// Temporizador
  Timer _timer;

  Debouncer({this.milliseconds});

  /// Método que ejecuta una acción cuando termina el tiempo
  void run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class IdentificadorTramites {
  int _idEntidad;
  bool _visible;

  IdentificadorTramites({
    int idEntidad,
    bool visible,
  })  : _idEntidad = idEntidad,
        _visible = visible;
}

class _ConfiguracionNotificaciones extends State<ConfiguracionNotificaciones> {
  /// temporizador de 1000 milisegundos
  final debouncer = Debouncer(milliseconds: 1000);

  _ConfiguracionNotificaciones();

  /// Controlador del campo de texto que filtra las notificaciones
  TextEditingController _searchController = TextEditingController();

  /// Lista de entidades
  List<SeccionEntidadTramite> _listado =
      new List(); // representacion de array simple entidad|lista tramites para visualizar
  /// Lista de trámites
  List<EntidadTramiteModel> _listaModel = new List(); // array de datos filtrado
  /// Lista de entidades temporal
  List<EntidadTramiteModel> _listaModelBckp =
      new List(); // backup array de datos (para no llamar varias veces la API)

  /// Indicador de carga de la aplicación
  bool _cargando = false;

  bool _estadoMostrarHabilitados = false;

  List<IdentificadorTramites> _identificadorTramites = new List();

  /// Indicador de petición correcta
  bool _peticionCorrecta = true;

  /// Posición inicial del filtro de trámites habilitados
  int _flagHabilitados = 0;

  @override
  void initState() {
    super.initState();
    obtenerEntidadesTramite();
  }

  /// Método que cambia en estado del indicador de carga
  void estadoCarga() {
    if (mounted)
      setState(() {
        _cargando = !_cargando;
      });
  }

  /// Método que obtiene la lista de entidades y trámites
  Future obtenerEntidadesTramite() async {
    // _listado = new List();
    _listaModel = new List();

    estadoCarga();

    await Sesion.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion: '${Constantes.urlNotificacionesConfiguracion}tramites',
            context: context)
        .then((response) {
      response['datos'].forEach((entidad) {
        List<TramiteModel> listaTramites = new List();
        bool todosAutorizados = true;
        entidad['tramites'].forEach((tramite) {
          TramiteModel tramiteModel = new TramiteModel(
              idTramite: int.parse(tramite['id'].toString()),
              codigoTramite: int.parse(tramite['codigo'].toString()),
              descripcionTramite: tramite['descripcion'] ?? '',
              obligatorio: tramite['obligatorio'] ?? false,
              validado: tramite['validado'] ?? false,
              autorizado: tramite['autorizado'] ?? false);
          if (tramiteModel.obligatorio) tramiteModel.autorizado = true;
          if (!tramiteModel.getAutorizado) todosAutorizados = false;
          listaTramites.add(tramiteModel);
        });
        _listaModel.add(new EntidadTramiteModel(
            idEntidad: int.parse(entidad['id'].toString()),
            nombreEntidad: entidad['nombre'],
            descripcion: entidad['descripcion'] ?? '',
            sigla: entidad['sigla'] ?? '',
            direccion: entidad['direccion'] ?? '',
            estado: entidad['estado'],
            codigoPortal: int.parse(entidad['codigo_portal'].toString()),
            autorizado: todosAutorizados,
            tramites: listaTramites));
      });
      // aplanando listas anidadas
      _listado = castFromListModel(_listaModel);
      _listaModelBckp = _listaModel.toList(); // copia sin referencias
      if (mounted) setState(() {});
    }).catchError((onError) {
      _peticionCorrecta = false;
      Utilidades.imprimir("Error: $onError ");
      Alertas.showToast(
          mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true);
    }).whenComplete(() {
      estadoCarga();
    });
  }

  // Método que convierte el array anidado de Entidades y tramites asociados en una lista plana
  List<SeccionEntidadTramite> castFromListModel(
      List<EntidadTramiteModel> lista) {
    return lista.expand<SeccionEntidadTramite>((entidadTramite) {
      return [
        EntidadRow(
            nombreEntidad: entidadTramite.nombreEntidad,
            autorizado: entidadTramite.getAutorizado,
            idEntidad: entidadTramite.idEntidad),
        ...entidadTramite.getTramites.map((tramite) => TramiteRow(
            nombreTramite: tramite.descripcionTramite,
            autorizado: tramite.getAutorizado,
            obligatorio: tramite.obligatorio,
            codigoPortal: tramite.codigoTramite,
            idEntidad: entidadTramite.idEntidad))
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          child: Column(
            children: [
              Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Lista de trámites disponibles",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          "${_listado.length} trámites ${_estadoMostrarHabilitados ? "habilitados" : "disponibles"}",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w200),
                        ),
                      )
                    ],
                  )),
              busquedaTramite(),
              if (!_peticionCorrecta)
                Card(
                    margin: EdgeInsets.only(
                        bottom: 10, left: 30, right: 30, top: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    color: ColorApp.greyLightText,
                    shadowColor: Colors.transparent,
                    child: ListTile(
                        contentPadding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        title: Text(
                          "Error al obtener las configuraciones 🚨",
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: ColorApp.blackText,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ))),
              SizedBox(height: 20),
              Container(
                child: Visibility(
                  visible: _cargando,
                  child: Elementos.indicadorProgresoLineal(),
                ),
              ),
              lista(screenSize)
            ],
          ),
        ),
      ),
    );
  }

  /// Widget que contiene la lista de trámites ordenadas por sección

  Widget lista(Size screenSize) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _listado.length,
        itemBuilder: (BuildContext context, int index) {
          return row(_listado[index], screenSize);
        },
      ),
    );
  }

  /// Widget que contiene un item de la lista de entidades y trámites
  Widget row(SeccionEntidadTramite entidadTramite, Size screenSize) {
    if (entidadTramite is EntidadRow) {
      if (_identificadorTramites
              .where(
                  (element) => element._idEntidad == entidadTramite.idEntidad)
              .toList()
              .length ==
          0) {
        _identificadorTramites.add(new IdentificadorTramites(
            idEntidad: entidadTramite.idEntidad, visible: true));
      }
    }

    return Card(
        //margin: EdgeInsets.only(bottom: 10, left: 0, right: 0, top: 10),
        color: ColorApp.listFillCell,
        shadowColor: Colors.transparent,
        child: Column(
          children: [
            if (entidadTramite is EntidadRow)
              widgetEntidad(entidadTramite, screenSize),
            if (entidadTramite is TramiteRow) widgetTramite(entidadTramite),
          ],
        ));
  }

  /// Widget que contiene un item para modificar las notificaciones de trámites de una entidad
  Widget widgetEntidad(EntidadRow entidad, Size screenSize) {
    List<IdentificadorTramites> list = _identificadorTramites
        .where((element) => element._idEntidad == entidad.idEntidad)
        .toList();
    double cWidth = MediaQuery.of(context).size.width * 0.3;
    return Container(
      padding: EdgeInsets.only(left: 0, right: 0),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
                child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _identificadorTramites.forEach((element) {
                        if (element._idEntidad == entidad.idEntidad) {
                          element._visible = !element._visible;
                        }
                      });
                    });
                  },
                  icon: Icon(
                      list.elementAt(0)._visible ? Icons.remove : Icons.add),
                ),
                Container(
                  width: cWidth,
                  child: Text(
                    Utilidades.capitalize(entidad.nombreEntidad),
                    style: TextStyle(
                        color: ColorApp.greyText,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                )
              ],
            )),
          ),
          SizedBox(
            width: 10,
          ),
          Row(
            children: [
              Text(
                entidad.autorizado ? "Habilitado" : "Deshabilitado",
                style: TextStyle(fontSize: 12),
              ),
              Elementos.switchNativo(
                  value: entidad.autorizado,
                  onChanged: (bool value) async {
                    Dialogo.mostrarDialogoPersonalizado(
                        context,
                        entidad,
                        () async => {
                              entidad.autorizado = await cambiarEstadoEntidad(
                                  idEntidad: entidad.idEntidad,
                                  nuevoEstado: value),
                              Navigator.of(context).pop()
                            },
                        null);
                  },
                  activeColor: ColorApp.colorGreen)
            ],
          )
        ],
      ),
    );
  }

  /// Widget que contiene un item para modificar la notificación de un trémite
  Widget widgetTramite(TramiteRow tramite) {
    List<IdentificadorTramites> list = _identificadorTramites
        .where((element) => element._idEntidad == tramite.idEntidad)
        .toList();
    if (list.elementAt(0)._visible) {
      return Card(
          // margin: EdgeInsets.only(bottom: 0, left: 10, right: 10, top: 0),
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          //color: ColorApp.listFillCell,
          color: Colors.white,
          margin: EdgeInsets.all(0),
          shadowColor: Colors.transparent,
          child: ListTile(
            contentPadding:
                EdgeInsets.only(/*top: 10, bottom: 10, */ left: 20, right: 0),
            dense: true,
            trailing: Elementos.switchNativo(
              value: tramite.autorizado,
              onChanged: (bool value) async {
                if (tramite.obligatorio) {
                  Alertas.showToast(
                      mensaje:
                          'Este trámite es de notificación obligatoria, no es posible deshabilitarlo',
                      danger: true);
                  return;
                }
                Dialogo.mostrarDialogoPersonalizado(context, null, () async {
                  tramite.autorizado = await cambiarEstadoTramites(
                      codigoTramite: tramite.codigoPortal, nuevoEstado: value);
                  Navigator.of(context).pop();
                }, tramite);
              },
              activeColor:
                  tramite.obligatorio ? ColorApp.alert : ColorApp.colorGreen,
            ),
            title: Text(
              Utilidades.capitalize(tramite.nombreTramite),
              maxLines: 5,
              style: TextStyle(
                  fontSize: 12.0,
                  color: ColorApp.greyText,
                  fontWeight: FontWeight.w500),
            ),
          ));
    }
    return Container(
      height: 0,
      child: null,
    );
  }

  /// Widget que contiene un Filtro de notificaciones habilitadas

  Widget botonesFiltro(Size screenSize) {
    Map<int, Widget> _children = {0: Text('Habilitados'), 1: Text('Todos')};

    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      width: 300,
      height: 60,
      child: MaterialSegmentedControl(
        children: _children,
        selectionIndex: _flagHabilitados,
        borderColor: Colors.grey,
        selectedColor: ColorApp.btnBackground,
        unselectedColor: Colors.white,
        borderRadius: 5.0,
        onSegmentChosen: (index) {
          setState(() {
            _flagHabilitados = index;
          });
        },
      ),
    );
  }

  /// Widget que contiene el campo de texto que filtra las notificaciones
  ///
  Widget busquedaTramite() {
    return Container(
      color: ColorApp.greyLightText,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                height: 1,
              ),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(15.0),
                  hintText: 'Escriba aquí para buscar un trámite o Entidad',
                  hintStyle:
                      TextStyle(fontStyle: FontStyle.normal, fontSize: 12),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.length > 0
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _listaModel = _listaModelBckp.toList();
                            _listado = castFromListModel(_listaModel);
                            _searchController.text = '';
                            setState(() {});
                          },
                        )
                      : null),
              onChanged: (filter) {
                if (filter.length > 0) {
                  debouncer.run(() async {
                    _listado = filterList(filter);
                    setState(() {});
                  });
                }
              },
              onSubmitted: (value) {
                _listado = filterList(value);
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Row(children: [
              Checkbox(
                value: _estadoMostrarHabilitados,
                activeColor: ColorApp.primary,
                onChanged: (bool state) {
                  setState(() {
                    _estadoMostrarHabilitados = state;
                    if (state) {
                      _listado = filterListByState();
                    } else {
                      _listaModel = _listaModelBckp.toList();
                      _listado = castFromListModel(_listaModel);
                    }
                    setState(() {});
                  });
                },
              ),
              Text(
                "Mostrar solo habilitados",
                style: TextStyle(
                    color: ColorApp.greyText, fontWeight: FontWeight.w200),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /// Función que filtra las notificaciones con una palabra clave

  List<SeccionEntidadTramite> filterList(String filtro) {
    filtro = filtro.toLowerCase();
    Utilidades.imprimir('filtrando $filtro...');
    List<EntidadTramiteModel> filtrado = new List();
    Utilidades.imprimir("listadolistado: ${_listaModel.length}");
    _listaModel.forEach((entidadTramites) {
      List<TramiteModel> listTramite = new List();
      bool coincide = false;
      entidadTramites.getTramites.forEach((tramite) {
        //if (_flagHabilitados == 0) {
        if (tramite.descripcionTramite.toLowerCase().contains(filtro) &&
            (tramite.getAutorizado || tramite.obligatorio) &&
            entidadTramites.nombreEntidad.toLowerCase().contains(filtro)) {
          listTramite.add(tramite);
          coincide = true;
        }
        //} else {
        if (tramite.descripcionTramite.toLowerCase().contains(filtro) ||
            entidadTramites.nombreEntidad.toLowerCase().contains(filtro)) {
          listTramite.add(tramite);
          coincide = true;
        }
        //}
      });
      if (coincide) {
        entidadTramites.tramites = listTramite;
        filtrado.add(entidadTramites);
      }
    });
    return castFromListModel(filtrado);
  }

  /// Filtrar solo Habilitados
  List<SeccionEntidadTramite> filterListByState() {
    List<EntidadTramiteModel> filtrado = new List();
    _listaModel.forEach((entidadTramites) {
      List<TramiteModel> listTramite = new List();
      bool coincide = false;
      entidadTramites.getTramites.forEach((tramite) {
        if (_flagHabilitados == 0) {
          if (tramite.getAutorizado) {
            listTramite.add(tramite);
            coincide = true;
          }
        } else {
          if (tramite.getAutorizado || entidadTramites.getAutorizado) {
            listTramite.add(tramite);
            coincide = true;
          }
        }
      });
      if (coincide) {
        entidadTramites.tramites = listTramite;
        filtrado.add(entidadTramites);
      }
    });
    return castFromListModel(filtrado);
  }

  /// Función que crea un arreglo de trámites

  List<dynamic> arrayObjetoTramite({List<int> codigos, bool value}) {
    return codigos
        .map((e) => {'codigo_portal': e.toString(), 'autorizacion': value})
        .toList();
  }

  /// Método que cambia el estado de un trámite haciendo una petición
  Future<bool> cambiarEstadoTramites(
      {@required bool nuevoEstado,
      int codigoTramite,
      List<int> codigos}) async {
    bool returnValue;

    List<dynamic> arrayTramites;
    if (codigoTramite == null) {
      arrayTramites = arrayObjetoTramite(codigos: codigos, value: nuevoEstado);
    } else {
      arrayTramites =
          arrayObjetoTramite(codigos: [codigoTramite], value: nuevoEstado);
    }
    if (arrayTramites.length > 0) {
      Map<String, dynamic> bodyParams = {'tramites': arrayTramites};

      try {
        var resultado = await Sesion.peticion(
          tipoPeticion: TipoPeticion.POST,
          urlPeticion:
              '${Constantes.urlNotificacionesConfiguracion}configuracion',
          context: context,
          bodyparams: bodyParams,
        );
        if (resultado['finalizado']) {
          returnValue = nuevoEstado;
        } else {
          returnValue = !nuevoEstado;
        }
      } catch (e) {
        Alertas.showToast(mensaje: e.toString(), danger: true);
        returnValue = !nuevoEstado;
      } finally {
        if (returnValue == nuevoEstado) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            obtenerEntidadesTramite();
          });
        }
      }
    } else {
      returnValue = !nuevoEstado;
    }
    return returnValue;
  }

  /// Método que cambia el estado de los trámites de una entidad
  Future<bool> cambiarEstadoEntidad({int idEntidad, bool nuevoEstado}) async {
    bool estadoActualizado = await cambiarEstadoTramites(
        codigos: obtenerIdsTramite(idEntidad: idEntidad, newValue: nuevoEstado),
        nuevoEstado: nuevoEstado);
    return estadoActualizado;
  }

  /// Método que ordena los trámites de una entidad
  List<int> obtenerIdsTramite({int idEntidad, bool newValue}) {
    List<int> lista = new List();
    _listaModelBckp.forEach((entidadTramite) {
      if (entidadTramite.idEntidad == idEntidad) {
        entidadTramite.getTramites.forEach((tramite) {
          if (!tramite.obligatorio && tramite.getAutorizado != newValue) {
            lista.add(tramite.codigoTramite);
          }
        });
      }
    });
    return lista;
  }

/*void actualizaEstadosTramites(int idEntidad, bool estado) {
    _listaModelBckp.map((entidadTramite) {
      if (entidadTramite.idEntidad == idEntidad) {
        entidadTramite.tramites = entidadTramite.getTramites.map((tramite) {
          if (!tramite.obligatorio && tramite.getAutorizado != estado) {
            tramite.autorizado = estado;
          }
          return tramite;
        }).toList();
      }
      return entidadTramite;
    });
    _listado.map((seccion) {
      if (seccion is TramiteRow && !seccion.obligatorio && seccion.autorizado != estado) {
        seccion.autorizado = estado;
      }
      return seccion;
    });
    setState(() { });
  }*/
}

/// Clase abstracta que contiene las propiedades de una entidad y un trámite
abstract class SeccionEntidadTramite {}

/// Clase que contiene las propiedades de una entidad
class EntidadRow implements SeccionEntidadTramite {
  EntidadRow({this.nombreEntidad, this.autorizado, this.idEntidad});

  final int idEntidad;
  final String nombreEntidad;
  bool autorizado;
}

/// Clase que contiene las propiedades de un trámite
class TramiteRow implements SeccionEntidadTramite {
  TramiteRow(
      {this.nombreTramite,
      this.autorizado,
      this.obligatorio,
      this.codigoPortal,
      this.idEntidad});

  final String nombreTramite;
  final int idEntidad;
  bool autorizado;
  bool obligatorio;
  int codigoPortal;
}
