part of 'discovery_bloc.dart';

const _noChange = Object();

class DiscoveryState {
  const DiscoveryState({
    this.isScanning = false,
    this.devices = const [],
    this.currentTargetIp,
    this.autoMatched = false,
    this.errorMessage,
  });

  final bool isScanning;
  final List<CoreDevice> devices;
  final String? currentTargetIp;
  final bool autoMatched;
  final String? errorMessage;

  DiscoveryState copyWith({
    bool? isScanning,
    List<CoreDevice>? devices,
    String? currentTargetIp,
    bool? autoMatched,
    Object? errorMessage = _noChange,
  }) {
    return DiscoveryState(
      isScanning: isScanning ?? this.isScanning,
      devices: devices ?? this.devices,
      currentTargetIp: currentTargetIp ?? this.currentTargetIp,
      autoMatched: autoMatched ?? this.autoMatched,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
