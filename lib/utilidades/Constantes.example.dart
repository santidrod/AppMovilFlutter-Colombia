enum Ambiente { PROD, PREPROD, TEST }

/// URL GOB.BO PARA BUSCAR TRÁMITES;
Map<Ambiente, String> _directorioServicios = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// URL GOB.BO PARA BUSCAR TRÁMITES;
Map<Ambiente, String> _gobBoTramites = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// URL CIUDADANIA PROVIDER
Map<Ambiente, String> _ciudadaniaProvider = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// URL CONSULTA SERVICIOS DIGITALES (Api Rest)
Map<Ambiente, String> _ciudadaniaServiciosDigitalesApiRest = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// URL CONSULTA SERVICIOS DIGITALES
Map<Ambiente, String> _ciudadaniaServiciosDigitalesWebView = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// URL NOTIFICACIONES, CONFIGURACION ALERTAS, CERRAR FLUJOS
Map<Ambiente, String> _ciudadaniaNotificacionesConfiguracion = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// URL NOTIFICACIONES, CONSULTA Y BANDEJA
Map<Ambiente, String> _ciudadaniaNotificacionesBandeja = {
  Ambiente.PROD:
  "${_ciudadaniaNotificacionesConfiguracion[Ambiente.PROD]}proxy/bpm/api/v1/",
  Ambiente.PREPROD:
  "${_ciudadaniaNotificacionesConfiguracion[Ambiente.PREPROD]}proxy/bpm/api/v1/",
  Ambiente.TEST:
  "${_ciudadaniaNotificacionesConfiguracion[Ambiente.TEST]}proxy/bpm/api/v1/"
};
Map<String, dynamic> _ciudadaniaNotificaciones = {
  'configuracion': _ciudadaniaNotificacionesConfiguracion,
  'bandeja': _ciudadaniaNotificacionesBandeja
};

/// URL PRE REGISTRO
Map<Ambiente, String> _ciudadaniaPreregistroBase = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// SUCURSALES DE ENTIDADES Y HORARIO ATENCION
Map<Ambiente, String> _ciudadaniaPreregistroSucursales = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// ENTIDADES
Map<Ambiente, String> _ciudadaniaPreregistroEntidades = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// SERVIDOR CONEXION SOCKET
Map<Ambiente, String> _ciudadaniaPreregistroSocket = {Ambiente.PROD: "", Ambiente.PREPROD: "", Ambiente.TEST: ""};

/// PATH PARA ESTABLECER CONEXION
Map<Ambiente, String> _ciudadaniaPreregistroPathSocket = {Ambiente.PROD: "", Ambiente.PREPROD: "", Ambiente.TEST: ""};

/// PATH PARA OBTENER CERTIFICADO ONLINE
Map<Ambiente, String> _ciudadaniaPreregistroCertificado = {Ambiente.PROD: "", Ambiente.PREPROD: "", Ambiente.TEST: ""};
Map<String, dynamic> _ciudadaniaPreregistro = {
  'base': _ciudadaniaPreregistroBase,
  'sucursales': _ciudadaniaPreregistroSucursales,
  'entidades': _ciudadaniaPreregistroEntidades,
  'socket': _ciudadaniaPreregistroSocket,
  'path_socket': _ciudadaniaPreregistroPathSocket,
  'certificado': _ciudadaniaPreregistroCertificado
};

/// LOGIN PRE BUZON
Map<Ambiente, String> _preBuzonLogin = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// BANDEJA PRE BUZON
Map<Ambiente, String> _preBuzonBandeja = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// CIERRE DE FLUJO PRE BUZON
Map<Ambiente, String> _preBuzonConfiguracion = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};
Map<String, dynamic> _preBuzon = {'login': _preBuzonLogin, 'bandeja': _preBuzonBandeja, 'configuracion': _preBuzonConfiguracion};

/// VERIFICACION DE VERSION
Map<Ambiente, String> _ciudadaniaVersion = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// PARAMETROS CONFIGURACION MQTT CIUDADANIA
Map<Ambiente, String> _ciudadaniaMQTTServer = {Ambiente.PROD: "", Ambiente.PREPROD: "", Ambiente.TEST: ""};

/// USUARIO MQTT
Map<Ambiente, String> _ciudadaniaMQTTUser = {Ambiente.PROD: "", Ambiente.PREPROD: "", Ambiente.TEST: ""};

/// CONTRASEÑA MQTT
Map<Ambiente, String> _ciudadaniaMQTTPassword = {Ambiente.PROD: "", Ambiente.PREPROD: "", Ambiente.TEST: ""};

