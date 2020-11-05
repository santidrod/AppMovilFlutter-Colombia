import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http2_client/http2_client.dart';

/// Enum que define los tipos de metodos HTTP aceptados por la aplicación
enum TipoPeticion { GET, POST, DELETE, PUT, PATCH }

/// Limite de tiempo en una petición
const _timeoutSeconds = 60;

/// Clase que contiene métodos para hacer peticiones HTTP
class Services {
  static List<int> statusSuccefull = <int>[200, 201, 202, 204];
  static List<int> statusError = <int>[401];

  /// Método que verifica la conexión a internet

  static Future<bool> conexionInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Método que hace la petición HTTP con parametros como headers, body

  static Future peticion(
      {@required TipoPeticion tipoPeticion,
      @required String urlPeticion,
      Map<String, String> headers,
      Map bodyparams,
      String body}) async {
    try {
      if (await conexionInternet()) {
        Utilidades.imprimir(
            "enviando 🌍 ${bodyparams ?? body}  $tipoPeticion a: $urlPeticion con  $headers");
      } else {
        throw ('No cuenta con conexión a internet 🌍');
      }

      http.Response response = await peticionHttp1(
          urlPeticion: urlPeticion,
          tipoPeticion: tipoPeticion,
          headers: headers,
          bodyparams: bodyparams,
          body: body);

      Utilidades.imprimir(
          "respuesta 📡 $urlPeticion :: ${response.statusCode}: ${response.body}");

      if (statusSuccefull.contains(response.statusCode)) {
        Utilidades.imprimir(
            "Tipo de respuesta: ${response.headers["content-type"]}");

        if (response.headers.containsKey("content-type")) {
          if (response.headers["content-type"].contains("application/json")) {
            return json.decode(response.body);
          } else {
            return response.bodyBytes;
          }
        } else {
          return;
        }
      } else {
        try {
          return throw json.decode(response.body);
        } on Exception catch (e) {
          Utilidades.imprimir("Error en petición: ${e.toString()}");
          return throw ('Solicitud errónea');
        }
      }
    } on TimeoutException catch (_) {
      return throw ("La petición está tardando demasiado");
    } on Exception {
      rethrow;
    }
  }

  /// Método que hace una peticion http2

  static Future<http.Response> peticionHttp2(
      {@required TipoPeticion tipoPeticion,
      @required String urlPeticion,
      Map<String, String> headers,
      Map bodyparams,
      String body}) async {
    http.Response response;

    // peticiones HTTP/2.0
    var client = Http2Client(
      maxOpenConnections: Platform.numberOfProcessors,
    );

    switch (tipoPeticion) {
      case TipoPeticion.POST:
        if ((bodyparams == null) && (body == null)) {
          response = await client
              .post(
                urlPeticion,
                headers: headers,
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        } else {
          response = await client
              .post(
                urlPeticion,
                headers: headers,
                body: body ?? jsonEncode(bodyparams),
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        }
        break;
      case TipoPeticion.PATCH:
        if ((bodyparams == null) && (body == null)) {
          response = await client
              .patch(
                urlPeticion,
                headers: headers,
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        } else {
          response = await client
              .patch(
                urlPeticion,
                headers: headers,
                body: body ?? jsonEncode(bodyparams),
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        }
        break;
      case TipoPeticion.GET:
        response = await client
            .get(
              urlPeticion,
              headers: headers,
            )
            .timeout(Duration(seconds: _timeoutSeconds));
        break;
      case TipoPeticion.DELETE:
        response = await client
            .delete(
              urlPeticion,
              headers: headers,
            )
            .timeout(Duration(seconds: _timeoutSeconds));
        /*if ((bodyparams == null) && (body == null)) {

            } else {
              headers.remove(HttpHeaders.contentTypeHeader);
              http.Request req = http.Request('DELETE', Uri.parse(urlPeticion))..headers.addAll(headers);
              req.body = body ?? jsonEncode(bodyparams);
              response = await req.send().then((value) => http.Response.fromStream(value));
            }*/
        break;

      case TipoPeticion.PUT:
        if ((bodyparams == null) && (body == null)) {
          response = await client
              .put(
                urlPeticion,
                headers: headers,
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        } else {
          response = await client
              .put(
                urlPeticion,
                headers: headers,
                body: body ?? jsonEncode(bodyparams),
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        }
        break;
      default:
    }
    client.close();

    return response;
  }

  /// Método que hace una peticion http\1

  static Future<http.Response> peticionHttp1(
      {@required TipoPeticion tipoPeticion,
      @required String urlPeticion,
      Map<String, String> headers,
      Map bodyparams,
      String body}) async {
    http.Response response;

    switch (tipoPeticion) {
      case TipoPeticion.POST:
        if ((bodyparams == null) && (body == null)) {
          response = await http
              .post(
                urlPeticion,
                headers: headers,
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        } else {
          response = await http
              .post(
                urlPeticion,
                headers: headers,
                body: body ?? jsonEncode(bodyparams),
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        }
        break;
      case TipoPeticion.PATCH:
        if ((bodyparams == null) && (body == null)) {
          response = await http
              .patch(
                urlPeticion,
                headers: headers,
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        } else {
          response = await http
              .patch(
                urlPeticion,
                headers: headers,
                body: body ?? jsonEncode(bodyparams),
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        }
        break;
      case TipoPeticion.GET:
        response = await http
            .get(
              urlPeticion,
              headers: headers,
            )
            .timeout(Duration(seconds: _timeoutSeconds));
        break;
      case TipoPeticion.DELETE:
        response = await http
            .delete(
              urlPeticion,
              headers: headers,
            )
            .timeout(Duration(seconds: _timeoutSeconds));

        break;

      case TipoPeticion.PUT:
        if ((bodyparams == null) && (body == null)) {
          response = await http
              .put(
                urlPeticion,
                headers: headers,
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        } else {
          response = await http
              .put(
                urlPeticion,
                headers: headers,
                body: body ?? jsonEncode(bodyparams),
              )
              .timeout(Duration(seconds: _timeoutSeconds));
        }
        break;
      default:
    }

    return response;
  }
}
