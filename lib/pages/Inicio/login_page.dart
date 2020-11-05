import 'dart:async';
import 'dart:io' show HttpHeaders, Platform;

import 'package:ciudadaniadigital/pages/Inicio/widgets/ListaOpcionesWidget.dart';
import 'package:ciudadaniadigital/pages/autoregistro_container.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/home.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/StatusAppBar.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/animaciones.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/servicios/ServiceLocator.dart';
import 'package:ciudadaniadigital/utilidades/servicios/mqtt.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:uni_links/uni_links.dart';

import '../../utilidades/Services.dart';

MqttWrapper mqttWrapper;

/// Vista de inicio de sesión la información de la aplicación
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  /// Indicador de petición activa
  bool _ocupado = false;

  /// Objeto que maneja la sesión OAuth
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  /// Token de acceso
  String _accessToken;

  /// Token de acceso
  int _accessTokenExpirationDateTime;

  /// Identificador del token
  String _idToken;

  /// Token de actualización
  String _refreshToken;

  /// Identificador del cliente
  final String _clientId = Constantes.clientID;

  /// URL de redirección
  final String _redirectUrl = Constantes.redirectURL;

  /// Lista de scopes para iniciar sesión
  final List<String> _scopes = Constantes.scopes;

  /// Configuraciones de servicio autorización
  final AuthorizationServiceConfiguration _serviceConfiguration =
      AuthorizationServiceConfiguration('${Constantes.urlCiudadania}auth',
          '${Constantes.urlCiudadania}token');

  /// Indicador de conexión a internet
  var internetstatus = true;

  /// Método que me cambia el estado de la petición activa
  void _setBusyState(bool valor) {
    setState(() {
      _ocupado = valor;
    });
  }

  /// Método que procesa la respuesta de la petición de inicio de sesión
  Future _processAuthTokenResponse(AuthorizationTokenResponse response) async {
    setState(() {
      _accessToken = response.accessToken;
      _accessTokenExpirationDateTime =
          response.accessTokenExpirationDateTime.millisecondsSinceEpoch;
      _idToken = response.idToken;
      _refreshToken = response.refreshToken;
    });

    Utilidades.imprimir("accessToken: $_accessToken");
    Utilidades.imprimir(
        "accessTokenExpirationDateTime: $_accessTokenExpirationDateTime");
    Utilidades.imprimir("idToken: $_idToken");
    Utilidades.imprimir("refreshToken: $_refreshToken");

    await Sesion.AlmacenarSesion(
        accessToken: _accessToken,
        accessTokenExpirationDateTime: _accessTokenExpirationDateTime,
        idToken: _idToken,
        refreshToken: _refreshToken);
  }

  /// Método que  inicia sesión OAuth

  Future<void> _signInWithAutoCodeExchange() async {
    try {
      _setBusyState(true);
      Utilidades.imprimir("usamos ${Platform.operatingSystem}");
      Utilidades.imprimir("_clientId: $_clientId");
      Utilidades.imprimir("_redirectUrl: $_redirectUrl");
      Utilidades.imprimir("_scopes: $_scopes");

      // this code block demonstrates passing in values for the prompt parameter. in this case it prompts the user login even if they have already signed in. the list of supported values depends on the identity provider
      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
              _clientId, _redirectUrl,
              serviceConfiguration: _serviceConfiguration,
              preferEphemeralSession: true,
              scopes: _scopes,
              promptValues: ['consent']));

      Utilidades.imprimir("Resultado Oauth: $result");

      if (result != null) {
        await _processAuthTokenResponse(result);
        await configurarTOTP();
        // Registra los buses de comunicacion
        setupLocator();
        // registramos al ciudadano en notificaciones
        await registraNotificaciones();
      }

      Navigator.pushAndRemoveUntil(
          context,
          FadeRoute(
              page: Elementos.bannerEntorno(
            child: HomePage(
              actualizarSesion: false,
            ),
          )),
          (Route<dynamic> route) => false);
    } catch (error) {
      Utilidades.imprimir("error _signInWithAutoCodeExchange: $error");
      // Alertas.showToast(mensaje: 'No se pudo iniciar sesión en ciudadanía, por favor intente más tarde', danger: true);
    } finally {
      Utilidades.imprimir("Finalizando OAuth");
      _setBusyState(false);
    }
  }

  /// Método que configura la petición TOTP
  Future<void> configurarTOTP() async {
    Utilidades.imprimir("Configurando TOTP ⚙️");
    try {
      var esEmulador = await Dispositivo.esEmulador();
      Utilidades.imprimir("emulador 🤖: $esEmulador");
      var dispositivo = await Dispositivo.getModel();
      Utilidades.imprimir("dispositivo 📱: $dispositivo");
      var fingerprint = await Dispositivo.getId();
      Utilidades.imprimir("fingerprint ℹ️: $fingerprint");
      String accesToken = await Sesion.obtenerAccessTokenAlmacenado();
      Utilidades.imprimir("AccesToken ℹ️: $accesToken");
      String pais = await Dispositivo.getCountryCode();
      Utilidades.imprimir("pais 🌄️: $pais");
      String carrierName = await Dispositivo.getCarrierName();
      Utilidades.imprimir("operadora 📲️: $carrierName");

      Map<String, String> params = {
        "pais": pais,
        "operador": carrierName,
        "esEmulador": esEmulador.toString(),
        "dispositivo": dispositivo,
        "fingerprint": fingerprint
      };

      var result = await Services.peticion(
          tipoPeticion: TipoPeticion.POST,
          urlPeticion: "${Constantes.urlCiudadania}api/v1/devices/",
          bodyparams: {
            "data": params
          },
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accesToken',
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          });

      Utilidades.imprimir("Configurar TOTP 🕒: $result");

      await Utilidades.saveSecureStorage(
          key: "secret", value: result["result"]["secret"]);
    } catch (error) {
      Utilidades.imprimir("Error al obtener TOTP 🕒: $error");
    }
  }

  /// Método que llama al método que inicia sesión OAuth
  Future<void> iniciarSesionOAuth() async {
    _signInWithAutoCodeExchange();
  }

  /// Método que cambia el statusbar cuando hay un cambio en la conexión a internet
  void activarBotones({bool habilitado, bool actualizar}) {
    setState(() {
      internetstatus = habilitado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StatusAppbar(accionCambioStatusAppBar: activarBotones),
      body: vistaPortrait(),
    );
  }

  /// Vista portrat de inicio de sesión
  Widget vistaPortrait() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Elementos.cabeceraLogos3(),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            left: 35, right: 35, top: 25, bottom: 5),
                        constraints: BoxConstraints(maxWidth: 400),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Bienvenid@ a Ciudadanía Digital,',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300)),
                              TextSpan(
                                  text: ' tu acceso a ',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300)),
                              TextSpan(
                                  text:
                                      'todos los servicios digitales del Estado Plurinacional de Bolivia',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: 500),
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        child: Column(
                          children: ListaOpciones.opciones(context,
                              habilitar: _accessToken == null),
                        ),
                      ),
                      Container(
                        width: 200,
                        child: Visibility(
                          visible: _ocupado,
                          child: Elementos.indicadorProgresoLineal(),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 5, bottom: 0),
                        child: SizedBox(
                            width: 221,
                            height: 40,
                            child: RaisedButton(
                              child: Text(
                                'Ingresar',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: ColorApp.bg,
                                    fontWeight: FontWeight.w500),
                              ),
                              onPressed: _accessToken == null && internetstatus
                                  ? iniciarSesionOAuth
                                  : null,
                              color: ColorApp.buttons,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(42.0)),
                            )),
                      ),
                      Container(
                        width: 244,
                        padding: EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '¿Aún no eres Ciudadano Digital?',
                            style: TextStyle(
                              color: ColorApp.blackText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 244,
                        child: Align(
                          alignment: Alignment.center,
                          child: FlatButton(
                            onPressed: _accessToken == null && internetstatus
                                ? () async {
                                    Map<String, String> allValues =
                                        await Utilidades.readAllSecureStorage();
                                    Utilidades.imprimir(
                                        "todos los valores: $allValues");

                                    //await Dialogo.showFullScreen(context, AutoRegistroPage());
                                    await Dialogo.showNativeModalBottomSheet(
                                        context, AutoRegistroPage());
                                  }
                                : null,
                            child: Text(
                              'Regístrate aquí',
                              style: TextStyle(
                                  color: ColorApp.btnBackground, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FocusScope.of(context).unfocus());
    super.initState();
    // initUniLinks();
  }

  /// Método que inicializa unilinks
  Future initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      Utilidades.imprimir('UNILINK DETECTADO === $initialLink');
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      Utilidades.imprimir('PLATFORM EXCEPTION!!!!');
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  /// Método que registra el dispositivo para uso de notificaciones
  Future<void> registraNotificaciones() async {
    String documento;
    Services.peticion(
            tipoPeticion: TipoPeticion.GET,
            urlPeticion: '${Constantes.urlIsuer}me',
            headers: {HttpHeaders.authorizationHeader: 'Bearer $_accessToken'})
        .then((response) async {
          Utilidades.imprimir('conectando servicio push....');
          documento =
              response["profile"]["documento_identidad"]["numero_documento"];
          await Utilidades.saveSecureStorage(key: 'usuario', value: documento);
          String nombreUsuario =
              "${response["profile"]["nombre"]["nombres"].toString().split(" ")[0]} ${response["profile"]["nombre"]["primer_apellido"] ?? {
                    response["profile"]["nombre"]["segundo_apellido"]
                  }}";
          await Utilidades.saveSecureStorage(
              key: 'nombreUsuario', value: nombreUsuario);
          Utilidades.imprimir("registrando ciudadano en notificaciones...");
        })
        .then((value) async => await Services.peticion(
            tipoPeticion: TipoPeticion.POST,
            urlPeticion: "${Constantes.urlNotificacionesConfiguracion}activar",
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $_accessToken',
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8'
            },
            bodyparams: null))
        .then((resultado) {
          Utilidades.imprimir('Registrado para notificaciones');
        })
        .catchError((onError) => Utilidades.imprimir("Error: $onError"));
  }
}
