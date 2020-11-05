import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ciudadaniadigital/pages/autoregistro/camara_vista.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/Services.dart';
import 'package:ciudadaniadigital/utilidades/alertas.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Archivo de la imagen de perfil
File fileSelfie;

/// Archivo de la imagen de carnet en anverso
File fileCarnetAnverso;

/// Archivo de la imagen de carnet en reverso
File fileCarnetReverso;

String messageErrorImage = "La imagen es de baja calidad";
bool showHideMessageError = false;

/// Vista del resumen de fotos
class ResumenFotos extends StatefulWidget {
  /// Vista de la acción en la vista principal
  final VoidCallback accion;

  const ResumenFotos({Key key, this.accion}) : super(key: key);

  @override
  _ResumenFotosState createState() => _ResumenFotosState();

  /// Método que envia las fotos que se tomaron y las elimina de la memoria temporal
  static Future verificarFotos() async {
    if (fileSelfie != null && fileCarnetReverso != null && fileCarnetAnverso != null) {
      List<bool> flagFotosOk = [false, false, false];
      String contentId1 = await Utilidades.readSecureStorage(key: 'content_id_1');
      String contentId2 = await Utilidades.readSecureStorage(key: 'content_id_2');
      String contentId3 = await Utilidades.readSecureStorage(key: 'content_id_3');
      String pathImage1 = await Utilidades.readSecureStorage(key: 'path_image_1');
      String pathImage2 = await Utilidades.readSecureStorage(key: 'path_image_2');
      String pathImage3 = await Utilidades.readSecureStorage(key: 'path_image_3');
      // mandamos foto comprimido con lz string
      Map<String, String> bodyParams = {'base64lz': await Utilidades.compresionLZString(pathImage1)};
      Utilidades.imprimir('PETICION POST a: ${Constantes.urlBasePreRegistroForm}imagenes/1/json');
      Utilidades.imprimir('HEADER: {Content-Id: $contentId1, Content-Type: "application/json"}');
      var peticion = await Services.peticion(
          tipoPeticion: TipoPeticion.POST,
          urlPeticion: "${Constantes.urlBasePreRegistroForm}imagenes/1/json",
          headers: {'Content-Id': contentId1, 'Content-Type': 'application/json', "tipo": Platform.operatingSystem.toLowerCase()},
          bodyparams: bodyParams);
      Utilidades.imprimir("Respuesta : ${peticion.toString()}");
      /*if (peticion['finalizado']) {
        File imagen1 = File(pathImage1);
        await imagen1.delete();
        Utilidades.imprimir('archivo $pathImage1 borrado...');
      }*/
      flagFotosOk[0] = peticion['finalizado'] ?? false;

      bodyParams = {'base64lz': await Utilidades.compresionLZString(pathImage2)};
      Utilidades.imprimir('PETICION POST a: ${Constantes.urlBasePreRegistroForm}imagenes/2/json');
      Utilidades.imprimir('HEADER: {Content-Id: $contentId2, Content-Type: "application/json"}');
      peticion = await Services.peticion(
          tipoPeticion: TipoPeticion.POST,
          urlPeticion: "${Constantes.urlBasePreRegistroForm}imagenes/2/json",
          headers: {'Content-Id': contentId2, 'Content-Type': 'application/json', "tipo": Platform.operatingSystem.toLowerCase()},
          bodyparams: bodyParams);
      Utilidades.imprimir("Respuesta : ${peticion.toString()}");
      /*if (peticion['finalizado']) {
        File imagen2 = File(pathImage2);
        await imagen2.delete();
        Utilidades.imprimir('archivo $pathImage2 borrado...');
      }*/
      flagFotosOk[1] = peticion['finalizado'] ?? false;

      bodyParams = {'base64lz': await Utilidades.compresionLZString(pathImage3)};
      Utilidades.imprimir('PETICION POST a: ${Constantes.urlBasePreRegistroForm}imagenes/3/json');
      Utilidades.imprimir('HEADER: {Content-Id: $contentId3, Content-Type: "application/json"}');
      peticion = await Services.peticion(
          tipoPeticion: TipoPeticion.POST,
          urlPeticion: "${Constantes.urlBasePreRegistroForm}imagenes/3/json",
          headers: {'Content-Id': contentId3, 'Content-Type': 'application/json', "tipo": Platform.operatingSystem.toLowerCase()},
          bodyparams: bodyParams);
      Utilidades.imprimir("Respuesta : ${peticion.toString()}");
      /*if (peticion['finalizado']) {
        File imagen3 = File(pathImage3);
        await imagen3.delete();
        Utilidades.imprimir('archivo $pathImage3 borrado...');
      }*/
      flagFotosOk[2] = peticion['finalizado'] ?? false;

      if (!flagFotosOk.contains(false)) {
        showHideMessageError = false;
        // Todas las peticiones fueron correctas, se borran las fotos
        File imagen = File(pathImage1);
        await imagen.delete();
        Utilidades.imprimir('archivo $pathImage1 borrado...');

        imagen = File(pathImage2);
        await imagen.delete();
        Utilidades.imprimir('archivo $pathImage2 borrado...');

        imagen = File(pathImage3);
        await imagen.delete();
        Utilidades.imprimir('archivo $pathImage3 borrado...');
      } else {
        showHideMessageError = true;
      }
    } else {
      return throw ("Debe completar todas las fotografías");
    }
  }
}

