

import 'package:ciudadaniadigital/utilidades/servicios/MessageBus.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  Utilidades.imprimir('++++++++Registrando buses de comunicación');
  locator.registerSingleton<ButtonMessageBus>(ButtonMessageBus(), signalsReady: true);
  locator.registerSingleton<PushMessageBus>(PushMessageBus(), signalsReady: true);
  locator.registerSingleton<PushTouchedMessageBus>(PushTouchedMessageBus(), signalsReady: true);
}

void unregisterLocator() {
  Utilidades.imprimir('++++++++borrando buses de comunicación');
  locator.unregister<ButtonMessageBus>();
  locator.unregister<PushMessageBus>();
  locator.unregister<PushTouchedMessageBus>();
  locator.reset();
}