import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:code_transfer/core/models/core_device.dart';
import 'package:code_transfer/core/models/device_type.dart';
import 'package:code_transfer/core/models/incoming_payload.dart';
import 'package:code_transfer/util/hive_service.dart';
import 'package:logger/logger.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';

abstract class CoreBridge {
  Stream<CoreDevice> get discoveryStream;

  Stream<IncomingPayload> get incomingMessages;

  Future<void> startServer({required int port});

  Future<void> startDiscovery();

  Future<void> sendPayload({
    required String targetIp,
    required int targetPort,
    required Map<String, dynamic> payload,
  });

  Future<void> dispose();
}

class LanCoreBridge implements CoreBridge {
  LanCoreBridge({
    Logger? logger,
    InternetAddress? broadcastAddress,
    this.discoveryPort = 53318,
    this.discoveryInterval = const Duration(seconds: 3),
    this.serverFallbackPort = 53317,
  }) : _logger = logger ?? Logger(),
       _broadcastAddress =
           broadcastAddress ?? InternetAddress('255.255.255.255'),
       _listeningPort = serverFallbackPort;

  final Logger _logger;
  final InternetAddress _broadcastAddress;
  final int discoveryPort;
  final Duration discoveryInterval;
  final int serverFallbackPort;

  final _discoveryController = StreamController<CoreDevice>.broadcast();
  final _incomingController = StreamController<IncomingPayload>.broadcast();

  HttpServer? _httpServer;
  RawDatagramSocket? _udpSocket;
  Timer? _announceTimer;
  int _listeningPort;

  late String _deviceId;
  final String _alias = _resolveAlias();

  // 配合hive 持久化存储_deviceId
  _generateSelfInfo() async {
    final deviceId = await HiveService.instance.stateBox.get('deviceId');
    if (deviceId != null) {
      _deviceId = deviceId;
    } else {
      _deviceId = const Uuid().v4();
      await HiveService.instance.stateBox.put('deviceId', _deviceId);
    }
    _logger.i('Device ID: $_deviceId');
  }

  @override
  Stream<CoreDevice> get discoveryStream => _discoveryController.stream;

  @override
  Stream<IncomingPayload> get incomingMessages => _incomingController.stream;

  @override
  Future<void> startServer({required int port}) async {
    if (_httpServer != null && _listeningPort == port) {
      return;
    }
    await _generateSelfInfo();
    final server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    _listeningPort = port;
    _httpServer = server;
    _logger.i('LAN server listening on port $port');
    unawaited(_handleHttpRequests(server));
    _sendAnnounce();
  }

