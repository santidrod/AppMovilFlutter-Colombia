import 'dart:async';
import 'dart:io';

import 'package:ciudadaniadigital/models/PushNotification.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/NotificacionesWidget.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/PerfilWidget.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/servicios/MessageBus.dart';
import 'package:ciudadaniadigital/utilidades/servicios/NotificationHelper.dart';
import 'package:ciudadaniadigital/utilidades/servicios/ServiceLocator.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'AccesoWidget.dart';
import 'ServiciosWidget.dart';
import 'opciones/StatusAppBar.dart';

/// Viste que contienen los widgets que puede ver un usuario que inicio sesión
class HomePage extends StatefulWidget {
  /// Indicador para actualizar la sesión
  final bool actualizarSesion;

  HomePage({@required this.actualizarSesion});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  /// Indicador de pestaña actual
  int _currentIndex = 0;

  /// Indicador de conexión a internet
  bool internetstatus = true;

  /// Indicador de progreso en actualizar la sesión
  bool verificandoSesion = true;

  List<Widget> _children = [];

  /// Hora a la que el access_token expira, para actualizar la sesión
  int accessTokenExpirationDateTime = 0;

  /// Bus para publicar id de pestaña seleccionada
  ButtonMessageBus _messageBus;

  /// Variable para obtener los mensajes push del bus
  PushMessageBus _pushMessageBus;

  /// Suscripcion para push entrante (listener)
  StreamSubscription<PushNotification> pushSubscription;

  /// Variable para obtener los mensajes push del bus
  PushTouchedMessageBus _pushTouchedMessageBus;

  /// Suscripcion para push pulsado (listener)
  StreamSubscription<String> pushTouchedSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized();
    inicializar();

