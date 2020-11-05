import 'package:ciudadaniadigital/models/TramiteModel.dart';

/// Clase que contiene las propiedades de una entidad

class EntidadTramiteModel {
  /// Identificador de entidad
  int _idEntidad;
  /// Nombre de entidad
  String _nombreEntidad;
  /// Descripción de la entidad
  String _descripcion;
  /// Sigla de la entidad
  String _sigla;
  /// Dirección de la entidad
  String _direccion;
  /// Estado de la entidad
  String _estado;
  /// Código en el portal de trámites gob.bo
  int _codigoPortal;
  /// Trámites de la entidad
  List<TramiteModel> _tramites;
  /// Indicador de trámite autorizado
  bool _autorizado;

  EntidadTramiteModel({
    int idEntidad,
    String nombreEntidad,
    String descripcion,
    String sigla,
    String direccion,
    String estado,
    int codigoPortal,
    List<TramiteModel> tramites,
    bool autorizado,
  })  : _idEntidad = idEntidad,
        _nombreEntidad = nombreEntidad,
        _descripcion = descripcion,
        _sigla = sigla,
        _direccion = direccion,
        _estado = estado,
        _codigoPortal = codigoPortal,
        _tramites = tramites,
        _autorizado = autorizado;

  factory EntidadTramiteModel.fromJson(jsonObject) {
    return EntidadTramiteModel(
      idEntidad: jsonObject['idEntidad'],
      nombreEntidad: jsonObject['nombreEntidad'],
      descripcion: jsonObject['descripcion'],
      sigla: jsonObject['sigla'],
      direccion: jsonObject['direccion'],
      estado: jsonObject['estado'],
      codigoPortal: jsonObject['codigoPortal'],
      tramites: jsonObject['tramites'],
      autorizado: jsonObject['autorizado']
    );
  }

  Map<String, dynamic> toJson() => {
    'idEntidad': _idEntidad,
    'nombreEntidad': _nombreEntidad,
    'descripcion': _descripcion,
    'sigla': _sigla,
    'direccion': _direccion,
    'estado': _estado,
    'codigoPortal': _codigoPortal,
    'tramites': _tramites,
    'autorizado': _autorizado,
  };

  bool get getAutorizado => _autorizado;

  set autorizado(bool value) {
    _autorizado = value;
  }

  List<TramiteModel> get getTramites => _tramites;

  int get codigoPortal => _codigoPortal;

  String get getEstado => _estado;

  String get direccion => _direccion;

  String get getSigla => _sigla;

  String get descripcion => _descripcion;

  String get nombreEntidad => _nombreEntidad;

  int get idEntidad => _idEntidad;

  set tramites(List<TramiteModel> value) {
    _tramites = value;
  }

  set estado(String value) {
    _estado = value;
  }

  set sigla(String value) {
    _sigla = value;
  }
}
