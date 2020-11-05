import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/ConfiguracionAlertas.dart';
import 'package:ciudadaniadigital/pages/ciudadania_tabs/opciones/ConfiguracionNotificaciones.dart';
import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Vista que muestra las opciones configurables de la aplicación

class ConfiguracionesWidget extends StatefulWidget {
  const ConfiguracionesWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfiguracionesWidgetState();
}

class _ConfiguracionesWidgetState extends State<ConfiguracionesWidget> with WidgetsBindingObserver {
  /// Flag para alternar configuraciones
  bool _mostrarAlertas = true;

  _ConfiguracionesWidgetState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.clear,
                color: ColorApp.greyDarkText,
              ),
            ),
          ],
        ),
        body: Container(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5, bottom: 20),
                          child: Text(
                            "Configuraciones",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                                  child: FlatButton(
                                      onPressed: () {
                                        _mostrarAlertas = !_mostrarAlertas;
                                        setState(() {});
                                      },
                                      padding: EdgeInsets.all(0.0),
                                      child: Container(
                                        // color: ColorApp.btnBackground,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: _mostrarAlertas ? ColorApp.btnBackground : Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                                              child: Icon(
                                                Icons.notifications,
                                                color: _mostrarAlertas ? Colors.white : ColorApp.colorGrisClaro,
                                                size: 20,
                                              ),
                                            ),
                                            Text(
                                              'Alertas',
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(color: _mostrarAlertas ? Colors.white : ColorApp.colorGrisClaro, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      shape: !_mostrarAlertas
                                          ? RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0), side: BorderSide(color: ColorApp.colorGrisClaro))
                                          : null),
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                                    child: FlatButton(
                                      color: _mostrarAlertas ? Colors.white : ColorApp.btnBackground,
                                      shape: _mostrarAlertas
                                          ? RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0), side: BorderSide(color: ColorApp.colorGrisClaro))
                                          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                      onPressed: () {
                                        _mostrarAlertas = !_mostrarAlertas;
                                        setState(() {});
                                      },
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                                              child: Icon(
                                                Icons.settings,
                                                color: _mostrarAlertas ? ColorApp.colorGrisClaro : Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                'Trámites a notificar',
                                                style: TextStyle(
                                                    color: _mostrarAlertas ? ColorApp.colorGrisClaro : Colors.white, fontSize: 12),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  flex: 2)
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              if (_mostrarAlertas) ConfiguracionAlertas(),
              if (!_mostrarAlertas) ConfiguracionNotificaciones(),
            ],
          ),
        ));
  }
}
