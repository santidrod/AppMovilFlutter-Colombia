import 'dart:io';

import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:device_info/device_info.dart';
import 'package:flt_telephony_info/flt_telephony_info.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'package:trust_fall/trust_fall.dart';

/// Clase que define métodos del dispositivo
class Dispositivo {
  /// Objeto de define métodos del dispositivo
  static DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  /// Identificador único del dispositivo
  static Future getId() async {
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  /// Código de país
  static Future getCountryCode() async {
    var info = await FltTelephonyInfo.info;
    String countryCode =  info.networkCountryIso ?? "no disponible";
    return (countryCode.isEmpty || countryCode.toLowerCase().compareTo('unavailable') == 0) ? "no disponible" : countryCode;
  }

  /// Nombre de operadora
  static Future getCarrierName() async {
    try {
      var info = await FltTelephonyInfo.info;
      String carrierName = info.simOperatorName ?? "no disponible";
      return (carrierName.isEmpty || carrierName.toLowerCase().compareTo('unavailable') == 0) ? "no disponible" : carrierName;
    } catch (error) {
      Utilidades.imprimir("Operadora no disponible: $error");
      return "no disponible";
    }
  }

  ///Indicador de ejecución un emulador
  static Future<bool> esEmulador() async {
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return !iosDeviceInfo.isPhysicalDevice;
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return !androidDeviceInfo.isPhysicalDevice;
    }
  }

  /// Indicador de ejecución una tablet
  static bool esTablet() {
    return Device.get().isTablet;
  }

  /// Método que obtiene el signature de la aplicación
  static Future<void> mostrarSignature() async {
    try {
      String signature = await SmsRetrieved.getAppSignature();
      Utilidades.imprimir("signature: $signature");
    } catch (error) {
      Utilidades.imprimir(error);
    }
  }

  /// Indicadores de dispositivos rooteado
  static Future<bool> esRooteado() async {
    return await TrustFall.isJailBroken;
  }

  /// Indicadores de dispositivos rooteado 2
  static Future<bool> esRooteado2() async {
    return await FlutterJailbreakDetection.jailbroken;
  }

  /// Indicadores de ejecución en almacenamiento externo
  static Future<bool> almacenamientoExterno() async {
    return await TrustFall.isOnExternalStorage;
  }

  /// Método que valida ejecución insegura
  static Future<bool> ejecucionInsegura() async {
    return /*await sslPiningInsecure() ||*/ (Platform.isAndroid ? await esRooteado() || await almacenamientoExterno() : await esRooteado());
    //return await esRooteado2();
  }

  /// Método contiene el nombre del modelo
  static Future<String> getModel() async {
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.localizedModel;
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.model;
    }
  }

//  static Future<bool> sslPiningInsecure() async {
//    Utilidades.imprimir('iniciando verificacion ssl pinning a ruta ==> ${Constantes.urlCiudadania}...');
//    var byteCert = await rootBundle.load(Constantes.ambiente == Ambiente.PROD
//        ? 'assets/raw/cuenta.ciudadaniadigital.agetic.gob.bo.der'
//        : 'assets/raw/account-idetest.agetic.gob.bo.der');
//    var sha256Cert = sha256.convert(byteCert.buffer.asUint8List());
//    List<String> fingerprints = new List();
//    fingerprints.add(sha256Cert.toString());
//    try {
//      String checked = await SslPinningPlugin.check(
//          serverURL: Constantes.urlCiudadania, headerHttp: new Map(), sha: SHA.SHA256, allowedSHAFingerprints: fingerprints, timeout: 120);
//      Utilidades.imprimir('CHECKED... $checked');
//      return false;
//    } catch (e) {
//      Utilidades.imprimir('EXCEPCION SSL PINING... ${e.toString()}');
//      return true;
//    }
//  }
}
