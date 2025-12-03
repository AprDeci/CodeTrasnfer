part of 'discovery_bloc.dart';

abstract class DiscoveryEvent {
  const DiscoveryEvent();
}

class DiscoveryStarted extends DiscoveryEvent {
  const DiscoveryStarted();
}

class DiscoveryTargetSelected extends DiscoveryEvent {
  const DiscoveryTargetSelected(this.device);

  final CoreDevice device;
}

class _DiscoveryDevicesUpdated extends DiscoveryEvent {
  const _DiscoveryDevicesUpdated(this.devices);

  final List<CoreDevice> devices;
}

class _DiscoveryTargetChanged extends DiscoveryEvent {
  const _DiscoveryTargetChanged(this.targetIp);

  final String? targetIp;
}