  Future<void> _handleHttpRequests(HttpServer server) async {
    await for (final request in server) {
      try {
        if (request.method != 'POST') {
          request.response.statusCode = HttpStatus.methodNotAllowed;
          await request.response.close();
          continue;
        }

        final content = await utf8.decoder.bind(request).join();
        final payload = content.isNotEmpty
            ? jsonDecode(content) as Map<String, dynamic>
            : <String, dynamic>{};

        final sourceIp =
            request.connectionInfo?.remoteAddress.address ?? 'unknown';
        final deviceName = payload['deviceName'] as String?;

        _incomingController.add(
          IncomingPayload(
            sourceIp: sourceIp,
            deviceName: deviceName,
            data: payload,
            receivedAt: DateTime.now(),
          ),
        );

        request.response.statusCode = HttpStatus.noContent;
        await request.response.close();
      } catch (error, stackTrace) {
        _logger.e(
          'Failed to process incoming message',
          error: error,
          stackTrace: stackTrace,
        );
        try {
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> startDiscovery() async {
    if (_udpSocket != null) {
      return;
    }
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
      reuseAddress: true,
    );
    socket.broadcastEnabled = true;
    _udpSocket = socket;
    _logger.i('Discovery socket bound on $discoveryPort');
    socket.listen(_handleUdpEvent);
    _announceTimer = Timer.periodic(discoveryInterval, (_) => _sendAnnounce());
    _sendAnnounce();
  }

  void _handleUdpEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) {
      return;
    }
    final socket = _udpSocket;
    if (socket == null) {
      return;
    }
    final datagram = socket.receive();
    if (datagram == null) {
      return;
    }
    try {
      final message = utf8.decode(datagram.data);
      final decoded = jsonDecode(message) as Map<String, dynamic>;
      if (decoded['kind'] != _DiscoveryPacket.kind) {
        return;
      }
      if (decoded['deviceId'] == _deviceId) {
        return;
      }
      final port = (decoded['port'] as num?)?.toInt() ?? serverFallbackPort;
      final alias = decoded['alias'] as String? ?? 'Unknown';
      final deviceType = _parseDeviceType(decoded['deviceType'] as String?);
      final id =
          decoded['deviceId'] as String? ?? '${datagram.address.address}:$port';
      final device = CoreDevice(
        id: id,
        alias: alias,
        ip: datagram.address.address,
        port: port,
        deviceType: deviceType,
        lastSeen: DateTime.now(),
        isReachable: true,
      );
      _discoveryController.add(device);
      final isResponse = decoded['isResponse'] == true;
      if (!isResponse) {
        _sendAnnounce(target: datagram.address, isResponse: true);
      }
    } catch (error, stackTrace) {
      _logger.w(
        'Failed to parse discovery packet',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _sendAnnounce({InternetAddress? target, bool isResponse = false}) {
    final socket = _udpSocket;
    if (socket == null) {
      return;
    }
    final port = _listeningPort;
    final packet = _DiscoveryPacket(
      deviceId: _deviceId,
      alias: _alias,
      port: port,
      deviceType: _deviceTypeString(),
      isResponse: isResponse,
    );
    final data = utf8.encode(jsonEncode(packet.toJson()));
    final destination = target ?? _broadcastAddress;
    socket.send(data, destination, discoveryPort);
  }

  @override
  Future<void> sendPayload({
    required String targetIp,
    required int targetPort,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri(
      scheme: 'http',
      host: targetIp,
      port: targetPort,
      path: '/sync',
    );
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      final enrichedPayload = {
        'deviceName': _alias,
        'sentAt': DateTime.now().toIso8601String(),
        ...payload,
      };
      request.write(jsonEncode(enrichedPayload));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw HttpException('发送失败：${response.statusCode}', uri: uri);
      }
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<void> dispose() async {
    await _httpServer?.close(force: true);
    _httpServer = null;
    _udpSocket?.close();
    _udpSocket = null;
    _announceTimer?.cancel();
    _announceTimer = null;
    await _discoveryController.close();
    await _incomingController.close();
  }

  static String _resolveAlias() {
    final hostname = Platform.isAndroid ? null : Platform.localHostname;
    if (hostname != null && hostname.isNotEmpty) {
      return hostname;
    }
    return 'Device-${Platform.operatingSystem}';
  }

  String _deviceTypeString() {
    if (UniversalPlatform.isWeb) {
      return DeviceType.web.name;
    }
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      return DeviceType.mobile.name;
    }
    if (UniversalPlatform.isWindows ||
        UniversalPlatform.isLinux ||
        UniversalPlatform.isMacOS) {
      return DeviceType.desktop.name;
    }
    return DeviceType.headless.name;
  }

  DeviceType _parseDeviceType(String? type) {
    switch (type) {
      case 'desktop':
        return DeviceType.desktop;
      case 'mobile':
        return DeviceType.mobile;
      case 'web':
        return DeviceType.web;
      case 'server':
        return DeviceType.server;
      default:
        return DeviceType.headless;
    }
  }
}

class _DiscoveryPacket {
  const _DiscoveryPacket({
    required this.deviceId,
    required this.alias,
    required this.port,
    required this.deviceType,
    this.isResponse = false,
  });

  final String deviceId;
  final String alias;
  final int port;
  final String deviceType;
  final bool isResponse;

  static const kind = 'code_transfer_discovery';

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'deviceId': deviceId,
    'alias': alias,
    'port': port,
    'deviceType': deviceType,
    'isResponse': isResponse,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

class MockCoreBridge implements CoreBridge {
  MockCoreBridge({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;
  final _discoveryController = StreamController<CoreDevice>.broadcast();
  final _incomingController = StreamController<IncomingPayload>.broadcast();

  Timer? _discoveryTimer;
  int _sampleIndex = 0;

  static const _sampleDevices = [
    ('device-pc', 'MyPC', '192.168.0.12', 53317, DeviceType.desktop),
    ('device-laptop', 'Work-Laptop', '192.168.0.42', 53317, DeviceType.desktop),
    ('device-phone', 'Pixel-Phone', '192.168.0.33', 53317, DeviceType.mobile),
  ];

  @override
  Stream<CoreDevice> get discoveryStream => _discoveryController.stream;

  @override
  Stream<IncomingPayload> get incomingMessages => _incomingController.stream;

  @override
  Future<void> startServer({required int port}) async {
    _logger.i('Mock server listening on port $port');
  }

  @override
  Future<void> startDiscovery() async {
    _discoveryTimer ??= Timer.periodic(const Duration(seconds: 4), (timer) {
      final sample = _sampleDevices[_sampleIndex % _sampleDevices.length];
      _sampleIndex++;
      final device = CoreDevice(
        id: sample.$1,
        alias: sample.$2,
        ip: sample.$3,
        port: sample.$4,
        deviceType: sample.$5,
        lastSeen: DateTime.now(),
      );
      _discoveryController.add(device);
    });
  }

  @override
  Future<void> sendPayload({
    required String targetIp,
    required int targetPort,
    required Map<String, dynamic> payload,
  }) async {
    _logger.i('Mock send -> $targetIp payload: $payload');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _incomingController.add(
      IncomingPayload(
        sourceIp: targetIp,
        deviceName: 'Echo-$targetIp',
        data: {'type': 'echo', 'payload': payload},
        receivedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    await _discoveryController.close();
    await _incomingController.close();
  }
}
