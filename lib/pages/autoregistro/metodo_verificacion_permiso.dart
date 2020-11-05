import 'package:ciudadaniadigital/pages/autoregistro/widgets/terminosCondicionesWidget.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import 'package:permission_handler/permission_handler.dart';

/// Variable que indica si el permiso de la cámara a sido habilitado
bool _permissionGranted = false;

/// Viste que informa acerca del permiso de la cámara
class MetodoVerificacionPermisoWidget extends StatefulWidget {
  const MetodoVerificacionPermisoWidget({Key key}) : super(key: key);

  @override
  _MetodoVerificacionPermisoWidgetState createState() =>
      _MetodoVerificacionPermisoWidgetState();

  /// Método que continua con la acción siguiente
  static Future verificadoAccion() async {
    if (_permissionGranted)
      return "";
    else
      return throw ('Debe proporcionar el permiso 🚨');
  }
}

class _MetodoVerificacionPermisoWidgetState
    extends State<MetodoVerificacionPermisoWidget> with WidgetsBindingObserver {
  /// Identificador de permisos de la cámara
  final Permission _permission = Permission.camera;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        Utilidades.imprimir("state ⚙️: resumed");
        checkServiceStatus();
        break;
      case AppLifecycleState.inactive:
        Utilidades.imprimir("state ⚙️: inactive");
        break;
      case AppLifecycleState.paused:
        Utilidades.imprimir("state ⚙️: paused");
        break;
      case AppLifecycleState.detached:
        Utilidades.imprimir("state ⚙️: detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: 40,
          ),
          Container(
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Container(
              alignment: Alignment.bottomCenter,
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              constraints: BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: ColorApp.listFillCell,
              ),
              child: RichText(
                text: TextSpan(
                    style:
                        TextStyle(color: ColorApp.greyDarkText, fontSize: 12),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              "Antes de continuar, necesitamos tu autorización para acceder a la cámara de tu dispositivo."),
                    ]),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: 240,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ColorApp.greyText))),
            child: Column(
              children: [
                if (!_permissionGranted)
                  FlatButton(
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(maxWidth: 500),
                      height: 50,
                      child: Text(
                        'Presiona para conceder el permiso',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorApp.btnBackground, fontSize: 12),
                      ),
                    ),
                    onPressed: () {
                      requestPermission();
                    },
                  ),
                ListTileMoreCustomizable(
                  horizontalTitleGap: 20.0,
                  minVerticalPadding: 0.0,
                  minLeadingWidth: 200.0,
                  title: Text(
                    '  Cámara del dispositivo  ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: _permissionGranted
                            ? ColorApp.greyText
                            : ColorApp.bg,
                        fontSize: 12,
                        backgroundColor:
                            _permissionGranted ? Colors.white : ColorApp.error),
                  ),
                  trailing: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Image.asset(
                      _permissionGranted
                          ? 'assets/images/icon_correct_blue.png'
                          : 'assets/images/icon_wrong.png',
                      width: 20,
                    ),
                  ),
                  onTap: (detalles) {
                    // concedemos permiso
                    requestPermission();
                  },
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () async {
              await Dialogo.showNativeModalBottomSheet(
                  context, TerminosCondiciones());
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: "Revisa los ",
                        style:
                            TextStyle(color: ColorApp.greyText, fontSize: 12)),
                    TextSpan(
                        text: "términos y condiciones.",
                        style: TextStyle(
                            color: ColorApp.btnBackground, fontSize: 12))
                  ]),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Text(
              "Comenzaremos con tu foto “selfie” sosteniendo tu Cédula de Identidad.",
              style: TextStyle(fontSize: 12, color: ColorApp.greyText),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          /*Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Image.asset(
                  "assets/images/imagen-ciudadania-selfie-carnet 1.png",
                  width: 109,
                  height: 133,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "Ubícate justo al frente de la cámara frontal de tu dispositivo móvil sosteniendo tu Carnet de Identidad.",
                    style: TextStyle(color: ColorApp.greyText, fontSize: 11),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),*/
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.only(left: 48, right: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: "Asegúrate de estar dentro de los recuadros",
                            style: TextStyle(
                                color: ColorApp.greyText, fontSize: 11)),
                        TextSpan(
                            text: " rojos ",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                                fontSize: 11)),
                        TextSpan(
                            text: "sosteniendo tu CI. ",
                            style: TextStyle(
                                color: ColorApp.greyText, fontSize: 11)),
                      ]),
                )),
                SizedBox(
                  width: 10,
                ),
                Image.asset(
                  "assets/images/imagen.ciudadania-selfie-carnet 2.png",
                  width: 109,
                  height: 141,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkServiceStatus();
  }

  /// Método que verifica si el permiso sido concedido
  Future<void> checkServiceStatus() async {
    PermissionStatus status = await _permission.status;
    _permissionGranted = status.isGranted;
    Utilidades.imprimir('PERMISSION CAMERA: $_permissionGranted');
    if (mounted) setState(() {});
  }

  /// Método que pide permiso a la cámara
  Future<void> requestPermission() async {
    PermissionStatus status = await _permission.status;

    if (status.isDenied) {
      openAppSettings();
    } else {
      PermissionStatus statusSolicitud;
      Dialogo.mostrarDialogoConfirmacion(
          context,
          "Permiso",
          () async => {
                statusSolicitud = await _permission.request(),
                Utilidades.imprimir(
                    'PERMISSION CAMERA isGranted: ${statusSolicitud.isGranted}'),
                _permissionGranted = statusSolicitud.isGranted,
                Utilidades.imprimir(
                    'PERMISSION CAMERA isDenied: ${statusSolicitud.isDenied}'),
                Utilidades.imprimir(
                    'PERMISSION CAMERA isRestricted: ${statusSolicitud.isRestricted}'),
                Utilidades.imprimir(
                    'PERMISSION CAMERA isPermanentlyDenied: ${statusSolicitud.isPermanentlyDenied}'),
                Navigator.of(context).pop()
              },
          "Haz click en continuar para conceder permiso de acceder a tú cámara móvil");
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
