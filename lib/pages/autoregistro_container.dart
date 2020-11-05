import 'dart:io';

import 'package:ciudadaniadigital/pages/autoregistro/finalizadoRemoto.dart';
import 'package:ciudadaniadigital/pages/autoregistro/informacion_carnet.dart';
import 'package:ciudadaniadigital/pages/autoregistro/metodo_verificacion_llamada.dart';
import 'package:ciudadaniadigital/pages/autoregistro/metodo_verificacion_permiso.dart';
import 'package:ciudadaniadigital/pages/autoregistro/metodo_verificacion_vista.dart';
import 'package:ciudadaniadigital/pages/autoregistro/registro_datos_personales.dart';
import 'package:ciudadaniadigital/pages/autoregistro/verificado_vista.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'autoregistro/finalizado_vista.dart';
import 'autoregistro/horario_llamada.dart';
import 'autoregistro/opcion_entidad_registradora.dart';
import 'autoregistro/registro_celular.dart';
import 'autoregistro/registro_correo.dart';
import 'autoregistro/resumen_fotos.dart';
import 'autoregistro/verificacion_celular.dart';
import 'autoregistro/verificacion_correo.dart';
import 'ciudadania_tabs/Elementos.dart';

/// Vista que muestra el formulario de autoregistro en varios pasos

class AutoRegistroPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AutoRegistroPage();
  }
}

class _AutoRegistroPage extends State<AutoRegistroPage> {
  /// Número de grupo actual
  int grupoActual = 0;

  /// Número de paso actual
  int pasoActual = 0;

  /// Lista de Grupos de pasos del formulario
  List formularioWidgets = [];

  /// Indicador de visibilidad para animación
  bool _visible = true;

  /// Indicador de operación activa
  bool ocupado = false;

  /// controlador de Scroll
  ScrollController controladorScroll;

  /// numero maximo de intentos para pasar a siguiente etapa
  final int numeroIntentos = 2;

  /// intento actual
  int _intento = 0;

  /// timestamp ultimo intento
  int _lastRetry = 0;

  /// milisegundos acumulados de bloqueo
  int _delayed = 0;

  /// duracion de toast en pantalla (milisegundos)
  final int tiempoAlerta = 4000;

