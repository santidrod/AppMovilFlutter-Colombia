import 'dart:async';

import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/InformacionPersonal.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/servicios/MessageBus.dart';
import 'package:ciudadaniadigital/utilidades/servicios/ServiceLocator.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

import 'Elementos.dart';
import 'opciones/ConfiguracionesWidget.dart';

class PerfilWidget extends StatefulWidget {
  /// Indicador para bloquear la vista
  final bool bloquear;

  /// Texto que viene de la vista Home
  final String texto;

  const PerfilWidget({Key key, this.bloquear, this.texto}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PerfilWidgetState();
  }
}

class _PerfilWidgetState extends State<PerfilWidget> {
  _PerfilWidgetState();

  /// Información del usuario
  String _userInfo = '';

  /// Indicador para mostrar progreso
  bool _mostrarProgreso = false;

  /// Variable para obtener los mensajes del bus
  ButtonMessageBus _messageBus = locator<ButtonMessageBus>();

  /// Suscripcion para id's de pestaña seleccionada entrantes
  StreamSubscription<int> messageSubscription;

  @override
  void initState() {
    super.initState();
    // obtenerPerfil();
    // suscribe el 'listener' para id de pestaña entrante
    messageSubscription = _messageBus.idStream.listen(_idReceived);
  }

  @override
  void dispose() {
    messageSubscription.cancel();
    super.dispose();
  }

  /// Método que recibe los id recibidos de las pestañas seleccionadas
  void _idReceived(int id) {
    if (id == 2) {
      // pestaña notificaciones activa
      obtenerPerfil();
    }
  }

  /// Método que obtiene la información de perfil
  Future obtenerPerfil() async {
    _userInfo = await Utilidades.readSecureStorage(key: "nombreUsuario");
    setState(() {});
  }

  /// Widget que muestra foto de perfil genérica
  Widget perfil() {
    return Container(
      child: Image.asset(
        'assets/images/celular.png',
        width: 150,
      ),
    );
  }

  /// Widget que muestra un mensaje de bienvenida al usuario que inicio sesión
  Widget bienvenida() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
      child: Text(
        "Bienvenid@, $_userInfo",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Widget que muestra indicaciones acerca de la aplicación
  Widget indicaciones() {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Text(
        "Administra tu ciudadanía digital, tu información, accede a los servicios digitales, recibe y administra tus notificaciones electrónicas y aprueba documentos",
        style: TextStyle(color: ColorApp.greyText, fontSize: 12),
      ),
    );
  }

  /// Widget las opciones de la vista

  Widget opciones() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Container(
            width: 400,
            height: 43,
            padding: EdgeInsets.only(left: 30, right: 30),
            margin: EdgeInsets.only(top: 20, bottom: 8),
            child: FlatButton(
              child: Text(
                "Información personal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
              onPressed: () async {
                if (!_mostrarProgreso) {
                  await Dialogo.showNativeModalBottomSheet(
                      context, InformacionPersonal());
                } else {
                  Utilidades.imprimir(
                      "Petición en progreso, función deshabilitada ⏳");
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(color: ColorApp.greyText)),
            )),
        Container(
            width: 400,
            height: 43,
            padding: EdgeInsets.only(left: 30, right: 30),
            margin: EdgeInsets.only(top: 8, bottom: 8),
            child: FlatButton(
              child: Text(
                "Configuración",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
              onPressed: () async {
                if (!_mostrarProgreso) {
                  await Dialogo.showNativeModalBottomSheet(
                      context, ConfiguracionesWidget());
                } else {
                  Utilidades.imprimir(
                      "Petición en progreso, función deshabilitada ⏳");
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(color: ColorApp.greyText)),
            )),
        Container(
            width: 400,
            height: 43,
            padding: EdgeInsets.only(left: 30, right: 30),
            margin: EdgeInsets.only(top: 8, bottom: 8),
            child: FlatButton(
              child: Text(
                "Cerrar sesión",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: ColorApp.alert),
              ),
              onPressed: () async {
                if (!_mostrarProgreso) {
                  Dialogo.mostrarDialogoNativo(
                      context,
                      "Alerta",
                      Text("¿Está seguro que desea cerrar sesión?"),
                      "Aceptar", () async {
                    estadoCarga(mostrarProgreso: true);
                    await Sesion.cerrarSesion(context, proveedor: true)
                        .whenComplete(
                            () => estadoCarga(mostrarProgreso: false));
                  },
                      secondButtonText: "Cancelar",
                      secondCallback: () {},
                      secondActionStyle: ActionStyle.important);
                } else {
                  Utilidades.imprimir(
                      "Petición en progreso, función deshabilitada ⏳");
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(color: ColorApp.alert)),
            )),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  /// Método que cambia el estado de una petición activa
  void estadoCarga({bool mostrarProgreso}) {
    if (mounted) {
      setState(() {
        _mostrarProgreso = mostrarProgreso;
      });
    } else {
      Utilidades.imprimir(
          "Widget no montado, no se cambiara el progreso en el perfil 👨‍💻");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Elementos.cabeceraLogos3(),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: 200,
              padding: EdgeInsets.only(top: 20, bottom: 20, left: 0, right: 0),
              child: Visibility(
                visible: _mostrarProgreso,
                child: Elementos.indicadorProgresoLineal(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                perfil(),
                bienvenida(),
                indicaciones(),
                opciones()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
