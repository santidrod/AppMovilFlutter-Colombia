import 'dart:async';
import 'dart:io';

import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/styles/styles.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/sesion.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:ciudadaniadigital/utilidades/validaciones.dart';
import 'package:countdown/countdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

/// Vista que mostrara un formulario para cambiar la contraseña

enum tipoActualizacion { PASSWORD, PHONE, EMAIL }

class ActualizarDatosWidget extends StatefulWidget {
  final tipoActualizacion tipoDeActualizacion;

  const ActualizarDatosWidget({Key key, this.tipoDeActualizacion})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ActualizarDatosWidgetState();
  }
}

class _ActualizarDatosWidgetState extends State<ActualizarDatosWidget> {
  _ActualizarDatosWidgetState();

  /// Indicador de carga
  bool cargando = false;

  /// Flag para actualizar la contraseña despues de válidar con el usuario
  String updateInteraction;

  List<PasoActualizacion> formularioWidgets = [];

  int pasoActual = 0;

  /// Controlador del campo para ingresar la contraseña
  final TextEditingController password = TextEditingController();

  /// Objeto que maneja el foco del campo contraseña
  FocusNode passwordFocus = FocusNode();

  /// Indicador para mostrar la contraseña en el campo seguro
  bool iconShowPassword = true;

  /// Objeto que maneja el foco del campo contraseña
  FocusNode newPasswordFocus = FocusNode();

  /// Objeto que maneja el estado del formulario para verificar la contraseña
  final _formKeyVerificarContrasenia = GlobalKey<FormState>();

  /// Objeto que maneja el estado del formulario para crear una nueva contraseña
  final _formKeyCambiarContrasenia = GlobalKey<FormState>();

  /// Indicador para mostrar la contraseña en el campo seguro de la nueva contraseña
  bool iconShowNewPassword = true;

  /// Objeto que maneja el foco del campo de la nueva contraseña
  FocusNode newPasswordFocusRepeat = FocusNode();

  /// Controlador del campo para ingresar la repetición de la nueva contraseña
  final TextEditingController newPasswordRepeat = TextEditingController();

  final int _otpCodeLength = 6;

  /// Controlador del campo para ingresar la nueva contraseña
  final TextEditingController newPasswordController = TextEditingController();

  /// Indicador para mostrar la contraseña en el campo seguro de la repetición de la nueva contraseña
  bool iconShowNewPasswordRepeat = true;

  /// Nivel de seguridad de la contraseña
  int passwordScore = 0;

  /// Objeto que maneja el foco del campo celular
  FocusNode newPhoneFocus = FocusNode();

  /// Objeto que maneja el estado del formulario para actualizar el nro de celular
  final _formKeyCambiarCelular = GlobalKey<FormState>();

  /// Objeto que maneja el estado del formulario para actualizar el correo
  final _formKeyCambiarCorreo = GlobalKey<FormState>();

  /// Objeto que maneja el estado del formulario para actualizar el correo
  final _formKeyVerificarCorreo = GlobalKey<FormState>();

  /// Objeto que maneja el estado del formulario para actualizar el celular
  final _formKeyVerificarCelular = GlobalKey<FormState>();

  /// Controlador del campo para ingresar la nuevo celular
  final TextEditingController newPhoneController = TextEditingController();

  /// Controlador del campo para ingresar la nuevo email
  final TextEditingController newEmailController = TextEditingController();

  /// Controlador del campo para ingresar un nuevo código
  final TextEditingController codeEmailController = TextEditingController();

  /// Controlador del campo para ingresar un nuevo código
  final TextEditingController codeCelularController = TextEditingController();

  /// Indicador de visibilidad para animación
  bool _visible = true;

  /// Indicador de contador para solicitar otro correo
  var contador = 0;

  @override
  void initState() {
    super.initState();
    Dispositivo.mostrarSignature();
  }

  /// Método que activa el indicador de carga
  void estadoCarga({bool estado}) {
    setState(() {
      cargando = estado;
    });
  }

