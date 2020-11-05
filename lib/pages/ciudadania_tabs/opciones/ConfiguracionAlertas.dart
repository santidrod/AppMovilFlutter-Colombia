import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class ConfiguracionAlertas extends StatefulWidget {
  const ConfiguracionAlertas({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfiguracionAlertas();
}

class _ConfiguracionAlertas extends State<ConfiguracionAlertas>
    with WidgetsBindingObserver {
  /// Indicador de correo activo
  static bool correoActivo = false;

  /// Indicador de correo habilitado
  static bool correoHabilitado = false;

  _ConfiguracionAlertas();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    obtenerConfiguracionAlertas();
  }

  /// Método que obtiene la configuración de las alertas de la aplicación
  Future<void> obtenerConfiguracionAlertas() async {
    await Sesion.peticion(
            tipoPeticion: TipoPeticion.POST,
            urlPeticion: '${Constantes.urlNotificacionesConfiguracion}activar',
            bodyparams: null,
            context: context)
        .then((resultado) {
      Utilidades.imprimir('ESTADO ALERTAS: ${resultado.toString()}');
      procesarRespuestaAlertas(resultado);
    }).catchError((onError) {
      Alertas.showToast(
          mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true);
      desactivarAlertas();
    });
  }

  /// Método que procesa la respuesta para mostrar la configuración de las alertas
  void procesarRespuestaAlertas(dynamic resultado) {
    if (resultado['finalizado'] && resultado['datos'] != null) {
      if (resultado['datos']['notificacion_email'] != null) {
        correoActivo = resultado['datos']['notificacion_email'];
      }
      correoHabilitado = true;

      if (mounted) setState(() {});
    }
  }

  /// Método que inhabilita la opción de modificación de las alertas
  void desactivarAlertas() {
    correoHabilitado = false;
    // pushHabilitado = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
          child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              "Elige el tipo de alerta para tus notificaciones",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            alignment: Alignment.centerLeft,
          ),
          // SizedBox(height: 35),
          Card(
              margin: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 35),
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: ColorApp.colorGrisClaro),
                  borderRadius: BorderRadius.circular(12.0)),
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 24, left: 15, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Correo electrónico',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: ColorApp.colorBlackClaro,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Elementos.switchNativo(
                            value: correoActivo,
                            onChanged: correoHabilitado
                                ? (value) async {
                                    Dialogo.mostrarDialogoConfirmacion(
                                        context,
                                        "Habilitar/Deshabilitar Notificaciones por Correo Electrónico",
                                        () async => {
                                              await configurarAlerta(
                                                  tipoAlerta: 'email',
                                                  nuevoEstado: value),
                                              Navigator.of(context).pop()
                                            },
                                        !value
                                            ? "¿Está seguro que desea deshabilitar las notificaciones de correo?"
                                            : "Considera que la recepción del mensaje, dependerá del tipo de conexión a internet que tienes y de tu proveedor de correo electrónico, por lo que no podemos garantizar su recepción. Por favor, revisa siempre tu buzón de notificaciones.");
                                  }
                                : null,
                            activeColor: ColorApp.buttons)
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                        'Con tu correo electrónico puedes recibir alertas de las notificaciones electrónicas.',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: ColorApp.greyText,
                        ))
                  ],
                ),
              )),
        ],
      )),
    );
  }

  /// Método que modifica la configuración de las alertas

  Future<void> configurarAlerta({String tipoAlerta, bool nuevoEstado}) async {
    Map<String, bool> bodyParams = {tipoAlerta: nuevoEstado};

    try {
      var resultado = await Sesion.peticion(
          tipoPeticion: TipoPeticion.PUT,
          urlPeticion: '${Constantes.urlNotificacionesConfiguracion}alertas',
          bodyparams: bodyParams,
          context: context);
      Utilidades.imprimir('cambio de estado alertas: ${resultado.toString()}');

      procesarRespuestaAlertas(resultado);
    } catch (e) {
      Utilidades.imprimir(
          "Error al actualizar el estado de la alerta: ${e.toString()}");
      desactivarAlertas();
    }
  }
}
