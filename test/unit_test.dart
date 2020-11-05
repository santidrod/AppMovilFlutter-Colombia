import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:ciudadaniadigital/utilidades/validaciones.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('Utilidades', () {
    test('Completando a la izquierda ⏮', () {
      String valor = Utilidades.completarZeroIzquierda("11", 4);
      expect(valor, "0011");
    });

    test('Letra capital 🔠', () {
      String valor = Utilidades.capitalize("hola mundo");
      expect(valor, "Hola mundo");
    });

    test('Convertir a Base64 🔠', () {
      String valor = Utilidades.toBase64("hola mundo");
      expect(valor, "aG9sYSBtdW5kbw==");
    });

    test('Convertir de Base64 🔡', () {
      String valor = Utilidades.fromBase64("aG9sYSBtdW5kbw==");
      expect(valor, "hola mundo");
    });

    test('Cabeceras con información del telefono 📱', () {
      String valor = Utilidades.fromBase64("aG9sYSBtdW5kbw==");
      expect(valor, "hola mundo");
    });

    test('Formateando fecha y hora📱', () {
      String fecha = Utilidades.parseHoraFecha(fechaInicial: "2020-09-01T10:30:00.412Z");
      expect(fecha, "01/Septiembre/2020 06:30");
    });

    test('Formateando fecha📱', () {
      String fecha = Utilidades.parseHoraFecha(fechaInicial: "2020-12-30T10:30:00.412Z", horaRequerida: false, separador: ' de ');
      expect(fecha, "30 de Diciembre de 2020");
    });

    test('Cargando texto en vista HTML📱', () {
      String htmlString = Utilidades.loadHtmlFromString("<h1>Titulo de pagina</h1><p>Texto de pagina</p>");
      expect(htmlString,
          "data:text/html;charset=utf-8,%3C!DOCTYPE%20html%3E%0A%20%20%20%20%3Chtml%3E%0A%20%20%20%20%20%20%3Chead%3E%3Cmeta%20name=%22viewport%22%20content=%22width=device-width,%20initial-scale=1.0%22%3E%3C/head%3E%0A%20%20%20%20%20%20%3Cbody%20style='%22margin:%200;%20padding:%200;'%3E%0A%20%20%20%20%20%20%20%20%3Cdiv%3E%0A%20%20%20%20%20%20%20%20%20%20%3Ch1%3ETitulo%20de%20pagina%3C/h1%3E%3Cp%3ETexto%20de%20pagina%3C/p%3E%0A%20%20%20%20%20%20%20%20%3C/div%3E%0A%20%20%20%20%20%20%3C/body%3E%0A%20%20%20%20%3C/html%3E");
    });

    test('Obteniendo el carnet de un string📱', () {
      String stringCarnet = '1020304050-1F';
      String carnet = Utilidades.obtenerCarnet(stringCarnet);
      expect(carnet, '1020304050');
    });

    test('Obteniendo el complemento del carnet 1', () {
      String stringCarnet = '1020304050-1F';
      String complemento = Utilidades.obtenerComplemento(stringCarnet);
      expect(complemento, '1F');
    });

    test('Obteniendo el complemento del carnet 2', () {
      String stringCarnet = '1020304050';
      String complemento = Utilidades.obtenerComplemento(stringCarnet);
      expect(complemento, '');
    });

    test('Calculando cantidad de años bisiestos', () {
      int cantidad = Utilidades.cantidadAniosBisiestos(30);
      expect(cantidad, 8);
    });

    test('Estimando la fortaleza de contraseña 1', () {
      String password = 'usuario';
      int fortaleza = Utilidades.estimadorFortalezaPassword(password);
      expect(fortaleza, 2);
    });

    test('Estimando la fortaleza de contraseña 2', () {
      String password = 'Usu4r1@-4g3p1c';
      int fortaleza = Utilidades.estimadorFortalezaPassword(password);
      expect(fortaleza, 4);
    });

    test('Formateando horario desde String', () {
      String horario = '08:00 - 12:00';
      String formato = Utilidades.obtieneHorario(horario);
      expect(formato, horario);
    });

    test('Formateando horario desde Objeto 1', () {
      Map<String, dynamic> horario = {
        'primero': {
          'hora_ini': '2020-09-01T12:00:00.412Z',
          'hora_fin': '2020-09-01T16:00:00.412Z',
        },
        'segundo': {
          'hora_ini': '2020-09-01T18:00:00.412Z',
          'hora_fin': '2020-09-01T22:00:00.412Z',
        },
      };
      String formato = Utilidades.obtieneHorario(horario);
      expect(formato, '08:00 - 12:00 / 14:00 - 18:00');
    });

    test('Formateando horario desde Objeto 2', () {
      Map<String, dynamic> horario = {
        'primero': {
          'hora_ini': '2020-09-01T12:00:00.412Z',
          'hora_fin': '2020-09-01T20:00:00.412Z',
        },
        'continuo': true
      };
      String formato = Utilidades.obtieneHorario(horario);
      expect(formato, '08:00 - 16:00 (horario contínuo)');
    });
  });

  final storage = MockStorage();

  group('SecureStorage', () {
    test('Almacenando dato seguro⏮', () async {
      String key = 'key';
      String value = 'value';

      when(storage.write(key: key, value: value)).thenAnswer((realInvocation) async => "Valores despues de guardar ✅: $key:$value");

      expect(await Utilidades.saveSecureStorageTest(storage: storage, key: key, value: value), "Valores despues de guardar ✅: $key:$value");
    });

    test('Eliminando todos los datos seguros⏮', () async {
      when(storage.deleteAll()).thenAnswer((realInvocation) async => null);

      when(storage.readAll()).thenAnswer((realInvocation) async => {});

      expect(await Utilidades.deleteAllSecureStorageTest(storage), {});
    });

    test('Recuperando todos los datos seguros⏮', () async {
      String key = 'key';
      String value = 'value';
      when(storage.readAll()).thenAnswer((realInvocation) async => {key: value});

      expect(await Utilidades.readAllSecureStorageTest(storage), {key: value});
    });

    test('Recuperando dato seguro⏮', () async {
      String key = 'key';
      String value = 'value';
      when(storage.read(key: key)).thenAnswer((realInvocation) async => value);

      expect(await Utilidades.readSecureStorageTest(storage: storage, key: key), value);
    });
  });

  group('Validaciones', () {
    test('Validando email correcto📱', () {
      bool esCorrecto = Validar.isEmail('correo_test@mail.server.com');
      expect(esCorrecto, true);
    });

    test('Validando email📱 incorrecto', () {
      bool esCorrecto = Validar.isEmail('correo_test.mail.server.com');
      expect(esCorrecto, false);
    });

    test('Validando fecha📱 correcta', () {
      bool esCorrecto = Validar.fecha('27/05/2000');
      expect(esCorrecto, true);
    });

    test('Validando fecha📱 incorrecta', () {
      bool esCorrecto = Validar.fecha('2000/10/10');
      expect(esCorrecto, false);
    });

    test('Validando contraseña📱 segura', () {
      bool esCorrecto = Validar.contrasenia('ContraseñaSegura_2O2O@#');
      expect(esCorrecto, true);
    });

    test('Validando contraseña📱 insegura', () {
      bool esCorrecto = Validar.contrasenia('123456');
      expect(esCorrecto, false);
    });

    test('Validando campo requerido', () {
      String mensaje = 'campo faltante';
      String requerido = Validar.requiredField('campo', mensaje);
      expect(requerido, null);
    });

    test('Validando campo faltante', () {
      String mensaje = 'campo faltante';
      String requerido = Validar.requiredField('', mensaje);
      expect(requerido, mensaje);
    });

    test('Validando celular correcto', () {
      String telefono = '77712345';
      bool correcto = Validar.telefono(telefono);
      expect(correcto, true);
    });

    test('Validando celular incorrecto', () {
      String telefono = '44412345';
      bool correcto = Validar.telefono(telefono);
      expect(correcto, false);
    });

    test('Validando correo institucional', () {
      String email = 'correo_usuario@agetic.gob.bo';
      bool correcto = Validar.esInstitucional(email);
      expect(correcto, true);
    });

    test('Validando correo no institucional', () {
      String email = 'correo_usuario@hotmail.com';
      bool correcto = Validar.esInstitucional(email);
      expect(correcto, false);
    });
  });
}
