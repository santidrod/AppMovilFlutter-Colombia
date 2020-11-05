import 'package:ciudadaniadigital/models/MarcadorModel.dart';
import 'package:ciudadaniadigital/models/MarcadorModelAccess.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// Viste que muestran detalles de un trámite
class DetalleTramite extends StatefulWidget {
  /// Identificador del trámite
  final String idTramite;

  const DetalleTramite({Key key, this.idTramite}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DetalleTramiteState();
  }
}

class _DetalleTramiteState extends State<DetalleTramite> {
  /// Indicador de petición activa
  bool _peticionActiva = false;

  /// Modelo de datos de trámite
  MarcadorModelAccess _marcadorModelAccess;

  /// Información del trámite seleccionado
  dynamic tramite;

  @override
  void initState() {
    super.initState();
    initBookmark().then((value) => {obtenerTramite(widget.idTramite)});
  }

  /// Inicializados de modelo de datos
  Future<void> initBookmark() async {
    _marcadorModelAccess = new MarcadorModelAccess();
    await _marcadorModelAccess.getAll();
  }

  /// método que obtiene la información del trámite a través de una petición web
  Future<void> obtenerTramite(String idTramite) async {
    _peticionActiva = true;
    setState(() {});
    FocusScope.of(context).unfocus();

    Utilidades.imprimir("buscando trámite $idTramite");

    await Services.peticion(tipoPeticion: TipoPeticion.GET, urlPeticion: '${Constantes.urlGobBoTramites}tramite/$idTramite')
        .then((responseObject) {
          setState(() {
            tramite = procesar(responseObject, idTramite);
          });
        })
        .catchError((onError) => {Alertas.showToast(mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true)})
        .whenComplete(() => {_peticionActiva = false});
  }

