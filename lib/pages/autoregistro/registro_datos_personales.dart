import 'dart:io';

import 'package:ciudadaniadigital/pages/autoregistro/widgets/terminosCondicionesWidget.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/styles/styles.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/dispositivo.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

/// Estado del formulario
final _formKey = GlobalKey<FormState>();

/// controlador del nombre
final TextEditingController nombreController = TextEditingController();

/// controlador del apellido paterno
final TextEditingController apellidoPaternoController = TextEditingController();

/// controlador del apellido materno
final TextEditingController apellidoMaternoController = TextEditingController();

/// controlador del apellido número de carnet
final TextEditingController numeroCIController = TextEditingController();

/// controlador del complemento
final TextEditingController complementoCIController = TextEditingController();

/// controlador de la fecha de nacimiento
final TextEditingController fechaNacimientoController = TextEditingController();

/// controlador de la contraseña
final TextEditingController contrasenaController = TextEditingController();

/// controlador de la contraseña repetida
final TextEditingController repetirContrasenaController =
    TextEditingController();

bool errorVisible = false;

/// Indicador si el usuario es nacional o extranjero
int opcionNacional = 1;

/// Mensaje de validación
String mensajeValidacion = "Revisa los campos indicados";

/// Flag para determinar si el usuario aceptó los términos y condiciones
bool _terminosAceptados = false;

/// Vista que muestra registro de datos personales para el auto registro
class RegistroDatosPersonales extends StatefulWidget {
  final VoidCallback accion;

  const RegistroDatosPersonales({Key key, this.accion}) : super(key: key);

  @override
  _RegistroDatosPersonalesState createState() =>
      _RegistroDatosPersonalesState();

  /// Método que registra datos personales
  static Future registarDatosPersonales() async {
    try {
      if (_formKey.currentState.validate()) {
        if (_terminosAceptados) {
          String celular = await Utilidades.readSecureStorage(key: "celular");
          String codigo = await Utilidades.readSecureStorage(key: "codigo");
          String codigoSMS =
              await Utilidades.readSecureStorage(key: "codigo_sms");
          String correo = await Utilidades.readSecureStorage(key: "correo");
          String uiid = await Dispositivo.getId();

          Map<String, String> bodyParams = {
            "celular": celular,
            "code": uiid,
            "codigo": codigo,
            "codigo_sms": codigoSMS,
            "correo": correo,
            "documento_identidad":
                Utilidades.obtenerCarnet(numeroCIController.text.trim()),
            "nombres": nombreController.text.trim(),
            "paterno": apellidoPaternoController.text.trim(),
            "materno": apellidoMaternoController.text.trim(),
            "nacional": "$opcionNacional",
            "fecha_nacimiento": fechaNacimientoController.text.trim(),
            "complemento":
                Utilidades.obtenerComplemento(numeroCIController.text.trim()),
            "contrasena": contrasenaController.text.trim(),
            "recontrasena": repetirContrasenaController.text.trim(),
          };

          var value = await Services.peticion(
              tipoPeticion: TipoPeticion.POST,
              urlPeticion:
                  "${Constantes.urlBasePreRegistroForm}registrar/persona/",
              headers: {
                HttpHeaders.userAgentHeader:
                    (await Utilidades.cabeceraUserAgent()).toString(),
                HttpHeaders.contentTypeHeader:
                    'application/json; charset=UTF-8',
                "tipo": Platform.operatingSystem.toLowerCase()
              },
              bodyparams: bodyParams);

          nombreController.text = "";
          apellidoPaternoController.text = "";
          apellidoMaternoController.text = "";
          numeroCIController.text = "";
          fechaNacimientoController.text = "";
          contrasenaController.text = "";
          repetirContrasenaController.text = "";
          opcionNacional = 1;

          Utilidades.imprimir("Respuesta : $value");
          if (value['finalizado']) {
            await Utilidades.saveSecureStorage(
                key: 'content_id_1', value: value['datos']['content_id'][0]);
            await Utilidades.saveSecureStorage(
                key: 'content_id_2', value: value['datos']['content_id'][1]);
            await Utilidades.saveSecureStorage(
                key: 'content_id_3', value: value['datos']['content_id'][2]);
            // almacenamos fecha de vigencia del preregistro
            await Utilidades.saveSecureStorage(
                key: 'fecha_vigencia',
                value: value['datos']['disponible']['fecha_literal']);
          }
        } else {
          return throw ('Debe aceptar los términos y condiciones para continuar');
        }
      } else {
        return throw (mensajeValidacion);
      }
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
      return throw (error);
    }
  }
}

class _RegistroDatosPersonalesState extends State<RegistroDatosPersonales> {
  /// Nivel de seguridad de la contraseña
  int passwordScore;

