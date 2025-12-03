part of 'sync_bloc.dart';

abstract class SyncEvent {
  const SyncEvent();
}

class SyncSendTestRequested extends SyncEvent {
  const SyncSendTestRequested({this.message});

  final String? message;
}

class SyncNotificationReceived extends SyncEvent {
  const SyncNotificationReceived({required this.payload});

  final Map<String, dynamic> payload;
}

class _SyncTargetChanged extends SyncEvent {
  const _SyncTargetChanged(this.targetIp);

  final String? targetIp;
}
