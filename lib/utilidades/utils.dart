import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image/image.dart';
import 'package:lzstring/lzstring.dart';
import 'package:package_info/package_info.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zxcvbn/zxcvbn.dart';

import 'Constantes.dart';
import 'colores.dart';

/// Objeto que estima el nivel de seguridad de la contraseña
final estimadorFortaleza = new Zxcvbn();

/// Patrón para terminaciones de archivo con .jpg o .jpeg
const Pattern jpgPattern = r"\.(jpeg|jpg)$";
final RegExp jpgRegEx = RegExp(jpgPattern);

/// clase con métodos para usar en toda la aplicación
class Utilidades {
  /// Almacenamiento seguro
  static final storage = new FlutterSecureStorage();

  /// Método que almacena información en almacenamiento seguro
  static Future<void> saveSecureStorage({key, value}) async {
    await storage.write(key: key, value: value);

    Map<String, String> allValues = await storage.readAll();
    Utilidades.imprimir(
        "Valores despues de guardar ✅: $key:$value: $allValues");
  }

  /// Método que elimina información en almacenamiento seguro
  static Future<void> deleteAllSecureStorage() async {
    Map<String, String> allValues = await storage.readAll();
    Utilidades.imprimir("Valores antes de eliminar: $allValues");

    await storage.deleteAll();

    allValues = await storage.readAll();
    Utilidades.imprimir("Valores despues de eliminar ✅: $allValues");
  }

  /// Método que lee los valores del almacenamiento seguro
  static Future<Map<String, String>> readAllSecureStorage() async {
    Map<String, String> allValues = await storage.readAll();
    return allValues;
  }

  /// Método que lee un valor del almacenamiento seguro
  static Future<String> readSecureStorage({String key}) async {
    return await storage.read(key: key);
  }

  /// Función que completa ceros en un código que no contenga n caracteres
  static String completarZeroIzquierda(String text, int nro) {
    return text.padLeft(nro, '0');
  }

  /// Función que convierte la primera letra en mayuscula
  static String capitalize(String value) {
    if (value.length > 0)
      return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
    else
      return value;
  }

  /// Método que imprime en caso de no estar en entorno de producción
  static void imprimir(String mensaje) {
    if (Constantes.ambiente != Ambiente.PROD)
      // ignore: avoid_print
      print("${Trace.current().frames[1].member} -> $mensaje");
  }

  /// Función que describe una fecha y hora a partir de un campo datetime
  static String parseHoraFecha(
      {String fechaInicial,
      bool fechaRequerida = true,
      String separador = '/',
      bool horaRequerida = true,
      bool mesNumerico = false}) {
    List<String> monthArray = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    DateTime date = DateTime.parse(fechaInicial).toLocal();

    String parsed = horaRequerida
        ? '${completarZeroIzquierda(date.hour.toString(), 2)}:${completarZeroIzquierda(date.minute.toString(), 2)}'
        : '';
    if (fechaRequerida)
      parsed =
          '${completarZeroIzquierda(date.day.toString(), 2)}$separador${mesNumerico ? completarZeroIzquierda(date.month.toString(), 2) : monthArray[date.month]}$separador${date.year} $parsed';
    return parsed.trimRight();
  }

  /// Método que abre una URL
  static Future abrirURL(String url) async {
    try {
      Utilidades.imprimir("Abriendo $url 🌎");

      if (Uri.parse(url).isAbsolute) {
        if (await canLaunch(url)) {
          await launch(url,
              statusBarBrightness: Brightness.light,
              enableJavaScript: true,
              forceSafariVC: false,
              forceWebView: false);
        } else {
          Utilidades.imprimir("No se puede abrir URL: $url");
          // showToast(mensaje: "No se puede abrir URL: $url", danger: true);
        }
      } else {
        Utilidades.imprimir("No es una URL: $url");
      }
    } catch (error) {
      Utilidades.imprimir("Error al abrir URL: $url - $error");
      // showToast(mensaje: "Error al abrir URL: $url", danger: true);
    }
  }

