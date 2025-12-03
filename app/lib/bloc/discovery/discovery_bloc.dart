import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:code_transfer/core/core_repository.dart';
import 'package:code_transfer/core/models/core_device.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  DiscoveryBloc(
    this._repository, {
    this.autoPairName = 'MyPC',
  }) : super(const DiscoveryState()) {
    on<DiscoveryStarted>(_onStarted);
    on<_DiscoveryDevicesUpdated>(_onDevicesUpdated);
    on<DiscoveryTargetSelected>(_onTargetSelected);
    on<_DiscoveryTargetChanged>(_onTargetChanged);

    _targetSubscription = _repository.watchCurrentTargetIp().listen((ip) {
      add(_DiscoveryTargetChanged(ip));
    });
  }

  final CoreRepository _repository;
  final String? autoPairName;

  StreamSubscription<List<CoreDevice>>? _devicesSubscription;
  StreamSubscription<String?>? _targetSubscription;

  Future<void> _onStarted(
    DiscoveryStarted event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(state.copyWith(
      isScanning: true,
      errorMessage: null,
    ));
    try {
      await _repository.startDiscovery();
      _devicesSubscription ??=
          _repository.watchDevices().listen(_onDevicesStream);
    } catch (error) {
      emit(state.copyWith(
        isScanning: false,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onDevicesStream(List<CoreDevice> devices) {
    add(_DiscoveryDevicesUpdated(devices));
  }

  void _onDevicesUpdated(
    _DiscoveryDevicesUpdated event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(
      devices: event.devices,
      isScanning: false,
    ));
    _autoSelectIfNeeded(event.devices);
  }

  void _autoSelectIfNeeded(List<CoreDevice> devices) {
    if (autoPairName == null || autoPairName!.isEmpty) {
      return;
    }
    if (_repository.currentTargetIp != null) {
      return;
    }
    final candidate = devices.where(
      (device) => device.alias.toLowerCase() == autoPairName!.toLowerCase(),
    );
    if (candidate.isEmpty) {
      return;
    }
    _repository.setCurrentTargetDevice(candidate.first);
    emit(state.copyWith(autoMatched: true));
  }

  void _onTargetSelected(
    DiscoveryTargetSelected event,
    Emitter<DiscoveryState> emit,
  ) {
    _repository.setCurrentTargetDevice(event.device);
    emit(state.copyWith(
      currentTargetIp: event.device.ip,
      autoMatched: false,
    ));
  }

  void _onTargetChanged(
    _DiscoveryTargetChanged event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(currentTargetIp: event.targetIp));
  }

  @override
  Future<void> close() async {
    await _devicesSubscription?.cancel();
    await _targetSubscription?.cancel();
    return super.close();
  }
}
