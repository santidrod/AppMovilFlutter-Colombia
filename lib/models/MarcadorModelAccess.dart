import 'dart:convert';

import 'package:ciudadaniadigital/models/MarcadorModel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clase que contiene los métodos para guardar en almacenamiento local seguro de un trámite

class MarcadorModelAccess extends FlutterSecureStorage {
  /// Identificador del modelo de trámite
  final String _key = 'tramites_model';

  /// Lista de marcadores
  List<MarcadorModel> _listMarcadores = new List();

  /// Método que guarda el almacenamiento seguro
  Future<void> save() async {
    if (_listMarcadores.length > 0) {
      await this.write(key: _key, value: jsonEncode(toArrayJson()));
    } else {
      await clean();
    }
  }

  /// Método que recupera la lista de marcadores

  Future<List<MarcadorModel>> getAll() async {
    String rawData = await this.read(key: _key);
    if (rawData != null) {
      _listMarcadores = List<MarcadorModel>.from(jsonDecode(rawData).map((x) => MarcadorModel.fromJson(x)));
      return _listMarcadores;
    } else
      return new List();
  }

  /// Método que guarda un marcador en la lista

  void add(MarcadorModel tramite) {
    _listMarcadores.add(tramite);
  }

  /// Método que borra el marcador de memoria local

  Future<void> clean() async {
    await this.delete(key: _key);
  }

  /// Método que convierte el arreglo de marcadores en un json

  List<dynamic> toArrayJson() {
    List<dynamic> listJson = new List();
    _listMarcadores.forEach((sintomaModel) {
      listJson.add(sintomaModel.toJson());
    });
    return listJson;
  }

  /// Función que retorna la cantidad de marcadores
  int length() {
    return _listMarcadores.length;
  }

  /// Método que obtiene un marcador por posición de la lista
  MarcadorModel getByPosition(int position) {
    return _listMarcadores[position];
  }

  /// Método que obtiene un marcador por identificador
  MarcadorModel getById(String idTramite) {
    for (MarcadorModel tramite in _listMarcadores) {
      if (tramite.idTramite.compareTo(idTramite) == 0) return tramite;
    }
    return null;
  }

  /// Método que obtiene un marcador por identificador de trámite
  int getIndex(String idTramite) {
    for (int i = 0; i < _listMarcadores.length; i++) {
      if (_listMarcadores[i].idTramite.compareTo(idTramite) == 0) return i;
    }
    return -1;
  }

  /// Método que elimina un marcador por identificador de trámite
  void deleteById(String idTramite) {
    int position = getIndex(idTramite);
    if (position != -1) {
      _listMarcadores.removeAt(position);
    }
  }
}
