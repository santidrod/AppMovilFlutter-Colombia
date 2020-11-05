import 'dart:async';

import 'package:ciudadaniadigital/pages/Inicio/login_page.dart';
import 'package:ciudadaniadigital/pages/alert_page.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/home.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utilidades/utils.dart';

/// Método principal que inicia la aplicación

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Utilidades.imprimir("Iniciando aplicación 🚀");

  bool sesionIniciada = await Sesion.sesionIniciada();

  // Verificando sesión iniciada

  Utilidades.imprimir("sesionIniciada 🤖: $sesionIniciada");

  // Definiendo orientación por defecto del dispositivo

  if (!Dispositivo.esTablet())
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Verificando si el dispositivo esta rooteado o con JailBreak o si la aplicación esta en una memoria externa
  bool ejecucionInsegura = await Dispositivo.ejecucionInsegura();

  runApp(MaterialApp(
    theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: ColorApp.btnBackground,
        accentColor: ColorApp.btnBackground),
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.light,
    home: Elementos.bannerEntorno(
      child: ejecucionInsegura
          ? AlertaPage()
          : (sesionIniciada
              ? HomePage(
                  actualizarSesion: false,
                )
              : LoginPage()),
    ),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ],
    supportedLocales: [
      const Locale('es'), // Español
    ],
  ));
}
