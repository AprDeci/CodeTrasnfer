import 'package:code_transfer/core/models/core_device.dart';
import 'package:hive_ce/hive.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  static HiveService get instance => _instance;

  static const String stateBoxKey = 'statebox';
  static const String devicesBoxKey = 'devicesbox';
  static const String settingsBoxKey = 'settingsbox';

  late Box _stateBoxInstance;
  late Box _devicesBoxInstance;
  late Box _settingsBoxInstance;

  bool _isInitialized = false;

  HiveService._internal();

  Future<void> init() async {
    if (!_isInitialized) {
      _stateBoxInstance = await Hive.openBox(stateBoxKey);
      _devicesBoxInstance = await Hive.openBox(devicesBoxKey);
      _settingsBoxInstance = await Hive.openBox(settingsBoxKey);
      _isInitialized = true;
    }
  }

  Future<void> saveState(String key, dynamic value) async {
    if (!_isInitialized) await init();
    await _stateBoxInstance.put(key, value);
  }

  Future<void> saveDevice(CoreDevice device) async {
    if (!_isInitialized) await init();
    await _devicesBoxInstance.put(device.id, device);
  }

  Box get stateBox => _stateBoxInstance;

  Box get devicesBox => _devicesBoxInstance;

  Box get settingsBox => _settingsBoxInstance;
}