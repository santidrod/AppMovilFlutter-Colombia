import 'package:camera/camera.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/Elementos.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

/// enum con opciones para sacar fotografía de perfil o de carnet

enum tipoFoto { Selfie, CarnetAnverso, CarnerReverso }

class TakePictureScreen extends StatefulWidget {
  /// Lista de cámaras disponibles
  final List<CameraDescription> cameras;

  /// Opción seleccionada para mostrar la interfaz de la cámara
  final tipoFoto opcionFoto;

  TakePictureScreen({@required this.cameras, @required this.opcionFoto});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> with WidgetsBindingObserver {
  /// Controlador de la cámara
  CameraController _controller;

  /// Método que inicialice el controlador de la cámara para mostrar la interfaz
  Future<void> _initializeControllerFuture;

  /// Descripción de la cámara seleccionada
  CameraDescription selectedCamera;

  /// Indicador de primera cámara seleccionada
  bool usarPrimeraCamara = true;

  int selectedCameraIdx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Utilidades.imprimir("Cantidad de camaras: ${widget.cameras}");

    usarPrimeraCamara = widget.opcionFoto == tipoFoto.Selfie;

    if (widget.cameras.length > 0) {
      selectedCamera = usarPrimeraCamara ? widget.cameras.last : widget.cameras.first;

      setState(() {
        if (usarPrimeraCamara) {
          selectedCameraIdx = widget.cameras.length - 1;
        } else {
          selectedCameraIdx = 0;
        }
      });
      inicializarCamara();
    } else {
      Utilidades.imprimir("No camera available");
    }
  }