class _ResumenFotosState extends State<ResumenFotos> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await selectFromImagePickerSelfie();
      await Future.delayed(Duration(seconds: 1));
      await selectFromImagePickerCarnetAnverso();
      await Future.delayed(Duration(seconds: 1));
      await selectFromImagePickerCarnetReverso();
    });
  }

  /// Indicador de progreso para tomar fotos
  bool ocupado = false;

  /// Objeto que abre las imagenes
  final picker = ImagePicker();

  /// Método que abre la vista de cámara
  Future<File> obtenerImagen(tipoFoto opcionFoto) async {
    // return await picker.getImage(source: ImageSource.camera).whenComplete(() => ajustarProgreso(val: false));
    final List cameras = await availableCameras();
    if (cameras.length > 0) {
      String path = await Dialogo.showNativeModalBottomSheet(
          context,
          TakePictureScreen(
            cameras: cameras,
            opcionFoto: opcionFoto,
          )).whenComplete(() => ajustarProgreso(val: false));

      // convertimos a formato PNG
      // String pathPng = Utilidades.convertJpgToPng(path);

      return path == null ? null : File(path);
    } else {
      Alertas.showToast(mensaje: "No se encontraron cámaras en el dispositivo", danger: true);
      ajustarProgreso(val: false);
      return null;
    }
  }

  /// Método que al tomar la foto, guarda el directorio en el almacenamiento seguro
  Future selectFromImagePickerSelfie() async {
    ajustarProgreso(val: true);

    var image = await obtenerImagen(tipoFoto.Selfie);

    if (image == null) return;

    await Utilidades.saveSecureStorage(key: 'path_image_1', value: image.path);

    setState(() {
      Utilidades.imprimir("Imagen selfie en ${image.path}");
      fileSelfie = File(image.path);
    });
  }

  /// Método que tomar la foto del carnet anverso
  Future selectFromImagePickerCarnetAnverso() async {
    ajustarProgreso(val: true);
    var image = await obtenerImagen(tipoFoto.CarnetAnverso);

    if (image == null) return;
    await Utilidades.saveSecureStorage(key: 'path_image_2', value: image.path);

    setState(() {
      Utilidades.imprimir("Imagen anverso en ${image.path}");
      fileCarnetAnverso = File(image.path);
    });
  }

  /// Método que tomar la foto del carnet reverso
  Future selectFromImagePickerCarnetReverso() async {
    ajustarProgreso(val: true);
    var image = await obtenerImagen(tipoFoto.CarnerReverso);

    if (image == null) return;
    await Utilidades.saveSecureStorage(key: 'path_image_3', value: image.path);

    setState(() {
      Utilidades.imprimir("Imagen reverso en ${image.path}");
      fileCarnetReverso = File(image.path);
    });
  }

  /// Método que cambia el estado del progreso
  void ajustarProgreso({bool val}) {
    setState(() {
      ocupado = val;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    fileSelfie = null;
    fileCarnetAnverso = null;
    fileCarnetReverso = null;
    super.dispose();
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
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(right: 30, left: 30),
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: ColorApp.listFillCell,
            ),
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              alignment: Alignment.bottomCenter,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                  TextSpan(
                      text:
                          "A continuación aparecerán todas las fotografías que sacaste. Por favor, revisa y confirma las mismas para adicionarlas al sistema.",
                      style: TextStyle(
                        color: ColorApp.greyText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                  TextSpan(
                      text: "\n\nEn caso de querer volver a sacar alguna, solo presiona sobre la misma.",
                      style: TextStyle(
                        color: ColorApp.alert,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                ]),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 210,
            child: Visibility(
              visible: ocupado,
              child: Elementos.indicadorProgresoLineal(),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.only(right: 20, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      child: Text("Selfie"),
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        selectFromImagePickerSelfie();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: fileSelfie == null
                            ? Container(
                                width: 109,
                                height: 200,
                                decoration: BoxDecoration(
                                  image: new DecorationImage(
                                    colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.4), BlendMode.dstATop),
                                    image: AssetImage("assets/images/imagen-ciudadania-selfie-carnet 1.png"),
                                  ),
                                ),
                              )
                            : Image.file(
                                fileSelfie,
                                width: 109,
                                height: 200,
                              ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 109,
                      child: Text(
                        showHideMessageError ? messageErrorImage : "",
                        style: TextStyle(color: ColorApp.errorRequest, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          child: Text("CI. Anverso"),
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            selectFromImagePickerCarnetAnverso();
                          },
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 160),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red, width: 2),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: fileCarnetAnverso == null
                                      ? Container(
                                          height: 100,
                                          width: 140,
                                          decoration: BoxDecoration(
                                            image: new DecorationImage(
                                              colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.4), BlendMode.dstATop),
                                              image: AssetImage("assets/images/imagen_carnet_anverso.png"),
                                            ),
                                          ),
                                        )
                                      : Image.file(
                                          fileCarnetAnverso,
                                          width: 100,
                                          height: 140,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          child: Text("CI. Reverso"),
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            selectFromImagePickerCarnetReverso();
                          },
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 160),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red, width: 2),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: fileCarnetReverso == null
                                      ? Container(
                                          height: 100,
                                          width: 140,
                                          decoration: BoxDecoration(
                                            image: new DecorationImage(
                                              colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.4), BlendMode.dstATop),
                                              image: AssetImage("assets/images/image_carnet_reverso.png"),
                                            ),
                                          ),
                                        )
                                      : Image.file(
                                          fileCarnetReverso,
                                          width: 100,
                                          height: 140,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )
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
}
