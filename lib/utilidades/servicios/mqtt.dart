
import 'dart:convert';

import 'package:ciudadaniadigital/models/PushNotification.dart';
import 'package:ciudadaniadigital/utilidades/Constantes.dart';
import 'package:ciudadaniadigital/utilidades/servicios/MessageBus.dart';
import 'package:ciudadaniadigital/utilidades/servicios/ServiceLocator.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:mqtt_client/mqtt_client.dart';

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}
enum MqttSubscriptionState {
  IDLE,
  SUBSCRIBED
}

class MqttWrapper {
  MqttClient client;
  // final Function(String) onMessageReceived;
  final Function onConnectedCallback;
  final String clientId;
  final String topic;

  PushMessageBus _pushMessageBus = locator<PushMessageBus>();

  MqttWrapper(
      this.clientId,
      this.topic,
      this.onConnectedCallback,
      // this.onMessageReceived
  );

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
    if (client.connectionStatus.state == MqttConnectionState.connected)
      _subscribeToTopic(topic);
  }

  void _setupMqttClient() {
    client = MqttClient.withPort(Constantes.urlMQTT, '#', Constantes.portMQTT);
    client.logging(on: false/*Constantes.ambiente != Ambiente.PROD*/);
    client.keepAlivePeriod = 30;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
    .authenticateAs(Constantes.usuarioMQTT, Constantes.passwordUsuarioMQTT)
    .withClientIdentifier(clientId)
    .withWillQos(MqttQos.exactlyOnce); // QoS 2
    client.connectionMessage = connMessage;
  }

  Future<void> _connectClient() async {
    try {
      Utilidades.imprimir('Cliente MQTT conectando....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect();
    } on Exception catch (e) {
      Utilidades.imprimir('exception cliente MQTT - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      Utilidades.imprimir('cliente MQTT conectado');
    } else {
      Utilidades.imprimir('ERROR conexion cliente  - desconectando, status es ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void disconnectMqttClient() {
    if (isMqttClientConnected()) {
      connectionState = MqttCurrentConnectionState.DISCONNECTED;
      client.disconnect();
    }
  }

  bool isMqttClientConnected() {
    if (client == null || client.connectionStatus == null) return false;
    return client.connectionStatus.state == MqttConnectionState.connected;
  }

  void _subscribeToTopic(String topicName) {
    Utilidades.imprimir('Cliente MQTT: Suscribiendo a topico: $topicName');
    String message;
    client.subscribe(topicName, MqttQos.atLeastOnce); // QoS 1
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      message =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      Utilidades.imprimir("Cliente MQTT: Llegó nuevo mensaje $message");
      // onMessageReceived(message);

      // broadcast
      _pushMessageBus.broadcastPush(PushNotification.fromJson(jsonDecode(message)));
    });
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    Utilidades.imprimir('Cliente MQTT: la conexión fue exitosa');
    onConnectedCallback();
  }

  void _onDisconnected() {
    Utilidades.imprimir('Cliente MQTT: cliente desconectado');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onSubscribed(String topic) {
    Utilidades.imprimir('Cliente MQTT: suscripcion confirmada para el tópico: $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }
}