  /// Widget que muestra el boton siguiente
  Widget botonSiguiente() {
    return RaisedButton(
      elevation: 0,
      child: Container(
        alignment: Alignment.center,
        width: 128,
        height: 40,
        child: Text(
          formularioWidgets[grupoActual][pasoActual].botonTexto,
          style: TextStyle(
              fontSize: 14,
              color: ColorApp.bg,
              fontWeight: FontWeight.w500), // fontSize: 18
        ),
      ),
      onPressed: formularioWidgets[grupoActual][pasoActual].habilitarSiguiente
          ? !ocupado
              ? () {
                  formularioWidgets[grupoActual][pasoActual]
                      .accionSiguiente
                      .call();
                }
              : null
          : null,
      color: ColorApp.buttons,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42.0)),
    );
  }

  /// Widget que muestra el boton volver
  Widget botonVolver() {
    return FlatButton(
      child: Container(
          child: Text(
        "Volver",
        style: TextStyle(color: ColorApp.greyText),
      )),
      onPressed: !ocupado
          ? () {
              formularioWidgets[grupoActual][pasoActual].accionVolver.call();
            }
          : null,
    );
  }

  Widget botonesVertical() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        botonSiguiente(),
        if (formularioWidgets[grupoActual][pasoActual].mostrarVolver)
          SizedBox(
            width: 20,
          ),
        if (formularioWidgets[grupoActual][pasoActual].mostrarVolver)
          botonVolver(),
      ],
    );
  }

  /// Widget que muestra los botones de forma horizontal
  Widget botonesHorizontal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        if (formularioWidgets[grupoActual][pasoActual].mostrarVolver)
          botonVolver(),
        if (formularioWidgets[grupoActual][pasoActual].mostrarVolver)
          SizedBox(
            width: 20,
          ),
        botonSiguiente(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var accionRegistroCelular = () {
      validarAccionSiguiente(RegistroCelular.registarCelular(""));
    };

    var accionVerificarCelular = () {
      validarAccionSiguiente(VerificacionCelular.verificarCelular());
    };

    var accionRegistroCorreo = () {
      validarAccionSiguiente(RegistroCorreo.registarCorreo("", context));
    };

    var accionVerificacionCorreo = () {
      validarAccionSiguiente(VerificacionCorreo.verificarCorreo());
    };

    var accionRegistroDatosPersonales = () {
      validarAccionSiguiente(RegistroDatosPersonales.registarDatosPersonales());
    };

    var accionVerificacion = () {
      validarAccionSiguiente(VerificadoVista.verificadoAccion());
    };
    var accionVerificacionCarnetInfo = () {
      validarAccionSiguiente(InformacionCarnet.verificadoAccion());
    };

    var accionVerificacionPermiso = () {
      validarAccionSiguiente(
          MetodoVerificacionPermisoWidget.verificadoAccion());
    };

    var accionMetodoOpcion = () async {
      progreso(mostrar: true);
      MetodoVerificacionOpcionesWidget.finalizarRegistro()
          .then((value) {
            if (value) {
              animacionPaso(5,
                  0); // Saltando a paso para terminar auto registro presencialmente
            } else {
              animacionPaso(3,
                  1); // Saltando a paso para terminar auto registro remotamente
            }
          })
          .catchError((onError) => {
                Alertas.showToast(
                    mensaje: Utilidades.obtenerMensajeRespuesta(onError),
                    danger: true)
              })
          .whenComplete(() => {progreso(mostrar: false)});
    };

    var accionVerificarFotos = () {
      validarAccionSiguiente(ResumenFotos.verificarFotos());
    };

    var accionVerificarEntidadRegistradora = () {
      validarAccionSiguiente(OpcionEntidadRegistradora.verificar());
    };

    var accionVerificarHorarioLlamada = () {
      progreso(mostrar: true);
      HorarioLlamada.verificar()
          .then((value) => animacionPaso(5, 1))
          .catchError((onError) => {
                Alertas.showToast(
                    mensaje: Utilidades.obtenerMensajeRespuesta(onError),
                    danger: true)
              })
          .whenComplete(() => {progreso(mostrar: false)});
    };

    var accionVolver = () {
      anteriorPaso();
    };

    var accionVolverDatosPersonales = () {
      animacionPaso(1, 1);
    };

    var accionVolverMetodoVerificacion = () {
      animacionPaso(2, 0);
    };

    var accionVolverPresencial = () {
      animacionPaso(3, 0);
    };

    var accionVolverRemoto = () {
      animacionPaso(4, 1);
    };

    formularioWidgets = [
      [
        Paso(
            titulo: "Registro",
            vista: RegistroCelular(
              accion: accionRegistroCelular,
            ),
            accionSiguiente: accionRegistroCelular,
            mostrarVolver: false,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Ingresar código",
            vista: VerificacionCelular(
              accion: accionVerificarCelular,
            ),
            accionSiguiente: accionVerificarCelular,
            accionVolver: accionVolver,
            botonTexto: "Continuar"),
      ],
      [
        Paso(
            titulo: "Correo electrónico",
            vista: RegistroCorreo(
              accion: accionRegistroCorreo,
            ),
            accionSiguiente: accionRegistroCorreo,
            accionVolver: accionVolver,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Verificación",
            vista: VerificacionCorreo(
              accion: accionVerificacionCorreo,
            ),
            accionSiguiente: accionVerificacionCorreo,
            accionVolver: accionVolver,
            habilitarSiguiente: false,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Verificación",
            vista: VerificadoVista(
              error: false,
              mensaje: "Tu correo electrónico fue verificado correctamente.",
            ),
            accionSiguiente: accionVerificacion,
            accionVolver: accionVolver,
            botonTexto: "Continuar"),
      ],
      [
        Paso(
            titulo: "Datos personales",
            vista: RegistroDatosPersonales(),
            accionSiguiente: accionRegistroDatosPersonales,
            accionVolver: accionVolverDatosPersonales,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Verificación",
            vista: VerificadoVista(
                error: true,
                mensaje:
                    "Tus datos fueron verificados correctamente con los datos del SEGIP."),
            accionSiguiente: accionVerificacion,
            accionVolver: accionVolver,
            accionCancelar: cancelarRegistro,
            botonTexto: "Continuar"),
      ],
      [
        Paso(
            titulo: "Método de Verificación",
            vista: MetodoVerificacionOpcionesWidget(),
            accionSiguiente: accionMetodoOpcion,
            accionVolver: accionVolverMetodoVerificacion,
            accionCancelar: cancelarRegistro,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Método de verificación",
            vista: MetodoVerificacionLlamadaWidget(),
            accionSiguiente: accionVerificacion,
            accionVolver: accionVolver,
            accionCancelar: cancelarRegistro,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Fotografía C.I.",
            vista: InformacionCarnet(),
            accionSiguiente: accionVerificacionCarnetInfo,
            accionVolver: accionVolver,
            accionCancelar: cancelarRegistro,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Permiso",
            vista: MetodoVerificacionPermisoWidget(),
            accionSiguiente: accionVerificacionPermiso,
            accionVolver: accionVolver,
            accionCancelar: cancelarRegistro,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Resumen de fotografías",
            vista: ResumenFotos(),
            accionSiguiente: accionVerificarFotos,
            accionVolver: accionVolver,
            accionCancelar: cancelarRegistro,
            botonTexto: "Continuar"),
      ],
      [
        Paso(
            titulo: "Videollamada",
            vista: OpcionEntidadRegistradora(),
            accionSiguiente: accionVerificarEntidadRegistradora,
            accionVolver: accionVolver,
            accionCancelar: cancelarRegistro,
            botonTexto: "Continuar"),
        Paso(
            titulo: "Videollamada",
            vista: HorarioLlamada(),
            accionSiguiente: accionVerificarHorarioLlamada,
            accionVolver: accionVolver,
            accionCancelar: cancelarRegistro,
            botonTexto: "Continuar")
      ],
      [
        Paso(
            titulo: "¡Tu solicitud de registro ha sido enviada con éxito!",
            vista: FinalizadoVista(),
            accionSiguiente: () {
              Navigator.pop(context);
            },
            accionVolver: accionVolverPresencial,
            mostrarVolver: false,
            botonTexto: "Volver al inicio"),
        Paso(
            titulo: "¡Tu solicitud de registro ha sido enviada con éxito!",
            vista: FinalizadoRemoto(),
            accionSiguiente: () {
              Navigator.pop(context);
            },
            accionVolver: accionVolverRemoto,
            mostrarVolver: false,
            botonTexto: "Volver al inicio")
      ]
    ];

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: WillPopScope(
          onWillPop: () async {
            return Dialogo.mostrarDialogoNativo(
                context,
                "Cancelar",
                Text("\n¿Está seguro de cancelar su registro?"),
                "Aceptar",
                () async {
                  if (formularioWidgets[grupoActual][pasoActual]
                          .accionCancelar !=
                      null)
                    formularioWidgets[grupoActual][pasoActual]
                        .accionCancelar
                        .call();
                  Navigator.pop(context);
                  Utilidades.imprimir("regresando true");
                  return true;
                },
                secondButtonText: "Cancelar",
                secondCallback: () {
                  Utilidades.imprimir("regresando false");
                  return false;
                },
                secondActionStyle: ActionStyle.important);
          },
          child: new Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomPadding: false,
            appBar: grupoActual + 1 != formularioWidgets.length
                ? AppBar(
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Dialogo.mostrarDialogoNativo(
                              context,
                              "Alerta",
                              Text("\n¿Está seguro de cancelar su registro?"),
                              "Aceptar", () async {
                            if (formularioWidgets[grupoActual][pasoActual]
                                    .accionCancelar !=
                                null)
                              formularioWidgets[grupoActual][pasoActual]
                                  .accionCancelar
                                  .call();

                            Navigator.pop(context);
                          },
                              secondButtonText: "Cancelar",
                              secondCallback: () {},
                              secondActionStyle: ActionStyle.important);
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: ColorApp.btnBackground),
                        ),
                      ),
                    ],
                  )
                : PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
            body: formularioWidgets.length > 0
                ? SingleChildScrollView(
                    controller: controladorScroll,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Elementos.cabeceraLogos3(),
                          SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: AnimatedOpacity(
                                opacity: _visible ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 500),
                                child: widgetTitulo()),
                          ),
                          Center(
                            child: AnimatedOpacity(
                              opacity: _visible ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 500),
                              child: Container(
                                child: formularioWidgets[grupoActual]
                                        [pasoActual]
                                    .vista,
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: _intento <= numeroIntentos,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 300),
                              // padding: EdgeInsets.only(left: 48, right: 48),
                              child: Text(
                                'Demasiados intentos consecutivos, espera por favor ${(_delayed / 1000).round()} segundos y vuelve a intentarlo',
                                style: TextStyle(color: ColorApp.error),
                              ),
                            ),
                          ),
                          if (pasoActual + 1 != formularioWidgets.length)
                            Container(
                                padding: EdgeInsets.only(
                                    left: 48, right: 48, bottom: 48, top: 20),
                                constraints: BoxConstraints(maxWidth: 400),
                                child: MediaQuery.of(context).size.width > 360
                                    ? botonesHorizontal()
                                    : botonesVertical()),
                          if ((pasoActual + 1 == formularioWidgets.length))
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 48, right: 48),
                                child: CupertinoButton(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 221,
                                    height: 20,
                                    child: Text(
                                      formularioWidgets[grupoActual][pasoActual]
                                          .botonTexto,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: ColorApp.greyText,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await Utilidades.deleteAllSecureStorage();
                                    Navigator.pop(context);
                                  },
                                  color: Colors.white,
                                )),
                          Offstage(
                            offstage:
                                (grupoActual + 1 == formularioWidgets.length),
                            child: Offstage(
                              offstage: ocupado,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 300),
                                padding: EdgeInsets.only(left: 48, right: 48),
                                child: StepProgressIndicator(
                                  totalSteps: formularioWidgets.length,
                                  selectedColor: ColorApp.buttons,
                                  currentStep: grupoActual + 1,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 300),
                            padding: EdgeInsets.only(left: 48, right: 48),
                            child: Visibility(
                              visible: ocupado,
                              child: Elementos.indicadorProgresoLineal(),
                            ),
                          ),
                          SizedBox(
                            height: 300,
                          )
                        ],
                      ),
                    ),
                  )
                : Text("sin widgets"),
          ),
        ));
  }

  /// Método que valida una acción a antes de proceder con el siguiente paso

  Future<void> validarAccionSiguiente(Future accion) {
    progreso(mostrar: true);

    return accion.then((value) => siguientePaso()).catchError((onError) {
      Alertas.showToast(
          mensaje: Utilidades.obtenerMensajeRespuesta(onError), danger: true);
      int now = DateTime.now().millisecondsSinceEpoch;
      if (_intento == 0) {
        _intento++;
        _delayed = tiempoAlerta;
      } else {
        int timeLapsed = now - _lastRetry;
        if (timeLapsed < _delayed) {
          _intento++;
          _delayed += tiempoAlerta - timeLapsed;
        } else {
          _intento = 0;
          _delayed = 0;
        }
      }
      _lastRetry = now;
    }).whenComplete(() async {
      if (_intento > numeroIntentos) {
        Utilidades.imprimir('bloqueando por $_delayed milisegundos');
        await Future.delayed(Duration(milliseconds: _delayed));
        _intento = 0;
        _delayed = 0;
        _lastRetry = DateTime.now().millisecondsSinceEpoch;
      }
      progreso(mostrar: false);
    });
  }

  /// Método que muestra o oculta el progreso de una operación

  void progreso({bool mostrar}) {
    setState(() {
      ocupado = mostrar;
    });
  }

  /// Método que vuelve un paso atras en el formulario
  void anteriorPaso() {
    Utilidades.imprimir("pasoActual: $pasoActual / grupo actual: $grupoActual");
    if (pasoActual == 0) {
      if (grupoActual == 0) {
        Utilidades.imprimir("Primer paso 🚨");
      } else {
        animacionPaso(
            grupoActual - 1, formularioWidgets[grupoActual - 1].length - 1);
      }
    } else {
      animacionPaso(grupoActual, pasoActual - 1);
    }
  }

  /// Método que avanza un paso en el formulario

  void siguientePaso() async {
    Utilidades.imprimir("pasoActual: $pasoActual / grupo actual: $grupoActual");
    if (formularioWidgets[grupoActual].length == pasoActual + 1) {
      Utilidades.imprimir("Último paso 🚨");
      Utilidades.imprimir("Grupo Actual: $grupoActual");
      if (formularioWidgets.length == grupoActual + 1) {
        Utilidades.imprimir("Último grupo 🚨");
      } else {
        animacionPaso(grupoActual + 1, 0);
      }
    } else {
      animacionPaso(grupoActual, pasoActual + 1);
    }
  }

  /// Método que cancela el registro

  void cancelarRegistro() async {
    String contentId = await Utilidades.readSecureStorage(key: 'content_id_1');

    if (contentId != null) {
      Utilidades.imprimir('cancelando registro..................');
      var response = await Services.peticion(
          tipoPeticion: TipoPeticion.DELETE,
          urlPeticion: "${Constantes.urlBasePreRegistroForm}registrar/persona",
          headers: {
            'Content-Id': contentId,
            "tipo": Platform.operatingSystem.toLowerCase(),
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8'
          });
      Utilidades.imprimir(
          'respuesta cancelacion de registro: ${response.toString()}');
    } else {
      Utilidades.imprimir(
          'No se tiene un Content-Id 🚨 para eliminar el auto registro');
    }
  }

  /// Animación para ir a un determinado grupo y paso
  void animacionPaso(int grupoNuevo, int pasoNuevo) async {
    setState(() {
      _visible = false;
    });

    await Future.delayed(Duration(milliseconds: 400))
        .then((value) => setState(() {
              grupoActual = grupoNuevo;
              pasoActual = pasoNuevo;
              controladorScroll
                  .animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  )
                  .then((value) => () {
                        Utilidades.imprimir("posición de scroll restaurada 🔝");
                      });

              Utilidades.imprimir("Paso destino: $pasoActual");
              _visible = true;
            }));
  }

  @override
  void initState() {
    super.initState();
    controladorScroll = new ScrollController();
    Utilidades.deleteAllSecureStorage();
  }

  /// Widget que muestra el título del paso
  Widget widgetTitulo() {
    Text widgetTitulo = Text(
      formularioWidgets[grupoActual][pasoActual].titulo,
      textAlign: TextAlign.center,
      style: new TextStyle(
          fontSize: 18.0,
          color: ColorApp.btnBackground,
          fontWeight: FontWeight.w700),
    );
    if (grupoActual == formularioWidgets.length - 1) {
      return Padding(
        padding: EdgeInsets.only(left: 48, right: 48),
        child: widgetTitulo,
      );
    } else {
      return widgetTitulo;
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    controladorScroll.dispose();
  }
}

/// Clase que define un paso del formulario
class Paso {
  /// Título del paso del formulario
  final String titulo;

  /// Widget vista del paso del formulario
  final Widget vista;

  /// Accion al presionar "siguiente"
  final VoidCallback accionSiguiente;

  /// Accion al presionar "cancelar"
  final VoidCallback accionCancelar;

  /// Accion al presionar "volver"
  final VoidCallback accionVolver;

  /// Texto del boton "siguiente" del formulario
  final String botonTexto;

  /// Indicador si mostrar o no el boton "volver"
  final bool mostrarVolver;

  /// Indicador si habilitar o no el boton "Siguiente"
  final bool habilitarSiguiente;

  Paso(
      {this.titulo,
      this.vista,
      this.accionSiguiente,
      this.accionVolver,
      this.accionCancelar,
      this.botonTexto,
      this.mostrarVolver = true,
      this.habilitarSiguiente = true});
}
