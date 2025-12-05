import 'package:code_transfer/core/models/core_device.dart';
import 'package:hive_ce/hive.dart';

class HiveService {
  static final stateBoxKey = 'statebox';
  static final devicesBoxKey = 'devicesbox';

  static final HiveService instance = HiveService._();

  HiveService._();

  Future<Box> get _stateBox async => await Hive.openBox(stateBoxKey);

  Future<Box> get _devicesBox async => await Hive.openBox(devicesBoxKey);

  Future<void> saveState(String key, value) async {
    final box = await _stateBox;
    await box.put(key, value);
  }

  Future<void> saveDevice(CoreDevice device) async {
    final box = await _devicesBox;
    await box.put(device.id, device);
  }
}
