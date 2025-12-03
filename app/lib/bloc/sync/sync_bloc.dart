import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:code_transfer/core/core_repository.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc(this._repository) : super(const SyncState()) {
    on<SyncSendTestRequested>(_onSendTestRequested);
    on<SyncNotificationReceived>(_onNotificationReceived);
    on<_SyncTargetChanged>(_onTargetChanged);

    _targetSubscription = _repository.watchCurrentTargetIp().listen((ip) {
      add(_SyncTargetChanged(ip));
    });
  }

  final CoreRepository _repository;
  StreamSubscription<String?>? _targetSubscription;

  Future<void> _onSendTestRequested(
    SyncSendTestRequested event,
    Emitter<SyncState> emit,
  ) async {
    final payload = {
      'type': 'test',
      'message': event.message ?? '同步测试',
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _sendToTarget(payload, emit);
  }

  Future<void> _onNotificationReceived(
    SyncNotificationReceived event,
    Emitter<SyncState> emit,
  ) async {
    await _sendToTarget(event.payload, emit);
  }

  void _onTargetChanged(
    _SyncTargetChanged event,
    Emitter<SyncState> emit,
  ) {
    emit(state.copyWith(currentTargetIp: event.targetIp));
  }

  Future<void> _sendToTarget(
    Map<String, dynamic> payload,
    Emitter<SyncState> emit,
  ) async {
    final targetIp = _repository.currentTargetIp;
    if (targetIp == null) {
      emit(state.copyWith(
        status: SyncStatus.failure,
        errorMessage: '尚未匹配到目标设备',
      ));
      return;
    }
    emit(state.copyWith(
      status: SyncStatus.sending,
      errorMessage: null,
    ));
    try {
      await _repository.sendPayload(payload: payload);
      emit(state.copyWith(
        status: SyncStatus.success,
        sentCount: state.sentCount + 1,
      ));
      emit(state.copyWith(status: SyncStatus.idle));
    } catch (error) {
      emit(state.copyWith(
        status: SyncStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _targetSubscription?.cancel();
    return super.close();
  }
}
