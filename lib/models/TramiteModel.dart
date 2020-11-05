/// clase que define las propiedades de un trámite

class TramiteModel {
  /// Identificador de trámite
  int _idTramite;
  /// Código de trámite
  int _codigoTramite;
  /// Descripción de trámite
  String _descripcionTramite;
  /// Indicador de trámite obligatorio
  bool _obligatorio;
  /// Indicador de trámite validado
  bool _validado;
  /// Indicador de trámite autorizado
  bool _autorizado;

  TramiteModel({
    int idTramite,
    int codigoTramite,
    String descripcionTramite,
    obligatorio,
    validado,
    autorizado
  })  : _idTramite = idTramite,
        _codigoTramite = codigoTramite,
        _descripcionTramite = descripcionTramite,
        _obligatorio = obligatorio,
        _validado = validado,
        _autorizado = autorizado;

  factory TramiteModel.fromJson(dynamic jsonObject) {
    return TramiteModel(
      idTramite: jsonObject['idTramite'],
      codigoTramite: jsonObject['codigoTramite'],
      descripcionTramite: jsonObject['descripcionTramite'],
      obligatorio: jsonObject['obligatorio'],
      validado: jsonObject['validado'],
      autorizado: jsonObject['autorizado'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idTramite': _idTramite,
    'codigoTramite': _codigoTramite,
    'descripcionTramite': _descripcionTramite,
    'obligatorio': _obligatorio,
    'validado': _validado,
    'autorizado': _autorizado,
  };

  bool get getAutorizado => _autorizado;

  bool get validado => _validado;

  bool get obligatorio => _obligatorio;

  String get descripcionTramite => _descripcionTramite;

  int get codigoTramite => _codigoTramite;

  int get idTramite => _idTramite;

  set autorizado(bool value) {
    _autorizado = value;
  }


}