  /// Foco del controlador del nombre
  FocusNode nombreFocus = FocusNode();

  /// Foco del controlador del apellido paterno
  FocusNode apellidoPaternoFocus = FocusNode();

  /// Foco del controlador del apellido materno
  FocusNode apellidoMaternoFocus = FocusNode();

  /// Foco del controlador del número de CI
  FocusNode numeroCIFocus = FocusNode();

  /// Foco del controlador de la fecha de nacimiento
  FocusNode fechaNacimientoFocus = FocusNode();

  /// Fecha para autoregistro inicializada hace 18 años
  DateTime currentDate = DateTime.now().subtract(Duration(days: 18 * 365));

  /// Foco del controlador de la contraseña
  FocusNode contrasenaFocus = FocusNode();

  /// Foco del controlador de la contraseña repetida
  FocusNode repetirContrasenaFocus = FocusNode();

  /// Indicador para mostrar la contraseña
  bool iconoPassword = true;

  /// Indicador para mostrar la repetida
  bool iconoPasswordRepetir = true;

  /// edad mínima de registro en años
  final int edadMinima = 18;

  _RegistroDatosPersonalesState();

  /// Opciones para identificar si una persona es nacional o extranjera
  static Map<int, Widget> opcionesNacionalWidget = {
    1: Container(
      width: 200,
      child: Center(child: Text('Boliviano (a)')),
    ),
    2: Container(
      width: 200,
      child: Center(child: Text('Extranjero (a)')),
    )
  };

  /// Identificador para saber si estamos en una tableta y asignar un ancho a la interfaz
  double ancho = Dispositivo.esTablet() ? 280 : 300;

  /// Método que muestra un selector para la fecha de nacimiento