  Future siguientePaso() async {
    Utilidades.imprimir(
        "Paso actual $pasoActual de ${formularioWidgets.length}");
    if (formularioWidgets.length > pasoActual + 1) {
      Utilidades.imprimir("Paso destino ➡ $pasoActual");
      setState(() {
        _visible = false;
      });
      await Future.delayed(Duration(milliseconds: 400)).then((value) {
        setState(() {
          pasoActual++;
          _visible = true;
        });
      });
    } else {
      Utilidades.imprimir("Último paso 🚨");
    }
  }

  Future modificarCorreo(String email) async {
    bool estaSeguro = false;
    bool esCorreoInst = Validar.esInstitucional(email);
    if (esCorreoInst) {
      await Dialogo.mostrarDialogoNativo(
          context,
          "Alerta",
          Text(
              'Parece que tratas de usar un correo electrónico institucional en lugar de un correo personal.\n\n¿Quieres continuar de todos modos?'),
          "SI",
          () async {
            estaSeguro = true;
          },
          secondButtonText: "NO",
          secondCallback: () {
            estaSeguro = false;
          },
          secondActionStyle: ActionStyle.important);
    }

    if (esCorreoInst && !estaSeguro) {
      return throw ('Introduce un correo no institucional');
    }

    estadoCarga(estado: true);

    Map<String, dynamic> params = {
      "update_interaction": updateInteraction,
      "email": email
    };
    await Sesion.peticion(
            tipoPeticion: TipoPeticion.PATCH,
            urlPeticion: '${Constantes.urlIsuer}api/v1/users/emails',
            bodyparams: params,
            context: context)
        .then((response) {
      Utilidades.imprimir("Fase 2 - email 🔐: $response");
    }).catchError((onError) {
      verificarForzarCerrarSesion(onError, context);
      throw onError;
    }).whenComplete(() => {
              Utilidades.imprimir("peticion a interacciones terminada 🆗"),
              estadoCarga(estado: false)
            });
  }

  /// Cambiar celular

  Future modificarCelular(String phone) async {
    estadoCarga(estado: true);
    Map<String, dynamic> params = {
      "update_interaction": updateInteraction,
      "phone": phone
    };

    await Sesion.peticion(
            tipoPeticion: TipoPeticion.PATCH,
            urlPeticion: '${Constantes.urlIsuer}/api/v1/users/phones',
            bodyparams: params,
            context: context)
        .then((response) {
      Utilidades.imprimir("Fase 2 - modificar celular 🔐: $response");
    }).catchError((onError) {
      verificarForzarCerrarSesion(onError, context);
      throw onError;
    }).whenComplete(() => {
              Utilidades.imprimir("peticion a interacciones terminada 🆗"),
              estadoCarga(estado: false)
            });
  }

  /// Contador para solicitar otro código de confirmación
  void countdown() async {
    if (mounted) {
      try {
        var cd = new CountDown(new Duration(seconds: 60));
        await for (var v in cd.stream) {
          setState(() => contador = v.inSeconds);
        }
      } catch (error) {
        Utilidades.imprimir("error con contador: $error");
      }
    } else {
      Utilidades.imprimir("El Widget no esta montado, contador detenido");
    }
  }

  /// Método que procesa mensaje de error en caso de tener un número de intentos, o para cerrar sesión

  String procesarMensajeError(dynamic respuesta) {
    try {
      String mensaje =
          "${respuesta["mensaje"] ?? respuesta["message"] ?? respuesta["error"] ?? "Solicitud erronea"}";

      if (respuesta["error_detail"] != null) {
        if (respuesta["error_detail"]["attempts"] != null) {
          int intentos = respuesta["error_detail"]["attempts"];
          String texto = intentos > 1
              ? "te quedan $intentos intentos"
              : "te queda $intentos intento";
          mensaje = "$mensaje, $texto";
        }
        if (respuesta["error_detail"]["lock"] != null) {
          if (respuesta["error_detail"]["lock"]) {
            mensaje = "$mensaje, cerraremos su sesión.";
          }
        }
      }

      return mensaje;
    } catch (error) {
      return respuesta;
    }
  }

