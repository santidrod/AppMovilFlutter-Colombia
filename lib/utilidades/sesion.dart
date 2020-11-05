import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ciudadaniadigital/pages/Inicio/login_page.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/servicios/ServiceLocator.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

import 'Constantes.dart';
import 'Services.dart';
import 'animaciones.dart';

/// Clase con métodos de la sesión OAuth

class Sesion {
  /// Objeto que maneja la sesión OAuth
  static final FlutterAppAuth _appAuth = FlutterAppAuth();

  static Future AlmacenarSesion(
      {accessToken,
      accessTokenExpirationDateTime,
      idToken,
      refreshToken}) async {
    await Utilidades.saveSecureStorage(key: "accessToken", value: accessToken);
    await Utilidades.saveSecureStorage(
        key: "accessTokenExpirationDateTime",
        value: "$accessTokenExpirationDateTime");
    await Utilidades.saveSecureStorage(key: "idToken", value: idToken);
    await Utilidades.saveSecureStorage(
        key: "refreshToken", value: refreshToken);
  }

  static Future<bool> sesionIniciada() async {
    return await obtenerAccessTokenAlmacenado() != null;
  }

  static Future<String> obtenerAccessTokenAlmacenado() async {
    return await Utilidades.readSecureStorage(key: "accessToken");
  }

  static Future<String> obtenerRefreshTokenAlmacenado() async {
    return await Utilidades.readSecureStorage(key: "refreshToken");
  }

