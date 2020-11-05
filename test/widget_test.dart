// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ciudadaniadigital/pages/Inicio/login_page.dart';
import 'package:ciudadaniadigital/pages/Inicio/widgets/ListaOpcionesWidget.dart';
import 'package:ciudadaniadigital/pages/PreBuzon/detalle_notificacion.dart';
import 'package:ciudadaniadigital/pages/PreBuzon/pre_buzon_main.dart';
import 'package:ciudadaniadigital/pages/alert_page.dart';
import 'package:ciudadaniadigital/pages/autoregistro/camara_vista.dart';
import 'package:ciudadaniadigital/pages/autoregistro/finalizadoRemoto.dart';
import 'package:ciudadaniadigital/pages/autoregistro/finalizado_vista.dart';
import 'package:ciudadaniadigital/pages/autoregistro/horario_llamada.dart';
import 'package:ciudadaniadigital/pages/autoregistro/informacion_carnet.dart';
import 'package:ciudadaniadigital/pages/autoregistro/metodo_verificacion_llamada.dart';
import 'package:ciudadaniadigital/pages/autoregistro/metodo_verificacion_permiso.dart';
import 'package:ciudadaniadigital/pages/autoregistro/metodo_verificacion_vista.dart';
import 'package:ciudadaniadigital/pages/autoregistro/registro_celular.dart';
import 'package:ciudadaniadigital/pages/autoregistro/registro_correo.dart';
import 'package:ciudadaniadigital/pages/autoregistro/registro_datos_personales.dart';
import 'package:ciudadaniadigital/pages/autoregistro/verificacion_celular.dart';
import 'package:ciudadaniadigital/pages/autoregistro/verificacion_correo.dart';
import 'package:ciudadaniadigital/pages/autoregistro/verificado_vista.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/NotificacionesWidget.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/ConfiguracionesWidget.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/PerfilWidget.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/ServicioVistaWeb.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/ServiciosWidget.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/actualizar_datos.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/ConfiguracionNotificaciones.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/InformacionAppWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
}

void main() {
  group('Inicial', () {
    testWidgets('Boton registrarse', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(LoginPage()));
      expect(find.text("Regístrate aquí"), findsOneWidget);
    });
    testWidgets('Boton ingresar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(LoginPage()));
      expect(find.text("Ingresar"), findsOneWidget);
    });
    testWidgets('Tercer opción Menu Login', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(LoginPage()));
      expect(find.text("Servicios Digitales"), findsOneWidget);
    });
    testWidgets('Cuarta opción Menu Login', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(LoginPage()));
      expect(find.text("Notificaciones electrónicas"), findsOneWidget);
    });
    testWidgets('Lista de opciones', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Column(
        children: ListaOpciones.opciones(null),
      )));
    });
    testWidgets('Primera opción Menu Login', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(LoginPage()));
      expect(find.text("Identidad digital"), findsOneWidget);
    });
    testWidgets('Segunda opción Menu Login', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(LoginPage()));
      expect(find.text("gob.bo"), findsOneWidget);
    });

    testWidgets('Alerta - Ejecución insegura', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AlertaPage()));
    });
  });

  group('Pre Buzón', () {
    testWidgets('Detalle de notificación', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(DetalleNotificacion(
        idCiudadano: "",
        token: "",
        notificacion: null,
      )));
    });
    testWidgets('Login Pre Buzón', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PreBuzonMain()));
    });
  });

  group('Home', () {
    /*testWidgets('Home', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(HomePage(
        actualizarSesion: false,
      )));
    });*/

    testWidgets('Servicios widget textos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ServiciosWidget()));
      expect(find.text("Estos son los servicios digitales del Estado Plurinacional de Bolivia a los que puedes acceder:"), findsOneWidget);
    });

    testWidgets('Notificaciones', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(NotificacionesWidget()));
    });

    testWidgets('Servicios vista web', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ServiciosVistaWeb()));
    });

    testWidgets('Servicios widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ServiciosWidget()));
    });

    testWidgets('Notificaciones widget textos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(NotificacionesWidget()));
      expect(find.text('No tiene notificaciones disponibles en su bandeja'), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('Destacadas'), findsOneWidget);
      expect(find.text('Leídas'), findsOneWidget);
      expect(find.text('Sin Leer'), findsOneWidget);
    });

    testWidgets('Perfil', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PerfilWidget()));
    });

    testWidgets('Perfil widget textos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PerfilWidget()));
      expect(
          find.text(
              "Administra tu ciudadanía digital, tu información, accede a los servicios digitales, recibe y administra tus notificaciones electrónicas y aprueba documentos"),
          findsOneWidget);
      expect(find.text("Información personal"), findsOneWidget);
    });

    testWidgets('Opciones', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ConfiguracionesWidget()));
    });

    testWidgets('Cambiar Contraseña', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ActualizarDatosWidget()));
    });

    testWidgets('Configurar notificaciones', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ConfiguracionNotificaciones()));
    });

    testWidgets('Información App', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(InformacionApp()));
    });
  });

  group('Auto registro', () {
    /*testWidgets('Vista principal', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AutoRegistroPage()));
    });*/

    testWidgets('Registro Celular', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: RegistroCelular())));
    });

    testWidgets('Verificación Celular', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: VerificacionCelular())));
    });

    testWidgets('Registro Correo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: RegistroCorreo())));
    });

    testWidgets('Verificación Correo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: VerificacionCorreo())));
    });

    testWidgets('Vista verificación correcta', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: VerificadoVista())));
    });

    testWidgets('Datos personales', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: RegistroDatosPersonales())));
    });

    testWidgets('Información Carnet', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: InformacionCarnet())));
    });

    testWidgets('Metodo Verificación llamada', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: MetodoVerificacionLlamadaWidget())));
    });

    testWidgets('Metodo Verificación permiso', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: MetodoVerificacionPermisoWidget())));
    });

    testWidgets('Metodo Verificación opciones', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: MetodoVerificacionOpcionesWidget())));
    });

    testWidgets('Horario llamada', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: HorarioLlamada())));
    });

    testWidgets('Vista de Cámara', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(TakePictureScreen(
        cameras: [],
        opcionFoto: tipoFoto.Selfie,
      )));
    });

    testWidgets('Finalizado registro remotamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(FinalizadoRemoto()));
    });

    testWidgets('Finalizado registro presencialmente ', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Scaffold(body: FinalizadoVista())));
    });
  });
}
