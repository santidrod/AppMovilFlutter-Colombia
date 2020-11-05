import 'package:ciudadaniadigital/utilidades/colores.dart';
import 'package:ciudadaniadigital/utilidades/dialogos.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter/material.dart';

/// Vista que muestra el paso final del registro remoto
class FinalizadoRemoto extends StatefulWidget {
  const FinalizadoRemoto({Key key}) : super(key: key);

  @override
  _FinalizadoRemotoState createState() => _FinalizadoRemotoState();

  /// Acción desde Widget principal
  static Future verificadoAccion() async {
    try {
      Utilidades.imprimir("Respuesta : Continuar");
    } catch (error) {
      Utilidades.imprimir('ocurrio un error: $error');
    }
  }
}

class _FinalizadoRemotoState extends State<FinalizadoRemoto> {
  _FinalizadoRemotoState();

  // DateTime _fechaLimite = DateTime.now().toLocal();
  String _fechaLimite;

  @override
  void initState() {
    super.initState();

    /// Fecha limite dentro de 3 dias
    obtieneFechaLimite();
    /*rootBundle.loadStri
    ng('assets/raw/feriadosBolivia.json').then((value) {
      List<dynamic> calendarioFeriados = jsonDecode(value);
      DateTime today = DateTime.now().toLocal();
      List<dynamic> feriados = calendarioFeriados.where((element) => element["year"] == today.year).first["holidays"];
      _fechaLimite = obtieneDiasHabiles(3, feriados);
      setState(() {});
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 48, right: 48),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: ColorApp.listFillCell,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 25, right: 25),
                child: Text(
                  'Para terminar tu verificación, serás contactado mediante videollamada por un operador de registro de ciudadanía digital hasta el día $_fechaLimite, en el horario seleccionado.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100),
                ),
              )),
          SizedBox(
            height: 35,
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 25, right: 25),
            constraints: BoxConstraints(maxWidth: 550),
            child: Text(
              'Por favor mantente conectado a Internet y atiende nuestra llamada',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 25, right: 25),
            constraints: BoxConstraints(maxWidth: 550),
            child: Text(
              'Si no obtenemos respuesta hasta el día $_fechaLimite, tu solicitud de registro será anulada y tendrás que llenar nuevamente este formulario.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100),
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Visibility(
            visible: false,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 25, right: 25),
              constraints: BoxConstraints(maxWidth: 550),
              child: FlatButton(
                onPressed: () {
                  Dialogo.mostrarDialogoNativo(
                      context,
                      "La seguridad de tu información es nuestra prioridad",
                      Text(
                          "\nSi no completas tu verificación hasta la fecha establecida borraremos toda la información de tu registro y tendrás que volver a llenar este formulario."),
                      "Aceptar",
                      () {});
                },
                child: Text(
                  '¿Qué ocurre si no atiendes la llamada?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ColorApp.alert),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Método para calcular fecha luego de X días sin contar fines de semana y feriados
  DateTime obtieneDiasHabiles(int dias, List<dynamic> feriados) {
    if (dias > 0) {
      int cantidadHabiles = 1;
      DateTime fechaCalculada = new DateTime.now().toLocal();
      while (cantidadHabiles <= dias) {
        fechaCalculada = fechaCalculada.add(Duration(days: 1));
        if (fechaCalculada.weekday != DateTime.saturday && fechaCalculada.weekday != DateTime.sunday) {
          // verificamos que no sea fin de semana
          String dia = Utilidades.parseHoraFecha(fechaInicial: fechaCalculada.toString(), horaRequerida: false);
          List<dynamic> lista = feriados.where((element) => element.toString().compareTo(dia) == 0).toList();
          if (lista.length == 0) cantidadHabiles++; // verificamos que no sea feriado
        }
      }
      return fechaCalculada;
    }
    return new DateTime.now();
  }

  Future<void> obtieneFechaLimite() async {
    _fechaLimite = await Utilidades.readSecureStorage(key: 'fecha_vigencia');
    setState(() {});
  }
}
