class PushNotification {
  final String id;
  final String titulo;
  final String mensaje;
  final dynamic payload;

  PushNotification({
    this.id,
    this.titulo,
    this.mensaje,
    this.payload,
  });

  factory PushNotification.fromJson(dynamic jsonObject) {
    return PushNotification(
      id: jsonObject['id'],
      titulo: jsonObject['titulo'] ?? 'Nueva notificación',
      mensaje: jsonObject['mensaje'] ?? '',
      payload: jsonObject['payload'] ?? null,
    );
  }
}