  /// Método que verifica la respuesta para encontrar algun flag del proveedor que indique que se debe cerrar sesión
  static void verificarForzarCerrarSesion(
      dynamic response, BuildContext context) {
    try {
      if (response["closeSessions"] != null) {
        if (response["closeSessions"]) {
          Future.delayed(const Duration(seconds: 5),
              () => Sesion.cerrarSesion(context, proveedor: false));
        }
      } else if (response["error_detail"] != null) {
        if (response["error_detail"]["lock"] != null) {
          if (response["error_detail"]["lock"]) {
            Future.delayed(const Duration(seconds: 5),
                () => Sesion.cerrarSesion(context, proveedor: false));
          }
        }
      }
    } catch (error) {
      Utilidades.imprimir("No se puede determinar si cerrar sesión 🔐: $error");
    }
  }

  bool ultimoPaso() {
    return pasoActual + 1 == formularioWidgets.length;
  }

  void cerrarWidget() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.tipoDeActualizacion) {
      case tipoActualizacion.PASSWORD:
        formularioWidgets = [
          PasoActualizacion(
              titulo: "Cambiar contraseña",
              vista: verificarContrasenia(),
              accionCancelar: cerrarWidget),
          PasoActualizacion(
              titulo: "Cambiar contraseña",
              vista: cambiarContrasenia(),
              accionCancelar: cerrarWidget),
          PasoActualizacion(
              titulo: "La contraseña se cambió exitosamente",
              vista: confirmacionCambio(
                  mensaje:
                      "El cambio fue realizado correctamente. \nRecuerda que deberás volver a ingresar al sistema de ciudadanía digital.",
                  signOut: true),
              accionCancelar: () {
                Sesion.cerrarSesion(context, proveedor: false);
              }),
        ];
        break;
      case tipoActualizacion.PHONE:
        formularioWidgets = [
          PasoActualizacion(
              titulo: "Cambiar número de teléfono",
              vista: verificarContrasenia(),
              accionCancelar: cerrarWidget),
          PasoActualizacion(
              titulo: "Cambiar número de teléfono",
              vista: cambiarCelular(),
              accionCancelar: cerrarWidget),
          PasoActualizacion(
              titulo: "Ingresar código",
              vista: verificarCelular(),
              accionCancelar: cerrarWidget),
          PasoActualizacion(
              titulo: "Cambio realizado Exitosamente",
              vista: confirmacionCambio(
                  mensaje: "El cambio fue realizado correctamente",
                  signOut: false),
              accionCancelar: cerrarWidget),
        ];
        break;
      case tipoActualizacion.EMAIL:
        formularioWidgets = [
          PasoActualizacion(
              titulo: "Cambiar correo electrónico",
              vista: verificarContrasenia(),
              accionCancelar: cerrarWidget),
          PasoActualizacion(
              titulo: "Cambiar correo electrónico",
              vista: nuevoCorreo(),
              accionCancelar: cerrarWidget),
          PasoActualizacion(
              titulo: "Ingresar código",
              vista: verificarCorreo(),
              accionCancelar: cerrarWidget),
          PasoActualizacion(
              titulo: "Cambio realizado Exitosamente",
              vista: confirmacionCambio(
                  mensaje: "El cambio fue realizado correctamente",
                  signOut: false),
              accionCancelar: cerrarWidget),
        ];
        break;
    }

    Future ejecutarMetodo({VoidCallback accion}) async {
      return accion.call();
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async {
          return ultimoPaso()
              ? ejecutarMetodo(
                      accion: formularioWidgets[pasoActual].accionCancelar)
                  .then((value) => true)
              : Dialogo.mostrarDialogoNativo(
                  context,
                  "Cancelar",
                  Text("¿Está seguro de cancelar el cambio ?"),
                  "Aceptar",
                  () async {
                    formularioWidgets[pasoActual].accionCancelar.call();
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
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  if (!ultimoPaso()) {
                    Dialogo.mostrarDialogoNativo(
                        context,
                        "Cancelar",
                        Text("¿Está seguro de cancelar el cambio ?"),
                        "Aceptar", () async {
                      formularioWidgets[pasoActual].accionCancelar.call();
                    },
                        secondButtonText: "Cancelar",
                        secondCallback: () {},
                        secondActionStyle: ActionStyle.important);
                  } else {
                    formularioWidgets[pasoActual].accionCancelar.call();
                  }
                },
                child: Icon(
                  Icons.clear,
                  color: ColorApp.greyDarkText,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("\n${formularioWidgets[pasoActual].titulo}",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: ColorApp.btnBackground,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal)),
                      SizedBox(
                        height: 40,
                      ),
                      Center(child: formularioWidgets[pasoActual].vista),
                      Container(
                        constraints: BoxConstraints(maxWidth: 250),
                        child: Visibility(
                          visible: cargando,
                          child: Elementos.indicadorProgresoLineal(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget botones(String textoContinuar, VoidCallback accion) {
    bool _isPortrait = MediaQuery.of(context).size.width > 360;

    Widget botonCancelar = FlatButton(
        child: Container(
            child: Text(
          "Cancelar",
          style: TextStyle(fontSize: 14, color: ColorApp.greyText),
        )),
        onPressed: cargando
            ? null
            : () {
                if (ultimoPaso()) {
                  formularioWidgets[pasoActual].accionCancelar.call();
                } else {
                  Dialogo.mostrarDialogoNativo(
                      context,
                      "Cancelar",
                      Text("¿Está seguro de cancelar el cambio ?"),
                      "Aceptar", () async {
                    Navigator.pop(context);
                  },
                      secondButtonText: "Cancelar",
                      secondCallback: () {},
                      secondActionStyle: ActionStyle.important);
                }
              });

    Widget botonContinuar = RaisedButton(
      child: Container(
        width: 128,
        height: 40,
        child: Center(
          child: Text(
            textoContinuar,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: ColorApp.bg, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      color: ColorApp.buttons,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42.0)),
      onPressed: cargando
          ? null
          : () {
              accion.call();
            },
    );

    return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          direction: _isPortrait ? Axis.horizontal : Axis.vertical,
          children: _isPortrait
              ? [botonCancelar, botonContinuar]
              : [botonContinuar, botonCancelar],
        ));
  }

  Widget verificarContrasenia() {
    /// Método que verifica la contraseña actual haciendo una petición al proveedor

    Future verificarContraseniaActual(String password) async {
      estadoCarga(estado: true);

      Map<String, String> params = {
        "type": describeEnum(widget.tipoDeActualizacion),
        "password": Utilidades.haciaBase64(password)
      };

      await Sesion.peticion(
              tipoPeticion: TipoPeticion.POST,
              urlPeticion:
                  '${Constantes.urlIsuer}/api/v1/accounts/interactions',
              bodyparams: params,
              context: context)
          .then((response) {
        Utilidades.imprimir("Fase 1 🔐: $response");
        setState(() {
          updateInteraction = response["update_interaction"];
        });
      }).catchError((onError) {
        Utilidades.imprimir(
            "Error al verificar la contraseña actual ❗️: $onError");
        verificarForzarCerrarSesion(onError, context);
        throw onError;
      }).whenComplete(() => {
                Utilidades.imprimir("peticion a interacciones terminada 🆗"),
                estadoCarga(estado: false)
              });
    }

    VoidCallback verificarContraseniaAccion = () async {
      if (_formKeyVerificarContrasenia.currentState.validate()) {
        await verificarContraseniaActual(password.text).then((value) {
          siguientePaso();
        }).catchError((onError) {
          Utilidades.imprimir("Error al verificar contraseña 🟥: $onError ");
          verificarForzarCerrarSesion(onError, context);
          Alertas.showToast(
              mensaje: procesarMensajeError(onError), danger: true);
        });
      }
    };

    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;

    return Container(
      height: screenHeight * 0.7,
      child: Form(
          key: _formKeyVerificarContrasenia,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  constraints: BoxConstraints(maxWidth: 285),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Al realizar este cambio se cerrarán todas las sesiones abiertas en tus dispositivos.",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w300),
                  )),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      constraints: BoxConstraints(maxWidth: 285),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Contraseña actual",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 285),
                    height: 80,
                    child: TextFormField(
                      enabled: !cargando,
                      obscureText: iconShowPassword,
                      controller: password,
                      focusNode: passwordFocus,
                      textInputAction: TextInputAction.send,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Ingresa tu contraseña actual';
                        }
                        return null;
                      },
                      onFieldSubmitted: (val) {
                        verificarContraseniaAccion.call();
                      },
                      decoration: Estilos.entradaSegura2(
                          hintText: "Ingresa tu contraseña actual",
                          accion: () {
                            setState(() {
                              iconShowPassword = !iconShowPassword;
                            });
                          },
                          estado: iconShowPassword),
                      keyboardType: TextInputType.text,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 40,
              ),
              botones("Continuar", verificarContraseniaAccion)
            ],
          )),
    );
  }

  Widget cambiarContrasenia() {
    /// Método que modifica la contraseña actual haciendo una petición al proveedor con la nueva contraseña

    Future modificarContrasenia(String password) async {
      estadoCarga(estado: true);

      Map<String, dynamic> params = {
        "update_interaction": updateInteraction,
        "password": {"new": Utilidades.haciaBase64(password)}
      };
      await Sesion.peticion(
              tipoPeticion: TipoPeticion.PATCH,
              urlPeticion: '${Constantes.urlIsuer}/api/v1/users/pass',
              bodyparams: params,
              context: context)
          .then((response) {
        Utilidades.imprimir("Fase 2 🔐 - contraseña: $response");

        setState(() {
          updateInteraction = null;
        });
      }).catchError((onError) {
        verificarForzarCerrarSesion(onError, context);
        throw onError;
      }).whenComplete(() => {
                Utilidades.imprimir("peticion a interacciones terminada 🆗"),
                estadoCarga(estado: false)
              });
    }

    VoidCallback verificarContraseniaAccion = () {
      if (_formKeyCambiarContrasenia.currentState.validate()) {
        Dialogo.mostrarDialogoConfirmacion(
            context, "¿Estás seguro(a) de modificar tu contraseña?", () {
          modificarContrasenia(newPasswordRepeat.text).then((value) {
            Utilidades.imprimir("empezo timer");
            this.startTimer();
            siguientePaso();
          }).catchError((onError) {
            Utilidades.imprimir("Error al modificar contraseña 🟥: $onError ");
            Alertas.showToast(
                mensaje: procesarMensajeError(onError), danger: true);
          });
          Navigator.of(context).pop();
        }, "Considera que se cerrarán todas las sesiones de ciudadanía digital abiertas en los dispositivos utilizados.");
      }
    };

    // var screenSize = MediaQuery.of(context).size;
    // var screenHeight = screenSize.height;
    return Container(
      // height: screenHeight * 0.7,
      child: Form(
        key: _formKeyCambiarContrasenia,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 285),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nueva Contraseña",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  constraints: BoxConstraints(maxWidth: 285),
                  height: 80,
                  child: TextFormField(
                    enabled: !cargando,
                    obscureText: iconShowNewPassword,
                    onChanged: (value) {
                      passwordScore =
                          Utilidades.estimadorFortalezaPassword(value);
                      setState(() {});
                    },
                    controller: newPasswordController,
                    focusNode: newPasswordFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context)
                          .requestFocus(newPasswordFocusRepeat);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Ingresa una nueva contraseña';
                      } else {
                        if (passwordScore < 3) {
                          return 'La contraseña no es segura';
                        }
                      }
                      return null;
                    },
                    decoration: Estilos.entradaSegura2(
                        hintText: "Ingresa tu nueva contraseña",
                        accion: () {
                          setState(() {
                            iconShowNewPassword = !iconShowNewPassword;
                          });
                        },
                        estado: iconShowNewPassword),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Elementos.seguridad(passwordScore, context),
            Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 285),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Repite tu contraseña",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  constraints: BoxConstraints(maxWidth: 285),
                  height: 80,
                  child: TextFormField(
                    enabled: !cargando,
                    obscureText: iconShowNewPasswordRepeat,
                    controller: newPasswordRepeat,
                    focusNode: newPasswordFocusRepeat,
                    textInputAction: TextInputAction.send,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'repite tu nueva contraseña';
                      } else {
                        if (newPasswordController.text != value) {
                          return 'La contraseña no coincide';
                        }
                      }
                      return null;
                    },
                    onFieldSubmitted: (val) {
                      verificarContraseniaAccion.call();
                    },
                    decoration: Estilos.entradaSegura2(
                        hintText: "Repite tu contraseña nueva",
                        accion: () {
                          setState(() {
                            iconShowNewPasswordRepeat =
                                !iconShowNewPasswordRepeat;
                          });
                        },
                        estado: iconShowNewPasswordRepeat),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
            botones("Continuar", verificarContraseniaAccion)
          ],
        ),
      ),
    );
  }

  Widget nuevoCorreo() {
    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;

    VoidCallback nuevoCorreoAccion = () {
      if (_formKeyCambiarCorreo.currentState.validate()) {
        modificarCorreo(newEmailController.text).then((value) {
          siguientePaso();
        }).catchError((onError) {
          Utilidades.imprimir("Error al enviar correo 🟥: $onError ");
          Alertas.showToast(
              mensaje: procesarMensajeError(onError), danger: true);
        });
      }
    };

    return Container(
      height: screenHeight * 0.7,
      child: Form(
        key: _formKeyCambiarCorreo,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 285),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nuevo Correo electrónico",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  constraints: BoxConstraints(maxWidth: 285),
                  height: 80,
                  child: TextFormField(
                      enabled: !cargando,
                      textAlign: TextAlign.center,
                      controller: newEmailController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Ingresa un nuevo correo';
                        }
                        return null;
                      },
                      onFieldSubmitted: (val) {
                        nuevoCorreoAccion.call();
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: Estilos.entrada2(
                        hintText: "Ingresa un nuevo correo",
                      )),
                ),
                Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 20, left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 270),
                    child: Text(
                      "Te enviaremos un código a tu nueva dirección de correo electrónico para verificar el cambio.",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                    ))
              ],
            ),
            botones("Continuar", nuevoCorreoAccion)
          ],
        ),
      ),
    );
  }

  Widget verificarCorreo() {
    Future verificarCorreo(String code) async {
      estadoCarga(estado: true);

      Map<String, dynamic> params = {
        "update_interaction": updateInteraction,
        "code": code
      };

      await Sesion.peticion(
              tipoPeticion: TipoPeticion.PATCH,
              urlPeticion:
                  '${Constantes.urlIsuer}/api/v1/accounts/interactions',
              bodyparams: params,
              context: context)
          .then((response) {
        Utilidades.imprimir("Fase 3 🔐: $response");
      }).catchError((onError) {
        verificarForzarCerrarSesion(onError, context);
        throw onError;
      }).whenComplete(() => {
                Utilidades.imprimir("peticion a interacciones terminada 🆗"),
                estadoCarga(estado: false)
              });
    }

    VoidCallback verificarCorreoAccion = () {
      if (_formKeyVerificarCorreo.currentState.validate()) {
        verificarCorreo(codeEmailController.text).then((value) {
          siguientePaso();
        }).catchError((onError) {
          Utilidades.imprimir("Error al verificar correo 🟥: $onError ");
          Alertas.showToast(
              mensaje: procesarMensajeError(onError), danger: true);
        });
      }
    };

    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;

    return Container(
      height: screenHeight * 0.7,
      child: Form(
        key: _formKeyVerificarCorreo,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(maxWidth: 285),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: ColorApp.listFillCell,
                ),
                child: ListTileMoreCustomizable(
                  leading: Image.asset(
                    "assets/images/icon_mail.png",
                    width: 40,
                  ),
                  horizontalTitleGap: 10,
                  minVerticalPadding: 10.0,
                  minLeadingWidth: 10,
                  title: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Revisa la ',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: ColorApp.greyText)),
                        TextSpan(
                            text: 'bandeja de entrada',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        TextSpan(
                            text: ' o ',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: ColorApp.greyText)),
                        TextSpan(
                            text: 'spam',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        TextSpan(
                            text:
                                ", te enviamos un código a tu correo electrónico: ",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: ColorApp.greyText)),
                        TextSpan(
                            text: newEmailController.text,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 285),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Código de verificación",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  constraints: BoxConstraints(maxWidth: 285),
                  height: 80,
                  child: TextFieldPin(
                      filled: true,
                      filledColor: Colors.grey[100],
                      codeLength: _otpCodeLength,
                      filledAfterTextChange: true,
                      textStyle: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0,
                      ),
                      borderStyle: OutlineInputBorder(),
                      borderStyeAfterTextChange: OutlineInputBorder(),
                      boxSize: 30,
                      onOtpCallback: (code, isAutofill) =>
                          {codeEmailController.text = code}),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: contador == 0
                      ? CupertinoButton(
                          onPressed: !cargando
                              ? () async {
                                  modificarCorreo(newEmailController.text)
                                      .then((value) => countdown())
                                      .catchError((onError) => {
                                            Alertas.showToast(
                                                mensaje: procesarMensajeError(
                                                    onError),
                                                danger: true)
                                          })
                                      .whenComplete(() => {});
                                }
                              : null,
                          child: Center(
                            child: Text(
                              "Solicitar otro correo de confirmación",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ColorApp.btnBackground,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            "Solicitar código nuevamente en $contador seg.",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ColorApp.btnBackground),
                          ),
                        ),
                )
              ],
            ),
            botones("Continuar", verificarCorreoAccion)
          ],
        ),
      ),
    );
  }

  Widget cambiarCelular() {
    VoidCallback cambiarCelularAccion = () {
      if (_formKeyCambiarCelular.currentState.validate()) {
        if (Validar.telefono(newPhoneController.text)) {
          modificarCelular(newPhoneController.text).then((value) {
            siguientePaso();
          }).catchError((onError) {
            Utilidades.imprimir("Error al modificar celular 🟥: $onError ");
            Alertas.showToast(
                mensaje: procesarMensajeError(onError), danger: true);
          });
        } else {
          Alertas.showToast(
              mensaje: "Debe ingresar un número de teléfono válido",
              danger: true);
        }
      }
    };

    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;

    return Container(
      height: screenHeight * 0.7,
      child: Form(
        key: _formKeyCambiarCelular,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 20, left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 270),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nuevo número de teléfono",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  constraints: BoxConstraints(maxWidth: 285),
                  height: 80,
                  child: TextFormField(
                    enabled: !cargando,
                    textAlign: TextAlign.center,
                    maxLength: 8,
                    controller: newPhoneController,
                    focusNode: newPhoneFocus,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Ingresa un nuevo teléfono';
                      }
                      return null;
                    },
                    onFieldSubmitted: (val) {
                      cambiarCelularAccion.call();
                    },
                    decoration: Estilos.entrada2(
                      hintText: "Ingresa un nuevo teléfono",
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  constraints: BoxConstraints(maxWidth: 285),
                  child: Text(
                      "Te enviaremos un código a tu nuevo número telefónico para verificar el cambio.",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                )
              ],
            ),
            botones("Continuar", cambiarCelularAccion)
          ],
        ),
      ),
    );
  }

  Widget verificarCelular() {
    Future verificarCelular(String code) async {
      estadoCarga(estado: true);
      Map<String, dynamic> params = {
        "update_interaction": updateInteraction,
        "code": code
      };

      await Sesion.peticion(
              tipoPeticion: TipoPeticion.PATCH,
              urlPeticion:
                  '${Constantes.urlIsuer}/api/v1/accounts/interactions',
              bodyparams: params,
              context: context)
          .then((response) {
        Utilidades.imprimir("Fase 3 - celular 🔐: $response");
      }).catchError((onError) {
        verificarForzarCerrarSesion(onError, context);
        throw onError;
      }).whenComplete(() => {
                Utilidades.imprimir("peticion a interacciones terminada 🆗"),
                estadoCarga(estado: false)
              });
    }

    VoidCallback verificarCelularAccion = () {
      if (_formKeyVerificarCelular.currentState.validate()) {
        verificarCelular(codeCelularController.text).then((value) {
          siguientePaso();
        }).catchError((onError) {
          Utilidades.imprimir("Error al verificar correo 🟥: $onError ");
          Alertas.showToast(
              mensaje: procesarMensajeError(onError), danger: true);
        });
      }
    };

    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;

    return Container(
      height: screenHeight * 0.7,
      child: Form(
        key: _formKeyVerificarCelular,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              constraints: BoxConstraints(maxWidth: 285),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: ColorApp.listFillCell,
                ),
                child: ListTileMoreCustomizable(
                  leading: Image.asset(
                    "assets/images/icon_sms.png",
                    width: 23,
                  ),
                  horizontalTitleGap: 10.0,
                  minVerticalPadding: 10.0,
                  minLeadingWidth: 10.0,
                  title: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text:
                                'Revisa tus mensajes de texto. Te enviamos un código a tu nuevo número de celular ',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: ColorApp.greyText)),
                        TextSpan(
                            text: newPhoneController.text,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 285),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Código de verificación",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )),
                SizedBox(
                  height: 10,
                ),
                if (Platform.isIOS)
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    constraints: BoxConstraints(maxWidth: 285),
                    height: 80,
                    child: TextFormField(
                        enabled: !cargando,
                        textAlign: TextAlign.center,
                        controller: codeCelularController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Ingresa el código de verificación';
                          }
                          return null;
                        },
                        onFieldSubmitted: (val) {
                          verificarCelularAccion.call();
                        },
                        keyboardType: TextInputType.text,
                        decoration: Estilos.entrada2(
                          hintText: "Ej.123456",
                        )),
                  ),
                if (Platform.isAndroid)
                  Container(
                    constraints: BoxConstraints(maxWidth: 285),
                    child: TextFieldPin(
                      margin: 5,
                      filled: true,
                      filledColor: Colors.grey[100],
                      codeLength: 6,
                      filledAfterTextChange: true,
                      borderStyle: OutlineInputBorder(),
                      borderStyeAfterTextChange: OutlineInputBorder(),
                      boxSize: 40,
                      onOtpCallback: (code, isAutofill) => _onOtpCallBack(
                          code, isAutofill, verificarCelularAccion),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  alignment: Alignment.bottomLeft,
                  child: contador == 0
                      ? CupertinoButton(
                          onPressed: !cargando
                              ? () async {
                                  modificarCelular(newPhoneController.text)
                                      .then((value) => countdown())
                                      .catchError((onError) => {
                                            Alertas.showToast(
                                                mensaje: procesarMensajeError(
                                                    onError),
                                                danger: true)
                                          })
                                      .whenComplete(() => {});
                                }
                              : null,
                          child: Center(
                            child: Text(
                              "Solicitar otro código de confirmación",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ColorApp.btnBackground,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            "Solicitar código nuevamente en $contador seg.",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ColorApp.btnBackground),
                          ),
                        ),
                )
              ],
            ),
            botones("Continuar", verificarCelularAccion)
          ],
        ),
      ),
    );
  }

  var counter = 5;

  void startTimer() {
    Timer.periodic(new Duration(seconds: 1), (time) {
      counter--;
      setState(() {});
      Utilidades.imprimir('Something $counter');
      if (counter < 1) {
        Sesion.cerrarSesion(context, proveedor: false);
        time.cancel();
      }
    });
  }

  Widget confirmacionCambio({String mensaje, bool signOut = false}) {
    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;

    return Container(
      height: screenHeight * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Image.asset(
            "assets/images/icon_correct_blue.png",
            width: 133,
          ),
          SizedBox(
            height: 60,
          ),
          signOut
              ? Text(
                  "Se cerrara sesión en $counter",
                  style: TextStyle(fontSize: 20),
                )
              : Text(""),
          Container(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Container(
                alignment: Alignment.bottomCenter,
                constraints: BoxConstraints(maxWidth: 300),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: ColorApp.listFillCell,
                ),
                child: Text(
                  mensaje,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 11),
                )),
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }

  /// Metodo que se ejecutara cuando llegue un sms con un código de un solo uso
  void _onOtpCallBack(String otpCode, bool isAutofill, VoidCallback accion) {
    codeCelularController.text = otpCode;

    Utilidades.imprimir("CODE: ${otpCode.length}");

    if (otpCode.length == 6) {
      Utilidades.imprimir("Completado automaticamente");
      accion.call();
    }
  }
}

class PasoActualizacion {
  final Widget vista;
  final String titulo;
  final VoidCallback accionCancelar;

  PasoActualizacion({this.vista, this.titulo, this.accionCancelar});
}
