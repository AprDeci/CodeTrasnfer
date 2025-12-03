part of 'sync_bloc.dart';

enum SyncStatus { idle, sending, success, failure }

const _syncNoChange = Object();

class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.currentTargetIp,
    this.errorMessage,
    this.sentCount = 0,
  });

  final SyncStatus status;
  final String? currentTargetIp;
  final String? errorMessage;
  final int sentCount;

  bool get hasTarget => currentTargetIp != null;

  SyncState copyWith({
    SyncStatus? status,
    String? currentTargetIp,
    int? sentCount,
    Object? errorMessage = _syncNoChange,
  }) {
    return SyncState(
      status: status ?? this.status,
      currentTargetIp: currentTargetIp ?? this.currentTargetIp,
      sentCount: sentCount ?? this.sentCount,
      errorMessage: identical(errorMessage, _syncNoChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
