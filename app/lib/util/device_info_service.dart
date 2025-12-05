import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  DeviceInfoService._internal();

  static final DeviceInfoService _instance = DeviceInfoService._internal();
  static DeviceInfoService get instance => _instance;

  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  BaseDeviceInfo? _deviceInfo;

  Future<void> init() async {
    _deviceInfo ??= await _plugin.deviceInfo;
  }

  BaseDeviceInfo get deviceInfo {
    final info = _deviceInfo;
    if (info == null) {
      throw StateError('DeviceInfoService not initialized');
    }
    return info;
  }

  Map<String, dynamic> get data => deviceInfo.data;

  String? get deviceName {
    final info = deviceInfo;
    if (info is WindowsDeviceInfo) {
      return info.computerName;
    }
    if (info is LinuxDeviceInfo) {
      return info.name;
    }
    if (info is MacOsDeviceInfo) {
      return info.computerName;
    }
    if (info is AndroidDeviceInfo) {
      return info.device;
    }
    if (info is IosDeviceInfo) {
      return info.name;
    }
    if (info is WebBrowserInfo) {
      return info.userAgent;
    }
    return info.data['name'] as String?;
  }
}
