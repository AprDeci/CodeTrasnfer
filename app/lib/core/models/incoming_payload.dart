class IncomingPayload {
  final String sourceIp;
  final String? deviceName;
  final Map<String, dynamic> data;
  final DateTime receivedAt;

  const IncomingPayload({
    required this.sourceIp,
    this.deviceName,
    required this.data,
    required this.receivedAt,
  });

  String get preview {
    final candidates = [
      data['title'],
      data['body'],
      data['message'],
      data.toString(),
    ].whereType<String>();
    return candidates.isEmpty ? '' : candidates.first;
  }
}
