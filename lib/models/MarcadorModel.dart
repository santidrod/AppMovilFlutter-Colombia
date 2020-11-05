/// Clase que contiene un marcador de un trámite
class MarcadorModel {
  /// Identificador del trámite
  String _idTramite;

  /// Nombre del trámite
  String _titulo;

  /// sigla de la entidad
  String _sigla;

  MarcadorModel({
    String idTramite,
    String titulo,
    String sigla,
  })  : _idTramite = idTramite,
        _titulo = titulo,
        _sigla = sigla;

  factory MarcadorModel.fromJson(dynamic jsonObject) {
    return MarcadorModel(
      idTramite: jsonObject['idTramite'],
      titulo: jsonObject['titulo'],
      sigla: jsonObject['sigla'],
    );
  }

  Map<String, dynamic> toJson() => {
        'idTramite': _idTramite,
        'titulo': _titulo,
        'sigla': _sigla,
      };

  String get sigla => _sigla;

  String get titulo => _titulo;

  String get idTramite => _idTramite;
}