    inicializaBusComunicaciones();
  }

  /// Método que se activa en caso de iniciar la aplicación con un usuario logueado, actualiza la sesión
  void inicializar() {
    if (widget.actualizarSesion) {
      actualizarOauth();
    } else {
      setState(() {
        verificandoSesion = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Utilidades.imprimir("AppLifecycleState: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        Utilidades.imprimir("state 🤖: resumed");
        break;
      case AppLifecycleState.inactive:
        Utilidades.imprimir("state 🤖: inactive");
        break;
      case AppLifecycleState.paused:
        Utilidades.imprimir("state 🤖: paused");
        break;
      case AppLifecycleState.detached:
        Utilidades.imprimir("state 🤖: detached");
        break;
    }
  }

  /// método actualiza la sesión OAuth
  Future<void> actualizarOauth() async {
    Utilidades.imprimir("Operación OAuth iniciada 📡");
    try {
      if (await Services.conexionInternet()) {
        await Sesion.actualizarOAUTH().then((value) {
          Utilidades.imprimir("OAuth actualizado ✅");
          verificandoSesion = false;
          if (mounted) {
            setState(() {});
          }
        }).catchError((onError) async {
          Utilidades.imprimir("Error al actualizar OAuth 🥾: $onError");
          await Sesion.cerrarSesion(context, proveedor: true);
        }).whenComplete(() {
          Utilidades.imprimir("Operación OAuth terminada 📡");
        });
      } else {
        Utilidades.imprimir(
            "No se actualizara OAuth, no esta conectado a internet 🌍 ");
      }
    } catch (error) {
      Utilidades.imprimir("error actualizando OAuth: $error");
      await Sesion.cerrarSesion(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pushTouchedSubscription.cancel();
    pushSubscription.cancel();
    super.dispose();
  }

  /// Método que cambia el status del appbar que muestra mensajes y actualiza la sesión cuando se reanuda la conexión a internet
  void habilitar({bool habilitado, bool actualizar}) {
    Utilidades.imprimir("actualizar sesión: $actualizar");
    setState(() {
      internetstatus = habilitado;
    });
    if (actualizar) {
      inicializar();
    }
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      ServiciosWidget(bloquear: false, texto: "Servicios"),
      NotificacionesWidget(bloquear: false, texto: "Notificaciones"),
      PerfilWidget(bloquear: false, texto: "Perfil"),
      AccesoWidget(bloquear: false, texto: "Código de seguridad"),
    ];

    return Scaffold(
      appBar: StatusAppbar(accionCambioStatusAppBar: habilitar),
      body: verificandoSesion
          ? Center(child: Text('Actualizando sesión...'))
          : IndexedStack(
              children: _children,
              index: _currentIndex,
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 10,
        unselectedFontSize: 9.5,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            Utilidades.imprimir("📌 $_currentIndex");

            // if (_currentIndex != 0) {
            // publicamos id de pestaña notificaciones
            if (_messageBus != null) _messageBus.broadcastId(_currentIndex);
            // }
          });
        },
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              activeIcon: Image.asset(
                'assets/images/icon_file.png',
                height: 22,
                width: 15,
                color: ColorApp.btnBackground,
              ),
              icon: Image.asset(
                'assets/images/icon_file.png',
                height: 22,
                width: 15,
              ),
              label: 'Servicios'),
          BottomNavigationBarItem(
            activeIcon: Image.asset(
              'assets/images/icon_notification.png',
              height: 22,
              width: 15,
              color: ColorApp.btnBackground,
            ),
            icon: Image.asset(
              'assets/images/icon_notification.png',
              height: 22,
              width: 15,
            ),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
              activeIcon: Image.asset(
                'assets/images/icon_user.png',
                height: 22,
                width: 15,
                color: ColorApp.btnBackground,
              ),
              icon: Image.asset(
                'assets/images/icon_user.png',
                height: 22,
                width: 15,
              ),
              label: 'Mi Perfil'),
          BottomNavigationBarItem(
              activeIcon: Image.asset(
                'assets/images/icon_lock2.png',
                height: 22,
                width: 15,
                color: ColorApp.btnBackground,
              ),
              icon: Image.asset(
                'assets/images/icon_lock2.png',
                height: 22,
                width: 15,
              ),
              label: 'Seguridad'),
        ],
      ),
    );
  }

  /// Método que inicializa comunicaciones y 'listeners'
  Future<void> inicializaBusComunicaciones() async {
    // Configura el bus de comunicacion
    if (!locator.isRegistered<ButtonMessageBus>()) {
      locator.registerSingleton<ButtonMessageBus>(ButtonMessageBus(),
          signalsReady: true);
    }
    _messageBus = locator<ButtonMessageBus>();
    if (!locator.isRegistered<PushMessageBus>()) {
      locator.registerSingleton<PushMessageBus>(PushMessageBus(),
          signalsReady: true);
    }
    _pushMessageBus = locator<PushMessageBus>();
    if (!locator.isRegistered<PushTouchedMessageBus>()) {
      locator.registerSingleton<PushTouchedMessageBus>(PushTouchedMessageBus(),
          signalsReady: true);
    }
    _pushTouchedMessageBus = locator<PushTouchedMessageBus>();

    // inicializa notificaciones para push
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    await initNotifications(flutterLocalNotificationsPlugin);
    if (Platform.isIOS) requestIOSPermissions(flutterLocalNotificationsPlugin);

    // suscribe el 'listener' para mensaje push entrante
    pushSubscription =
        _pushMessageBus.pushStream.listen(_mostrarNotificacionPush);

    // suscribe el 'listener' para push pulsado
    pushTouchedSubscription = _pushTouchedMessageBus.pushTouchedStream
        .listen(_mostrarBandejaNotificaciones);
  }

  void _mostrarNotificacionPush(PushNotification pushNotification) {
    showNotification(flutterLocalNotificationsPlugin, pushNotification);
  }

  Future<void> _mostrarBandejaNotificaciones(String payload) async {
    String lastPayload = await Utilidades.readSecureStorage(key: 'payload');
    if (lastPayload == null || lastPayload.compareTo(payload) != 0) {
      Utilidades.imprimir('PUSH PULSADO, MOSTRANDO BANDEJA');
      _currentIndex = 1;
      _messageBus.broadcastId(_currentIndex);
      setState(() {});
      await Utilidades.saveSecureStorage(key: 'payload', value: payload);
    }
  }
}
