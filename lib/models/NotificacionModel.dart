/// Modelo que contiene las propiedades de una notificación
class NotificacionModel {
  /// Identificador de la notificación
  String _id;

  /// Título de la notificación
  String _titulo;

  /// Nombre de la notificación
  String _institucion;

  /// Fecha de notificación
  String _updateAt;

  /// Estado de notificación (leído o no)
  bool _finalizado;

  /// Nombre de flujo de la notificación
  String _nombreFlujo;

  /// Indicador de trámite destacado
  bool _destacado;

  NotificacionModel(
      {String id, String titulo, String institucion, String updateAt, bool finalizado, String nombreFlujo, bool destacado = false})
      : _id = id,
        _titulo = titulo,
        _institucion = institucion,
        _updateAt = updateAt,
        _finalizado = finalizado,
        _nombreFlujo = nombreFlujo,
        _destacado = destacado;

  /// Método que crea un modelo de notificación a partir de un objeto JSON
  factory NotificacionModel.fromJson(dynamic jsonObject) {
    return NotificacionModel(
      id: jsonObject['id'],
      titulo: jsonObject['titulo'],
      institucion: jsonObject['institucion'],
      updateAt: jsonObject['updateAt'],
      finalizado: jsonObject['finalizado'],
      nombreFlujo: jsonObject['nombreFlujo'],
      destacado: jsonObject['destacado'],
    );
  }

  /// Método que crea un objeto JSON de una notificación
  Map<String, dynamic> toJson() => {
        'id': _id,
        'titulo': _titulo,
        'institucion': _institucion,
        'updateAt': _updateAt,
        'finalizado': _finalizado,
        'nombreFlujo': _nombreFlujo,
        'destacado': _destacado,
      };

  /// Nombre de Flujo
  String get getNombreFlujo => _nombreFlujo;

  set setNombreFlujo(String value) {
    _nombreFlujo = value;
  }

  bool get getFinalizado => _finalizado;

  String get getUpdateAt => _updateAt;

  String get getInstitucion => _institucion;

  String get getTitulo => _titulo;

  String get getId => _id;

  bool get getDestacado => _destacado;

  void setDestacado({bool value}) {
    _destacado = value;
  }

  void setFinalizado({bool value}) {
    _finalizado = value;
  }
}