  /// Inicializador de la cámara
  void inicializarCamara() {
    _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        selectedCamera,
        // Define the resolution to use.
        ResolutionPreset.medium,
        enableAudio: false);
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  /// Widget que contiene la silueta de la vista de selfie
  Widget vistaSiluetaSelfie() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.lighten), // This one will create the magic
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: 400),
            padding: EdgeInsets.only(left: 80, right: 80),
            child: AspectRatio(
              aspectRatio: 262 / 322,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  border: Border.all(color: Colors.red, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            padding: EdgeInsets.only(left: 80, right: 80),
            child: Container(
              child: AspectRatio(
                aspectRatio: 306 / 166,
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red, width: 2)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Widget que contiene la silueta de la vista de carnet
  Widget vistaSiluetaCarnet() {
    return ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.lighten), // This one will create the magic
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              padding: EdgeInsets.only(left: 48, right: 48),
              child: Container(
                child: AspectRatio(
                  aspectRatio: 462 / 296,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red, width: 2)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ));
  }

  /// Widget que contiene indicaciones de la vista de silueta
  Widget vistaIndicacionSilueta() {
    return Container(
        padding: EdgeInsets.only(right: 48, left: 48),
        alignment: Alignment.center,
        height: 100,
        constraints: BoxConstraints(maxWidth: 400),
        child: StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return Column(
                children: <Widget>[
                  ListTile(
                    title: RichText(
                      text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                        TextSpan(text: "Asegúrate de estar dentro de los recuadros", style: TextStyle(color: Colors.white)),
                        TextSpan(text: " rojos ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                        TextSpan(text: "sosteniendo tu CI.", style: TextStyle(color: Colors.white)),
                      ]),
                    ),
                    /*subtitle:
                        Text("El telefono tiene ${widget.cameras.length} cámaras", style: TextStyle(color: Colors.white, fontSize: 9)),*/
                    trailing: GestureDetector(
                      onTap: cambiarCamara,
                      child: Icon(
                        Icons.switch_camera,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Espacio para tu rostro",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            }));
  }

  /// Widget que contiene indicaciones de la vista de carnet
  Widget vistaIndicacionCarnet() {
    return Container(
      padding: EdgeInsets.only(right: 48, left: 48),
      alignment: Alignment.center,
      height: 40,
      constraints: BoxConstraints(maxWidth: 400),
      child: Text(
        "Espacio para tu C.I.",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  /// Widget que contiene indicaciones del anverso del carnet
  Widget imagenCarnetAnverso() {
    return Container(
      padding: EdgeInsets.only(right: 48, left: 48),
      alignment: Alignment.bottomCenter,
      child: Image.asset(
        "assets/images/imagen_carnet_anverso.png",
        width: 250,
        alignment: Alignment.center,
      ),
    );
  }

  /// Widget que contiene indicaciones del reverso del carnet
  Widget imagenCarnetReverso() {
    return Container(
      padding: EdgeInsets.only(right: 48, left: 48),
      alignment: Alignment.bottomCenter,
      child: Image.asset(
        "assets/images/image_carnet_reverso.png",
        width: 250,
        alignment: Alignment.center,
      ),
    );
  }

  /// Método que intercambia las cámaras
  void cambiarCamara() {
    setState(() {
      selectedCameraIdx = selectedCameraIdx < widget.cameras.length - 1 ? selectedCameraIdx + 1 : 0;
      selectedCamera = widget.cameras[selectedCameraIdx];
    });
    inicializarCamara();
  }

  /// Widget que muestran los botones tomar fotografía y cancelar
  Widget botones() {
    return Container(
      padding: EdgeInsets.only(right: 10, left: 10),
      child: Column(
        children: [
          SizedBox(height: usarPrimeraCamara ? 0 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButton(
                child: Container(
                    child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                )),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              SizedBox(
                width: 20,
              ),
              RaisedButton(
                child: Container(
                  alignment: Alignment.center,
                  width: 128,
                  height: 40,
                  child: Text(
                    "Tomar foto",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                onPressed: () async {
                  // Take the Picture in a try / catch block. If anything goes wrong,
                  // catch the error.
                  try {
                    // Ensure that the camera is initialized.
                    await _initializeControllerFuture;

                    // Construct the path where the image should be saved using the
                    // pattern package.
                    final path = join(
                      // Store the picture in the temp directory.
                      // Find the temp directory using the `path_provider` plugin.
                      (await getTemporaryDirectory()).path,
                      '${DateTime.now()}.jpg',
                    );

                    // Attempt to take a picture and log where it's been saved.
                    await _controller.takePicture(path);

                    // If the picture was taken, display it on a new screen.
                    Navigator.pop(context, path);
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    Utilidades.imprimir(e);
                  }
                },
                color: ColorApp.buttons,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42.0)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Indicaciones de la anverso del carnet
  Widget vistaIndicacionAnverso() {
    return Container(
        padding: EdgeInsets.only(right: 48, left: 48),
        alignment: Alignment.center,
        height: 90,
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          children: <Widget>[
            ListTile(
              title: RichText(
                text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                  TextSpan(text: "Asegúrate de ubicar el ANVERSO de tu CI en el recuadro", style: TextStyle(color: Colors.white)),
                  TextSpan(text: " rojo ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                ]),
              ),
              trailing: GestureDetector(
                onTap: cambiarCamara,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ));
  }

  /// Indicaciones de la reverso del carnet
  Widget vistaIndicacionReverso() {
    return Container(
        padding: EdgeInsets.only(right: 48, left: 48),
        alignment: Alignment.center,
        height: 90,
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          children: <Widget>[
            ListTile(
              title: RichText(
                text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                  TextSpan(text: "Asegúrate de ubicar el REVERSO de tu CI en el recuadro", style: TextStyle(color: Colors.white)),
                  TextSpan(text: " rojo ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                ]),
              ),
              trailing: GestureDetector(
                onTap: cambiarCamara,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final sizeHeight = MediaQuery.of(context).size.height;
    final deviceRatio = sizeWidth / sizeHeight;
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Container(
              width: sizeWidth,
              height: sizeHeight,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      width: sizeWidth,
                      height: sizeHeight,
                      child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            // If the Future is complete, display the preview.
                            return Stack(
                              children: <Widget>[
                                Center(
                                  child: Transform.scale(
                                    scale: _controller.value.aspectRatio / deviceRatio,
                                    // no tocar, es la proporción de la pantalla para la cámara
                                    child: new AspectRatio(
                                      aspectRatio: _controller.value.aspectRatio,
                                      child: new CameraPreview(_controller),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        widget.opcionFoto == tipoFoto.Selfie
                                            ? vistaIndicacionSilueta()
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        widget.opcionFoto == tipoFoto.Selfie
                                            ? vistaSiluetaSelfie()
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        widget.opcionFoto == tipoFoto.CarnetAnverso
                                            ? vistaIndicacionAnverso()
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        widget.opcionFoto == tipoFoto.CarnerReverso
                                            ? vistaIndicacionReverso()
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        widget.opcionFoto == tipoFoto.CarnetAnverso || widget.opcionFoto == tipoFoto.CarnerReverso
                                            ? vistaSiluetaCarnet()
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        widget.opcionFoto == tipoFoto.Selfie
                                            ? vistaIndicacionCarnet()
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        widget.opcionFoto == tipoFoto.CarnetAnverso
                                            ? imagenCarnetAnverso()
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        widget.opcionFoto == tipoFoto.CarnerReverso
                                            ? imagenCarnetReverso()
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        botones()
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Otherwise, display a loading indicator.
                            return Center(child: Elementos.indicadorProgresoCircularNativo());
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
