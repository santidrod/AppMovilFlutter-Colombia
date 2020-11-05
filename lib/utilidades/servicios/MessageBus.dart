
import 'package:ciudadaniadigital/models/PushNotification.dart';
import 'package:rxdart/rxdart.dart';

class ButtonMessageBus {
  BehaviorSubject<int> _buttonIdSubject = BehaviorSubject<int>.seeded(-1);

  Stream<int> get idStream => _buttonIdSubject.stream;

  void broadcastId(int id) {
    _buttonIdSubject.add(id);
  }

  void cancelBroadcast() {
    _buttonIdSubject.close();
  }
}

class PushMessageBus {
  BehaviorSubject<PushNotification> _pushSubject = BehaviorSubject<PushNotification>(); // .seeded(PushNotification());

  Stream<PushNotification> get pushStream => _pushSubject.stream;

  void broadcastPush(PushNotification pushNotification) {
    _pushSubject.add(pushNotification);
  }

  void cancelBroadcast() {
    _pushSubject.close();
  }
}

class PushTouchedMessageBus {
  BehaviorSubject<String> _pushTouchedSubject = BehaviorSubject<String>();

  Stream<String> get pushTouchedStream => _pushTouchedSubject.stream;

  void broadcastPushTouched(String payload) {
    _pushTouchedSubject.add(payload);
  }

  void cancelBroadcast() {
    _pushTouchedSubject.close();
  }
}