  /// Método que procesa la respuesta de la petición para mostrarlo en la interfaz
  dynamic procesar(responseObject, idTramite) {
    dynamic resultado = {};
    Utilidades.imprimir("procesando... : $responseObject");
    if (responseObject.containsKey('finalizado') && responseObject['finalizado']) {
      resultado['idTramite'] = idTramite;
      resultado['titulo'] = responseObject['datos']['titulo'];
      resultado['fecha_modificacion'] = responseObject['datos']['_fecha_modificacion'] != null
          ? Utilidades.parseHoraFecha(fechaInicial: responseObject['datos']['_fecha_modificacion'])
          : '';
      resultado['entidad'] =
          responseObject['datos']['entidad']['sigla'] != null && responseObject['datos']['entidad']['sigla'].toString().isNotEmpty
              ? '${responseObject['datos']['entidad']['sigla']} ${responseObject['datos']['entidad']['denominacion']}'
              : 'No hay información registrada';
      resultado['unidad'] = responseObject['datos']['unidad'] != null && responseObject['datos']['unidad'].toString().isNotEmpty
          ? responseObject['datos']['unidad']
          : 'No hay información registrada';
      resultado['horario_atencion_tramite'] = responseObject['datos']['horario_atencion'] != null
          ? Utilidades.obtieneHorario(responseObject['datos']['horario_atencion'])
          : 'No hay información registrada';
      resultado['horario_atencion_entidad'] =
          responseObject['datos']['entidad'] != null && responseObject['datos']['entidad']['horario_atencion'] != null
              ? Utilidades.obtieneHorario(responseObject['datos']['entidad']['horario_atencion'])
              : 'No hay información registrada';
      resultado['objetivo'] = responseObject['datos']['objetivo'] != null && responseObject['datos']['objetivo'].toString().isNotEmpty
          ? responseObject['datos']['objetivo']
          : 'No hay información registrada';

      Utilidades.imprimir("procesado 👍: $resultado");

      List<dynamic> listaRequisitos = new List();

      try {
        if (responseObject['datos']['requisitos_json'] != null) {
          listaRequisitos = responseObject['datos']['requisitos_json'];
        }
      } catch (e) {
        Utilidades.imprimir(e.toString());
      }

      Utilidades.imprimir("Lista de requisitos: $listaRequisitos");

      Utilidades.imprimir("arreglo de requisitos: ${responseObject['datos']['requisitos']}");

      if (responseObject['datos']['requisitos'] != null && responseObject['datos']['requisitos'].toString().isNotEmpty) {
        resultado['requisitos'] = responseObject['datos']['requisitos'];
      } else if (responseObject['datos']['requisitos_json'] != null && listaRequisitos.length > 0 && listaRequisitos[0]['items'] != null) {
        resultado['requisitos'] = '<ol>';
        for (var item in listaRequisitos[0]['items']) {
          resultado['requisitos'] += '<li>${item['value']}</li>';
        }
        resultado['requisitos'] += '</ol>';
      } else
        resultado['requisitos'] = 'No hay información registrada';

      List<dynamic> listaCostos = new List();
      try {
        if (responseObject['datos']['Costos'] != null) {
          listaCostos = responseObject['datos']['Costos'];
        }
      } catch (e) {
        Utilidades.imprimir(e.toString());
      }

      Utilidades.imprimir("Lista de costos: $listaCostos");

      if (responseObject['datos']['Costos'] != null && listaCostos.length > 0) {
        resultado['costo'] = "<table border='1'>" +
            "<tr>" +
            "<th>Forma de Pago</th>" +
            "<th>Concepto</th>" +
            "<th>Monto</th>" +
            "<th>Moneda</th>" +
            "<th>Cuenta Bancaria</th>" +
            "</tr>";
        for (var item in listaCostos) {
          resultado['costo'] += "<tr>" +
              "<td>" +
              (item["forma_pago"] != null ? item["forma_pago"] : "---") +
              "</td>" +
              "<td>" +
              (item["concepto"] != null ? item["concepto"] : "---") +
              "</td>" +
              "<td>" +
              (item["monto"] != null ? item["monto"] : "---") +
              "</td>" +
              "<td>" +
              (item["moneda"] != null ? item["moneda"] : "---") +
              "</td>" +
              "<td>" +
              (item["cuenta_deposito"] != null ? item["cuenta_deposito"] : "---") +
              "</td>" +
              "</tr>";
        }
        resultado['costo'] += "</table>";
      } else if (responseObject['datos']['costo'] != null &&
          responseObject['datos']['costo'].toString().compareTo('0.00 Bs') != 0 &&
          responseObject['datos']['costo'].compareTo('null Bs') != 0) {
        resultado['costo'] = responseObject['datos']['costo'];
      } else
        resultado['costo'] = 'No hay información registrada';

      List<dynamic> listaPasos = new List();
      try {
        listaPasos = responseObject['datos']['pasos_json'] == null ? new List() : responseObject['datos']['pasos_json'];
      } catch (e) {
        Utilidades.imprimir(e.toString());
      }

      Utilidades.imprimir("Lista de pasos: $listaPasos");

      if (responseObject['datos']['procedimientos'] != null && responseObject['datos']['procedimientos'].toString().isNotEmpty) {
        resultado['procedimientos'] = responseObject['datos']['procedimientos'];
      } else if (responseObject['datos']['pasos_json'] != null && listaPasos.length > 0 && listaPasos[0]['items'] != null) {
        resultado['procedimientos'] = '<ol>';
        for (var item in listaPasos[0]['items']) {
          resultado['procedimientos'] += '<li>${item['value']}</li>';
        }
        resultado['procedimientos'] += '</ol>';
      } else
        resultado['procedimientos'] = 'No hay información registrada';

      if (responseObject['datos']['direcciones'] != null && responseObject['datos']['direcciones'].length > 0) {
        resultado['direcciones'] = "<ul>";
        for (var item in responseObject['datos']['direcciones']) {
          String departamento = item['departamento'] +
              (item['provincia'] != null ? ', ${item['provincia']}' : '') +
              (item['municipio'] != null ? ', ${item['municipio']}' : '');
          resultado['direcciones'] +=
              "<li><strong>" + departamento + ": </strong>" + item['direccion_completa'] + "<br>Teléfonos: " + item['telefono'] + "</li>";
        }
        resultado['direcciones'] += "</ul>";
      } else
        resultado['direcciones'] = 'No hay información registrada';

      resultado['duracion'] =
          responseObject['datos']['duracion'] != null ? responseObject['datos']['duracion'] : 'No hay información registrada';

      Utilidades.imprimir("Lista de pasos 2.5");

      Utilidades.imprimir("${responseObject['datos']['marco_legal'].runtimeType}");

      if (responseObject['datos']['marco_legal'] is String) {
        resultado['marco_legal'] = responseObject['datos']['marco_legal'];
      } else {
        if (responseObject['datos']['marco_legal'] != null && responseObject['datos']['marco_legal'].length > 0) {
          resultado['marco_legal'] = "<ul>";
          for (String item in responseObject['datos']['marco_legal']) {
            resultado['marco_legal'] += "<li>$item</li>";
          }
          resultado['marco_legal'] += "</ul>";
        } else
          resultado['marco_legal'] = 'No hay información registrada';
      }

      resultado['url_tramite_en_linea'] = responseObject['datos']['url_tramite_en_linea'] != null
          ? '<a href = "${responseObject['datos']['url_tramite_en_linea']}">${responseObject['datos']['url_tramite_en_linea']}</a>'
          : null;
      resultado['url_informacion_tramite'] = responseObject['datos']['url_informacion_tramite'] != null
          ? '<a href = "${responseObject['datos']['url_informacion_tramite']}">${responseObject['datos']['url_informacion_tramite']}</a>'
          : null;
      resultado['url_aplicacion_movil'] = responseObject['datos']['url_aplicacion_movil'] != null
          ? '<a href = "${responseObject['datos']['url_aplicacion_movil']}">${responseObject['datos']['url_aplicacion_movil']}</a>'
          : null;
      Utilidades.imprimir("todo el resultado: $resultado");
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Container(
              child: Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Image(
                      image: AssetImage(
                        'assets/images/tramites/pin.png',
                      ),
                      color: _marcadorModelAccess.getById(widget.idTramite) != null ? Colors.lightGreen : ColorApp.greyBackground,
                      height: 30,
                    ),
                  ),
                  onTap: () async {
                    if (_marcadorModelAccess.getById(widget.idTramite) != null) {
                      _marcadorModelAccess.deleteById(widget.idTramite);
                      await _marcadorModelAccess.save();
                      setState(() {});
                    } else {
                      _marcadorModelAccess
                          .add(new MarcadorModel(idTramite: tramite['idTramite'], titulo: tramite['titulo'], sigla: tramite['entidad']));
                      await _marcadorModelAccess.save();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          )),
          actions: <Widget>[
            FlatButton(
              child: Text('Cerrar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          child: Center(
              child: tramite == null
                  ? Visibility(
                      visible: _peticionActiva,
                      child: Elementos.indicadorProgresoLineal(),
                    )
                  : infoTramite()),
        ));
  }

  /// Viste que muestra la información del trámite
  Widget infoTramite() {
    // Expanded > SingleChildScrollView > Padding
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tramite['titulo'],
                    style: TextStyle(color: Color(0XFF606060), fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ultima actualización',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tramite['fecha_modificacion'],
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w100),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Información actualizada por',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tramite['entidad'],
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w100),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Este trámite depende de',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tramite['unidad'],
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w100),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Horarios de atención de trámite',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tramite['horario_atencion_tramite'],
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w100),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'horarios de atención de entidad',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tramite['horario_atencion_entidad'],
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w100),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${tramite['objetivo']}',
                    style: TextStyle(color: Color(0XFF606060), fontWeight: FontWeight.w100),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '¿Qué requisitos se necesitan?',
                    style: TextStyle(color: Color(0XFF606060), fontWeight: FontWeight.w700),
                  ),
                ),
                Html(
                  data: tramite['requisitos'],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '¿Cuánto cuesta el trámite?',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Html(
                  data: tramite['costo'],
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '¿Cómo se realiza este trámite?',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Html(
                  data: tramite['procedimientos'],
                ),
                Divider(
                  height: 5,
                  thickness: 1.5,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '¿Dónde puedo realizar el trámite?',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Html(
                  data: tramite['direcciones'],
                ),
                Divider(
                  height: 5,
                  thickness: 1.5,
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Más información del trámite',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tiempo promedio para realizar el trámite',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${tramite['duracion']}',
                    style: TextStyle(color: Color(0XFF606060), fontWeight: FontWeight.w100),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Marco legal',
                    style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                  ),
                ),
                Html(
                  data: tramite['marco_legal'],
                ),
                if (tramite['url_tramite_en_linea'] != null)
                  Column(
                    children: [
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Puede realizar este trámite en línea',
                          style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Html(
                        data: tramite['url_tramite_en_linea'],
                        onLinkTap: (url) {
                          Utilidades.abrirURL(url);
                        },
                      ),
                    ],
                  ),
                if (tramite['url_informacion_tramite'] != null)
                  Column(
                    children: [
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Información del trámite',
                          style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Html(
                        data: tramite['url_informacion_tramite'],
                        onLinkTap: (url) {
                          Utilidades.abrirURL(url);
                        },
                      ),
                    ],
                  ),
                if (tramite['url_aplicacion_movil'] != null)
                  Column(
                    children: [
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Aplicación móvil',
                          style: TextStyle(color: Color(0XFF606060), fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Html(
                        data: tramite['url_aplicacion_movil'],
                        onLinkTap: (url) {
                          Utilidades.abrirURL(url);
                        },
                      )
                    ],
                  )
              ],
            )));
  }
}
