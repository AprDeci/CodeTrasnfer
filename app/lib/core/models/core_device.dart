import 'package:code_transfer/rust/api/model.dart';

class CoreDevice {
  final String id;
  final String alias;
  final String ip;
  final int port;
  final DeviceType deviceType;
  final DateTime lastSeen;
  final bool isReachable;

  const CoreDevice({
    required this.id,
    required this.alias,
    required this.ip,
    required this.port,
    required this.deviceType,
    required this.lastSeen,
    this.isReachable = true,
  });

  CoreDevice copyWith({
    String? id,
    String? alias,
    String? ip,
    int? port,
    DeviceType? deviceType,
    DateTime? lastSeen,
    bool? isReachable,
  }) {
    return CoreDevice(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      deviceType: deviceType ?? this.deviceType,
      lastSeen: lastSeen ?? this.lastSeen,
      isReachable: isReachable ?? this.isReachable,
    );
  }

  @override
  String toString() {
    return 'CoreDevice(id: $id, alias: $alias, ip: $ip, port: $port, type: $deviceType)';
  }
}