/// PUERTO CONEXION MQTT
Map<Ambiente, int> _ciudadaniaMQTTPort = {
  Ambiente.PROD: 0,
  Ambiente.PREPROD: 0,
  Ambiente.TEST: 0
};
Map<String, dynamic> _ciudadaniaMQTT = {
  'server': _ciudadaniaMQTTServer,
  'user': _ciudadaniaMQTTUser,
  'password': _ciudadaniaMQTTPassword,
  'port': _ciudadaniaMQTTPort
};

/// TERMINOS Y CONDICIONES DE USO
Map<Ambiente, String> _ciudadaniaTerminosCondiciones = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// RUTA OAUTH2 DISCOVERY CONFIGURATION
Map<Ambiente, String> _ciudadaniaOauthDiscovery = {
  Ambiente.PROD: "<api/de/consumo/prod>",
  Ambiente.PREPROD: "<api/de/consumo/preprod>",
  Ambiente.TEST: "<api/de/consumo/test>"
};

/// SCOPES
List<String> _ciudadaniaOauthScopes = <String>[
  'openid',
  'profile',
  'fecha_nacimiento',
  'email',
  'celular',
  'offline_access',
  'me.devices.create',
  'me.devices.delete',
  'me.2fa.read',
  'me.2fa.update',
  'me.email.update',
  'me.phone.update',
  'me.sessions.read',
  'me.password.update'
];

/// CLIENT ID
Map<Ambiente, String> _ciudadaniaOauthClientId = {
  Ambiente.PROD: "client_id_prod",
  Ambiente.PREPROD: "client_id_preprod",
  Ambiente.TEST: "client_id_test"
};
Map<String, dynamic> _ciudadaniaOauth2 = {
  'discovery': _ciudadaniaOauthDiscovery,
  'scopes': _ciudadaniaOauthScopes,
  'clientId': _ciudadaniaOauthClientId,
  'redirect': "<redirect_uri>",
  'store': "<ruta playstore/appstore>"
};

class Constantes {
  static const Ambiente ambiente = Ambiente.TEST;

  static final String urlGobBoTramites = _gobBoTramites[ambiente];
  static final String urlDirectorioServicios = _directorioServicios[ambiente];
  static final String urlCiudadania = _ciudadaniaProvider[ambiente];
  static final String urlCiudadaniaServiciosDigitales =
  _ciudadaniaServiciosDigitalesWebView[ambiente];
  static final String urlCiudadaniaServiciosDigitalesApiRest =
  _ciudadaniaServiciosDigitalesApiRest[ambiente];
  static final String urlNotificacionesConfiguracion =
  _ciudadaniaNotificaciones['configuracion'][ambiente];
  static final String urlNotificacionesBandeja =
  _ciudadaniaNotificaciones['bandeja'][ambiente];
  static final String urlBasePreRegistroForm =
  _ciudadaniaPreregistro['base'][ambiente];
  static final String urlBasePreRegistroEntidadesSucursales =
  _ciudadaniaPreregistro['sucursales'][ambiente];
  static final String urlBasePreRegistroEntidades =
  _ciudadaniaPreregistro['entidades'][ambiente];
  static final String urlSocket = _ciudadaniaPreregistro['socket'][ambiente];
  static final String urlPathSocket =
  _ciudadaniaPreregistro['path_socket'][ambiente];
  static final String socketCertURi =
  _ciudadaniaPreregistro['certificado'][ambiente];
  static final String urlBasePreBuzonLogin = _preBuzon['login'][ambiente];
  static final String urlBasePreBuzon = _preBuzon['bandeja'][ambiente];
  static final String urlBasePortalNotPreBuzon =
  _preBuzon['configuracion'][ambiente];
  static final String urlVerificarVersion = _ciudadaniaVersion[ambiente];
  static final String urlMQTT = _ciudadaniaMQTT['server'][ambiente];
  static final String usuarioMQTT = _ciudadaniaMQTT['user'][ambiente];
  static final String passwordUsuarioMQTT =
  _ciudadaniaMQTT['password'][ambiente];
  static final int portMQTT = _ciudadaniaMQTT['port'][ambiente];
  static final String urlBasePreTerminosCondiciones =
  _ciudadaniaTerminosCondiciones[ambiente];
  static final String urlIsuer = urlCiudadania;
  static final String discoveryURL = _ciudadaniaOauth2['discovery'][ambiente];
  static final List<String> scopes = _ciudadaniaOauth2['scopes'];
  static final String clientID = _ciudadaniaOauth2['clientId'][ambiente];
  static final String redirectURL = _ciudadaniaOauth2['redirect'];
  static final String urlStore = _ciudadaniaOauth2['store'];
}
