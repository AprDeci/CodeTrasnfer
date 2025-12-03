import 'dart:async';

import 'package:code_transfer/core/core_bridge.dart';
import 'package:code_transfer/core/models/core_device.dart';
import 'package:code_transfer/core/models/incoming_payload.dart';
import 'package:logger/logger.dart';

class CoreRepository {
  CoreRepository({
    CoreBridge? bridge,
    Logger? logger,
  })  : _bridge = bridge ?? LanCoreBridge(logger: logger),
        _logger = logger ?? Logger();

  final CoreBridge _bridge;
  final Logger _logger;

  final _deviceCache = <String, CoreDevice>{};
  final _devicesController = StreamController<List<CoreDevice>>.broadcast();
  final _targetIpController = StreamController<String?>.broadcast();

  StreamSubscription<CoreDevice>? _discoverySubscription;
  CoreDevice? _currentTargetDevice;

  Stream<List<CoreDevice>> watchDevices() => _devicesController.stream;

  Stream<IncomingPayload> watchIncomingMessages() => _bridge.incomingMessages;

  Stream<String?> watchCurrentTargetIp() => _targetIpController.stream;

  String? get currentTargetIp => _currentTargetDevice?.ip;
  CoreDevice? get currentTargetDevice => _currentTargetDevice;

  Future<void> startServer({required int port}) async {
    await _bridge.startServer(port: port);
  }

  Future<void> startDiscovery() async {
    _discoverySubscription ??=
        _bridge.discoveryStream.listen(_handleDiscoveredDevice);
    await _bridge.startDiscovery();
  }

  void _handleDiscoveredDevice(CoreDevice device) {
    _deviceCache[device.id] = device;
    final list = _deviceCache.values.toList()
      ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    _devicesController.add(list);
  }

  void setCurrentTargetDevice(CoreDevice? device) {
    if (_currentTargetDevice?.id == device?.id) {
      return;
    }
    _currentTargetDevice = device;
    final ip = device?.ip;
    _logger.i('Target device changed -> $ip');
    _targetIpController.add(ip);
  }

  Future<void> sendPayload({
    required Map<String, dynamic> payload,
  }) {
    final device = _currentTargetDevice;
    if (device == null) {
      throw StateError('No target device selected');
    }
    return _bridge.sendPayload(
      targetIp: device.ip,
      targetPort: device.port,
      payload: payload,
    );
  }

  Future<void> dispose() async {
    await _discoverySubscription?.cancel();
    await _bridge.dispose();
    await _devicesController.close();
    await _targetIpController.close();
  }
}