  /// Método que llama a otro para cerrar la sesión OAuth y elimina los datos del usuario del almacenamiento local
  static Future cerrarSesion(context, {bool proveedor = false}) async {
    if (proveedor) {
      Utilidades.imprimir(
          "Cerrando sesión con proveedor en ${Platform.operatingSystem} 📱");
      Platform.isAndroid ? await logout() : await revocarTokens();
    } else {
      Utilidades.imprimir("Cerrando sesión sin llamar al proveedor");
    }
    if (mqttWrapper != null) mqttWrapper.disconnectMqttClient();
    unregisterLocator();
    await Utilidades.deleteAllSecureStorage();
    // Navigator.pushAndRemoveUntil(context, FadeRoute(page: LoginPage()), ModalRoute.withName('/'));
    await Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: Elementos.bannerEntorno(child: LoginPage())),
        (route) => false);
  }

  static Future revocarTokens() async {
    var _accessToken = await obtenerAccessTokenAlmacenado();
    Utilidades.imprimir("accessToken: $_accessToken");
    await revokeToken(tokenTypeHint: "access_token", token: _accessToken);
    var _refreshToken = await obtenerRefreshTokenAlmacenado();
    Utilidades.imprimir("refreshToken: $_refreshToken");
    await revokeToken(tokenTypeHint: "refresh_token", token: _refreshToken);
  }

  // Método que revoca un token
  static Future revokeToken(
      {@required String tokenTypeHint, @required String token}) async {
    Utilidades.imprimir("_clientId: ${Constantes.clientID}");

    var idToken = await Utilidades.readSecureStorage(key: "idToken");
    Utilidades.imprimir("idToken: $idToken");

    Map<String, dynamic> params = {
      "client_id": Constantes.clientID,
      "token_type_hint": tokenTypeHint,
      "token": token,
    };

    await Services.peticion(
            tipoPeticion: TipoPeticion.POST,
            urlPeticion: "${Constantes.urlCiudadania}token/revocation",
            body: Uri(queryParameters: params).query,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'})
        .then((value) {
      Utilidades.imprimir("token revocado ✅: $value");
    }).catchError((onError) {
      Utilidades.imprimir("Error al revocar el token 🛑: $onError");
    }).whenComplete(() => () {
              Utilidades.imprimir(
                  "Termina la petición de recovar token: $tokenTypeHint ↩️");
            });
  }

  /// Método que cierra sesión en el proveedor
  static Future logout() async {
    try {
      Utilidades.imprimir(Platform.isAndroid ? "usamos Android" : "usamos iOS");
      Utilidades.imprimir("_clientId: ${Constantes.clientID}");
      Utilidades.imprimir("_redirectUrl: ${Constantes.redirectURL}");

      AuthorizationServiceConfiguration _serviceConfiguration =
          AuthorizationServiceConfiguration(
              "${Constantes.urlCiudadania}session/end",
              "${Constantes.urlCiudadania}/token");
      Utilidades.imprimir("usaremos: $_serviceConfiguration");
      Utilidades.imprimir("_scopes: ${Constantes.scopes}");

      var idToken = await Utilidades.readSecureStorage(key: "idToken");
      Utilidades.imprimir("idToken: $idToken");

      final String accessToken = await obtenerAccessTokenAlmacenado();

      var resultEliminar = await Services.peticion(
          tipoPeticion: TipoPeticion.DELETE,
          urlPeticion: "${Constantes.urlCiudadania}api/v1/devices/",
          headers: {
            'Authorization': 'Bearer $accessToken',
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8'
          });

      Utilidades.imprimir("Resultado eliminar dispositivo 📲: $resultEliminar");

      var resultadoCerrar = await _appAuth.authorize(
        AuthorizationRequest(Constantes.clientID, Constantes.redirectURL,
            promptValues: ["login"],
            preferEphemeralSession: true,
            discoveryUrl: Constantes.discoveryURL,
            additionalParameters: Platform.isAndroid
                ? {
                    "id_token_hint": idToken,
                    "post_logout_redirect_uri": Constantes.redirectURL
                  }
                : {"id_token_hint": idToken},
            scopes: Constantes.scopes,
            serviceConfiguration: _serviceConfiguration),
      );

      Utilidades.imprimir(
          "Resultado cerrar sesión 🔒: ${resultadoCerrar.toString()}");
    } catch (error) {
      Utilidades.imprimir("error al cerrar sesión 🔒: $error");
    }
  }

  static Future<String> verificarObtenerToken(BuildContext context) async {
    int accessTokenExpirationDateTime = int.parse(
        await Utilidades.readSecureStorage(
            key: "accessTokenExpirationDateTime"));

    int horaActual = DateTime.now().millisecondsSinceEpoch;
    if (horaActual >= accessTokenExpirationDateTime) {
      Utilidades.imprimir(
          "Actualizando por hora de expiración $accessTokenExpirationDateTime 🚨");
      await Sesion.actualizarOAUTH()
          .then((value) async {})
          .catchError((onError) {
        Utilidades.imprimir("Error: $onError ");
        Sesion.cerrarSesion(context, proveedor: true);
      });
    } else {
      Utilidades.imprimir(
          "$horaActual =! $accessTokenExpirationDateTime : faltan ${(accessTokenExpirationDateTime - (horaActual)) / 1000 / 60} minutos ⏳");
    }

    return await obtenerAccessTokenAlmacenado();
  }

  /// Método que actualiza la sesión Oauth
  static Future actualizarOAUTH() async {
    Utilidades.imprimir("Actualizando OAuth 🚨");
    try {
      var _clientId = Constantes.clientID;
      Utilidades.imprimir("_clientId: $_clientId");
      var _refreshToken =
          await Utilidades.readSecureStorage(key: "refreshToken");
      Utilidades.imprimir("refreshToken: $_refreshToken");

      final TokenResponse response = await _appAuth.token(TokenRequest(
          _clientId, Constantes.redirectURL,
          refreshToken: _refreshToken,
          discoveryUrl: Constantes.discoveryURL,
          scopes: Constantes.scopes));

      var _accessToken = response.accessToken;
      int _accessTokenExpirationDateTime =
          response.accessTokenExpirationDateTime.millisecondsSinceEpoch;
      var _idToken = response.idToken;
      _refreshToken = response.refreshToken;

      Utilidades.imprimir("accessToken nuevo 🟢: $_accessToken");
      Utilidades.imprimir(
          "accessTokenExpirationDateTime nuevo 🟢: $_accessTokenExpirationDateTime");
      Utilidades.imprimir("idToken nuevo 🟢: $_idToken");
      Utilidades.imprimir("refreshToken nuevo 🟢: $_refreshToken");

      await Utilidades.saveSecureStorage(
          key: "accessToken", value: _accessToken);
      await Utilidades.saveSecureStorage(
          key: "accessTokenExpirationDateTime",
          value: "$_accessTokenExpirationDateTime");
      await Utilidades.saveSecureStorage(key: "idToken", value: _idToken);
      await Utilidades.saveSecureStorage(
          key: "refreshToken", value: _refreshToken);
    } catch (error) {
      Utilidades.imprimir("Error al actualizar OAuth $error");
      throw "Error al actualizar OAuth $error";
    }
  }

  /// Método que hace generaliza las peticiones web usando el access_token

  static Future peticion(
      {@required TipoPeticion tipoPeticion,
      @required String urlPeticion,
      @required BuildContext context,
      Map bodyparams,
      String body}) async {
    try {
      String _accessToken = await Sesion.verificarObtenerToken(context);

      if (await Services.conexionInternet()) {
        Utilidades.imprimir(
            "enviando 🌍🤖  ${bodyparams ?? body}  $tipoPeticion a: $urlPeticion con $_accessToken");
      } else {
        throw ('No cuenta con conexión a internet 🌍');
      }

      http.Response response = await Services.peticionHttp1(
          urlPeticion: urlPeticion,
          tipoPeticion: tipoPeticion,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $_accessToken',
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8'
          },
          bodyparams: bodyparams,
          body: body);

      Utilidades.imprimir(
          "respuesta 📡 $urlPeticion :: ${response.statusCode}: ${response.body}");

      if (Services.statusSuccefull.contains(response.statusCode)) {
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
          if (Services.statusError.contains(response.statusCode)) {
            Sesion.cerrarSesion(context, proveedor: true);
          }
          return throw json.decode(response.body);
        } on Exception catch (e) {
          Utilidades.imprimir("Error en petición: ${e.toString()}");
          return throw ('Solicitud erronea');
        }
      }
    } on TimeoutException catch (_) {
      return throw ("La petición está tardando demasiado");
    } on Exception {
      rethrow;
    }
  }
}