  void callDatePicker() async {
    Utilidades.imprimir('Escogiendo fecha: $currentDate 🕐');

    DateTime dateMin = DateTime.now()
        .toLocal()
        .subtract(Duration(days: 100 * 365)); // edad máxima 100 años
    DateTime dateMax = DateTime.now().toLocal().subtract(Duration(
        days:
            edadMinima * 365 + Utilidades.cantidadAniosBisiestos(edadMinima)));

    currentDate = await DatePicker.showDatePicker(context,
            currentTime: currentDate,
            minTime: dateMin,
            maxTime: dateMax,
            showTitleActions: true,
            locale: LocaleType.es,
            theme: DatePickerTheme(
                doneStyle: TextStyle(color: ColorApp.btnBackground))) ??
        currentDate;

    if (currentDate != null) {
      setState(() {
        fechaNacimientoController.text =
            DateFormat('dd/MM/yyyy').format(currentDate);
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FocusScope.of(context).unfocus());
    super.initState();

    passwordScore = 0;
  }

  /// Widget que muestra una alerta de seguridad
  Widget alertaSeguridad() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
          decoration: BoxDecoration(
            color: ColorApp.buttonsBackGround,
            border: Border.all(
              color: ColorApp.buttons,
              width: 1,
            ),
          ),
          child: ListTileMoreCustomizable(
            leading: Image.asset(
              "assets/images/icon_lock.png",
              width: 20,
              height: 20,
            ),
            title: Text(
              "Formulario seguro",
              style: TextStyle(
                  color: ColorApp.buttonsborder,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              "Tus datos están seguros, no son almacenados, son verificados con los datos en SEGIP.",
              style: TextStyle(color: ColorApp.buttons, fontSize: 11),
            ),
            horizontalTitleGap: 0.0,
            minVerticalPadding: 0.0,
            minLeadingWidth: 40.0,
          ),
        ),
      ],
    );
  }

  /// Widget que muestra el campo del nombre
  Widget nombre() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            constraints: BoxConstraints(maxWidth: ancho),
            alignment: Alignment.centerLeft,
            child: Text(
              "Nombre (s)",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w700),
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: ancho),
          child: TextFormField(
            controller: nombreController,
            focusNode: nombreFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (String value) {
              FocusScope.of(context).requestFocus(apellidoPaternoFocus);
            },
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value.isEmpty) {
                return 'Ingresa tu(s) nombre(s)';
              }
              return null;
            },
            decoration: Estilos.entrada2(hintText: "Ingresa tu(s) nombre(s)"),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  /// Widget que muestra el campo del apellido paterno
  Widget apellidoPaterno() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            constraints: BoxConstraints(maxWidth: ancho),
            alignment: Alignment.centerLeft,
            child: Text(
              "Apellido Paterno",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w700),
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: ancho),
          child: TextFormField(
            focusNode: apellidoPaternoFocus,
            controller: apellidoPaternoController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
            onFieldSubmitted: (String value) {
              FocusScope.of(context).requestFocus(apellidoMaternoFocus);
            },
            validator: (value) {
              if (value.isEmpty && apellidoMaternoController.text.length == 0) {
                return 'Ingresa tu apellido paterno';
              }
              return null;
            },
            decoration:
                Estilos.entrada2(hintText: "Ingresa tu apellido paterno"),
            keyboardType: TextInputType.text,
          ),
        )
      ],
    );
  }

  /// Widget que muestra el campo del apellido materno
  Widget apellidoMaterno() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            constraints: BoxConstraints(maxWidth: ancho),
            alignment: Alignment.centerLeft,
            child: Text(
              "Apellido Materno",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w700),
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: ancho),
          child: TextFormField(
            controller: apellidoMaternoController,
            textInputAction: TextInputAction.next,
            focusNode: apellidoMaternoFocus,
            onFieldSubmitted: (String value) {
              FocusScope.of(context).requestFocus(fechaNacimientoFocus);
            },
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value.isEmpty && apellidoPaternoController.text.length == 0) {
                return 'Ingresa tu apellido paterno';
              }
              return null;
            },
            decoration:
                Estilos.entrada2(hintText: "Ingresa tu apellido materno"),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  /// Widget que muestra el campo de la cédula de identidad
  Widget cedulaIdentidad() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            constraints: BoxConstraints(maxWidth: ancho),
            alignment: Alignment.centerLeft,
            child: Text(
              "Cédula de Identidad",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w700),
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: ancho),
          child: TextFormField(
            controller: numeroCIController,
            textInputAction: TextInputAction.next,
            focusNode: numeroCIFocus,
            onFieldSubmitted: (String value) {
              FocusScope.of(context).requestFocus(nombreFocus);
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Ingresa tu número de CI';
              }
              return null;
            },
            decoration: Estilos.entrada2(hintText: "Ingresa tu número de CI"),
            keyboardType: TextInputType.text,
          ),
        )
      ],
    );
  }

  /// Widget que muestra la fecha de nacimiento
  Widget fechaNacimiento() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            constraints: BoxConstraints(maxWidth: ancho),
            alignment: Alignment.centerLeft,
            child: Text(
              "Fecha de Nacimiento",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w700),
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: ancho),
          child: TextFormField(
            controller: fechaNacimientoController,
            textInputAction: TextInputAction.next,
            focusNode: fechaNacimientoFocus,
            onFieldSubmitted: (String value) {
              FocusScope.of(context).requestFocus(contrasenaFocus);
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Ingresa tu fecha de nacimiento';
              }
              return null;
            },
            onTap: () {
              callDatePicker();
            },
            decoration: Estilos.entrada2(hintText: "dd/mm/aaaa"),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  /// Widget que muestra las opciones para saber si una persona es nacional o extranjera
  Widget opcionesNacional() {
    return Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: ancho),
          height: 90,
          alignment: Alignment.center,
          child: MaterialSegmentedControl(
            children: opcionesNacionalWidget,
            selectionIndex: opcionNacional,
            borderColor: Colors.grey,
            selectedColor: ColorApp.btnBackground,
            unselectedColor: Colors.white,
            borderRadius: 5.0,
            disabledChildren: [],
            onSegmentChosen: (index) {
              setState(() {
                opcionNacional = index;
              });
              Utilidades.imprimir("opcionNacional: $opcionNacional");
            },
          ),
        ),
      ],
    );
  }

  /// Widget que muestra la contraseña
  Widget contrasena() {
    return Column(children: <Widget>[
      SizedBox(
        height: 10,
      ),
      Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: ancho),
          alignment: Alignment.centerLeft,
          child: Text(
            "Contraseña",
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.w700),
          )),
      SizedBox(
        height: 10,
      ),
      Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        constraints: BoxConstraints(maxWidth: ancho),
        child: TextFormField(
          controller: contrasenaController,
          focusNode: contrasenaFocus,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            passwordScore = Utilidades.estimadorFortalezaPassword(
                value); // posibles valores: [0 .. 4]
            Utilidades.imprimir('FORTALEZA CONTRASEÑA $value | $passwordScore');
            setState(() {});
          },
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(repetirContrasenaFocus),
          validator: (value) {
            if (value.isEmpty) {
              return 'Ingresa una nueva contraseña';
            } else {
              if (passwordScore < 3) {
                Dialogo.mostrarDialogoNativo(
                    context,
                    "¿Cómo es una contraseña segura?",
                    Text(
                      "Las contraseñas deben tener 6 caracteres o más. Las buenas contraseñas son difíciles de adivinar y usan palabras, números, símbolos y letras mayúsculas poco comunes.",
                      textAlign: TextAlign.start,
                    ),
                    "Aceptar",
                    () {},
                    firstActionStyle: ActionStyle.important);
                return throw ('La contraseña no es segura');
              }
            }
            return null;
          },
          obscureText: iconoPassword,
          decoration: Estilos.entradaSegura2(
              hintText: "Ingresa una contraseña segura",
              accion: () {
                setState(() {
                  iconoPassword = !iconoPassword;
                });
              },
              estado: iconoPassword),
          keyboardType: TextInputType.text,
        ),
      ),
    ]);
  }

  /// Widget que muestra la contraseña repetida
  Widget repetirContrasena() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            constraints: BoxConstraints(maxWidth: ancho),
            alignment: Alignment.centerLeft,
            child: Text(
              "Repite la Contraseña",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w700),
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          constraints: BoxConstraints(maxWidth: ancho),
          child: TextFormField(
            focusNode: repetirContrasenaFocus,
            controller: repetirContrasenaController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) =>
                {FocusScope.of(context).unfocus(), widget.accion.call()},
            validator: (value) {
              setState(() {
                errorVisible = false;
              });
              if (value.isEmpty) {
                return 'repite tu nueva contraseña';
              } else {
                if (contrasenaController.text != value) {
                  return 'La contraseña no coincide';
                }
              }
              return null;
            },
            onChanged: (value) {
              errorVisible = contrasenaController.text != value;
              setState(() {});
            },
            obscureText: iconoPasswordRepetir,
            decoration: Estilos.entradaSegura2(
                hintText: "Repite tu contraseña",
                accion: () {
                  setState(() {
                    iconoPasswordRepetir = !iconoPasswordRepetir;
                  });
                },
                estado: iconoPasswordRepetir),
            keyboardType: TextInputType.text,
          ),
        ),
        errorVisible
            ? Container(
                constraints: BoxConstraints(maxWidth: ancho),
                width: double.infinity,
                padding: EdgeInsets.only(left: 22, right: 10),
                child: Text(
                  "La contraseña no coincide",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 12, color: ColorApp.colorPass1),
                ),
              )
            : SizedBox()
      ],
    );
  }

  Widget ayudaCarnet() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              constraints: BoxConstraints(maxWidth: ancho),
              child: Image.asset(
                "assets/images/logo_carnet.png",
                height: 150,
              )),
          Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              constraints: BoxConstraints(maxWidth: ancho),
              child: RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: " * ", style: TextStyle(color: Colors.red)),
                      TextSpan(
                          text:
                              "Ingresa tu número, tal cual está en tu cédula de identidad.")
                    ]),
              )),
          Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              constraints: BoxConstraints(maxWidth: ancho),
              child: RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              "Si tu carnet tiene complemento (ej. 1K ; 1E), tu usuario es: "),
                      TextSpan(
                          text: " 1234567-1K ",
                          style: TextStyle(color: Colors.red))
                    ]),
              )),
        ],
      ),
    );
  }

  /// Widget que muestra un boton para cargar los terminos y condiciones
  Widget terminosYCondiciones() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: ancho),
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    activeColor: ColorApp.primary,
                    value: _terminosAceptados,
                    onChanged: (bool value) async {
                      setState(() {
                        _terminosAceptados = value;
                      });
                      if (_terminosAceptados) await Dialogo.showNativeModalBottomSheet(context, TerminosCondiciones());
                    },
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () async {
                        if (!_terminosAceptados) await Dialogo.showNativeModalBottomSheet(context, TerminosCondiciones());
                        _terminosAceptados = !_terminosAceptados;
                        setState(() { });
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                          TextSpan(text: "He leído y acepto los ${MediaQuery.of(context).size.width <= 320 ? "\n" : ""}"),
                          TextSpan(
                              text: "términos y condiciones.",
                              style: TextStyle(
                                  // color: ColorApp.buttonsborder,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline))
                        ]),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget que muestra la vista en portrait del formulario
  Widget vistaPortrait() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // alertaSeguridad(),
          cedulaIdentidad(),
          ayudaCarnet(),
          nombre(),
          apellidoPaterno(),
          apellidoMaterno(),
          fechaNacimiento(),
          opcionesNacional(),
          contrasena(),
          repetirContrasena(),
          Elementos.seguridad(passwordScore, context),
          terminosYCondiciones()
        ],
      ),
    );
  }

  /// Widget que muestra la vista en landscape del formulario
  Widget vistaLandscape() {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 5),
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // alertaSeguridad(),
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      cedulaIdentidad(),
                      nombre(),
                      apellidoPaterno()
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      ayudaCarnet(),
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[apellidoMaterno(), fechaNacimiento()],
              ),
              Row(
                children: <Widget>[
                  contrasena(),
                  repetirContrasena(),
                ],
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  Elementos.seguridad(passwordScore, context),
                  opcionesNacional()
                ],
              )),
              terminosYCondiciones()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 600
        ? vistaLandscape()
        : vistaPortrait();
  }
}