  /// Método que obtiene la versión de la aplicación
  static Future<String> versionAplicacion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    return versionName;
  }

  /// Método que convierte html en una cadena
  static String loadHtmlFromString(String body) {
    String url = Uri.dataFromString("""<!DOCTYPE html>
    <html>
      <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
      <body style='"margin: 0; padding: 0;'>
        <div>
          $body
        </div>
      </body>
    </html>""", mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString();
    return url;
  }

  /// Método que convierte una cadena en base64
  static String toBase64(String value) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(value);
  }

  /// Método alternativo para codificar a base64 para uso con el proveedor de Ciudadanía
  static String haciaBase64(String value) {
    return base64Encode(Uri.encodeFull(value).codeUnits);
  }

  /// Método que convierte base64 en una cadena
  static String fromBase64(String value) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.decode(value);
  }

  /// Método alternativo para decodificar de base64 para uso con el proveedor de Ciudadanía
  static Uint8List desdeBase64(String value) {
    return base64Decode(Uri.decodeFull(value));
  }

  /// Método que comprime un archivo
  static Future<String> compresionLZString(String path) async {
    final bytes = await File(path).readAsBytes();
    Utilidades.imprimir('LENGTH BYTES: ${bytes.length}');
    String encoded64 = base64Encode(bytes);
    Utilidades.imprimir('LENGTH STRING BASE64: ${encoded64.length}');
    String compressed64 = await LZString.compressToUTF16(encoded64);
    Utilidades.imprimir('LENGTH STRING LZ: ${compressed64.length}');
    return compressed64;
  }

  /// Método que crea una cabecera genérica
  static Future<Map<String, String>> cabeceraUserAgent() async {
    var esEmulador = await Dispositivo.esEmulador();
    var dispositivo = await Dispositivo.getModel();
    var fingerprint = await Dispositivo.getId();
    String pais = await Dispositivo.getCountryCode();
    String carrierName = await Dispositivo.getCarrierName();

    return {
      "pais": pais,
      "operador": carrierName,
      "esEmulador": esEmulador.toString(),
      "dispositivo": dispositivo,
      "fingerprint": fingerprint
    };
  }

  /// Método refactorizado para test unitarios
  static Future<String> saveSecureStorageTest(
      {FlutterSecureStorage storage, key, value}) async {
    await storage.write(key: key, value: value);

    return "Valores despues de guardar ✅: $key:$value";
  }

  /// Método refactorizado para test unitarios
  static Future<Map> deleteAllSecureStorageTest(
      FlutterSecureStorage storage) async {
    await storage.deleteAll();

    Map allValues = await storage.readAll();
    return allValues;
  }

  /// Método refactorizado para test unitarios
  static Future<Map<String, String>> readAllSecureStorageTest(
      FlutterSecureStorage storage) async {
    Map<String, String> allValues = await storage.readAll();
    return allValues;
  }

  /// Método refactorizado para test unitarios
  static Future<String> readSecureStorageTest(
      {FlutterSecureStorage storage, String key}) async {
    return await storage.read(key: key);
  }

  /// Método que obtiene el complemento de un carnet
  static String obtenerComplemento(String ci) {
    return ci.contains("-") ? ci.split("-").last : "";
  }

  /// Método que obtiene el carnet
  static String obtenerCarnet(String ci) {
    return ci.split("-").first;
  }

  /// Método que calcula cantidad de años bisiestos en un rango de años
  /// transcurridos hasta la fecha actual
  static int cantidadAniosBisiestos(int anios) {
    int anioActual = DateTime.now().toLocal().year;
    int cantidad = 0;
    for (int year = anioActual - anios; year <= anioActual; year++) {
      if ((year % 400 == 0) || (year % 4 == 0 && year % 100 != 0)) {
        cantidad++;
      }
    }
    return cantidad;
  }

  /// Método que estima la fortaleza de una contraseña en base a la librería Zxcvbn
  static int estimadorFortalezaPassword(String password) {
    var result = estimadorFortaleza.evaluate(password);
    return result.score.round(); // posibles valores: [0 .. 4]
  }

  /// Método que procesa el horario de atención
  static String obtieneHorario(fecha) {
    if (fecha is String) return fecha;
    String horario = '';
    if (fecha['primero'] != null) {
      if (fecha['primero']['hora_ini'] != null) {
        horario = Utilidades.parseHoraFecha(
            fechaInicial: fecha['primero']['hora_ini'], fechaRequerida: false);
      }
      if (fecha['primero']['hora_fin'] != null) {
        horario +=
            ' - ${Utilidades.parseHoraFecha(fechaInicial: fecha['primero']['hora_fin'], fechaRequerida: false)}';
      }
    }

    if (fecha['segundo'] != null) {
      if (fecha['segundo']['hora_ini'] != null) {
        horario +=
            ' / ${Utilidades.parseHoraFecha(fechaInicial: fecha['segundo']['hora_ini'], fechaRequerida: false)}';
      }
      if (fecha['segundo']['hora_fin'] != null) {
        horario +=
            ' - ${Utilidades.parseHoraFecha(fechaInicial: fecha['segundo']['hora_fin'], fechaRequerida: false)}';
      }
    }

    if (fecha['continuo'] != null) {
      horario += fecha['continuo'] ? ' (horario contínuo)' : '';
    }
    return horario;
  }

  // Método que convierte un archivo JPG a PNG y devuelve la ruta del nuevo archivo
  static String convertJpgToPng(String path) {
    if (jpgRegEx.hasMatch(path)) {
      String pathPng = path.replaceAll(jpgRegEx, '.png');
      var image = decodeImage(new File(path).readAsBytesSync());
      new File(pathPng).writeAsBytesSync(encodePng(image));
      return pathPng;
    }
    return null;
  }

  /// Lista que relaciona un mensaje y un color al nivel de seguridad de la contraseña
  static List<dynamic> seguridadContrasenia = [
    {
      'mensaje': 'Contraseña muy insegura',
      'color': ColorApp.colorPass1,
    },
    {
      'mensaje': 'Contraseña muy débil',
      'color': ColorApp.colorPass2,
    },
    {
      'mensaje': 'Contraseña débil',
      'color': ColorApp.colorPass3,
    },
    {
      'mensaje': 'Contraseña segura',
      'color': ColorApp.colorPass4,
    },
    {
      'mensaje': 'Contraseña muy segura',
      'color': ColorApp.colorPass5,
    },
  ];

  static bool versionMenorQue(String versionLocal, String versionOnline) {
    List<String> arrayVersionLocal = versionLocal.split('.');
    List<String> arrayVersionOnline = versionOnline.split('.');

    if (arrayVersionOnline.length == arrayVersionLocal.length &&
        arrayVersionOnline.length == 3) {
      if (int.parse(arrayVersionLocal[0]) > int.parse(arrayVersionOnline[0])) {
        return false;
      }
      bool majorUpgrade =
          int.parse(arrayVersionLocal[0]) < int.parse(arrayVersionOnline[0]);

      if (!majorUpgrade) {
        if (int.parse(arrayVersionLocal[1]) <
            int.parse(arrayVersionOnline[1])) {
          return true;
        } else if (int.parse(arrayVersionLocal[2]) <
            int.parse(arrayVersionOnline[2])) {
          return true;
        }
      } else
        return true;
    }
    return false;
  }

  /// Función que procesa el mensaje en una respuesta, tambien indica la cantidad de intentos en caso de que se requiera, según formato del proveedor

  static String obtenerMensajeRespuesta(dynamic respuesta) {
    try {
      String mensaje =
          "${respuesta["mensaje"] ?? respuesta["message"] ?? respuesta["error"] ?? "Solicitud erronea"}";

      if (respuesta["error"] != null &&
          ["invalid_token_error", "invalid_token"]
              .contains(respuesta["error"])) {
        mensaje = "Sesión expirada";
      }

      return mensaje;
    } catch (error) {
      Utilidades.imprimir(
          "Error interpretando el mensaje '${respuesta.toString()}' ✉️: ${error.toString()}");
      return respuesta.toString();
    }
  }
}
