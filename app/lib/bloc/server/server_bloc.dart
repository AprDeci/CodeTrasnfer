import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:code_transfer/core/core_repository.dart';
import 'package:code_transfer/core/models/incoming_payload.dart';

part 'server_event.dart';
part 'server_state.dart';

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  ServerBloc(
    this._repository, {
    this.defaultPort = 53317,
  }) : super(ServerState.initial(defaultPort)) {
    on<ServerStarted>(_onStarted);
    on<_ServerMessageReceived>(_onMessageReceived);
  }

  final CoreRepository _repository;
  final int defaultPort;

  StreamSubscription<IncomingPayload>? _messageSubscription;

  Future<void> _onStarted(
    ServerStarted event,
    Emitter<ServerState> emit,
  ) async {
    if (state.isRunning) {
      return;
    }
    final port = event.port ?? defaultPort;
    emit(state.copyWith(
      isRunning: true,
      port: port,
      errorMessage: null,
    ));
    try {
      await _repository.startServer(port: port);
      _messageSubscription ??=
          _repository.watchIncomingMessages().listen(_onMessageStream);
    } catch (error) {
      emit(state.copyWith(
        isRunning: false,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onMessageStream(IncomingPayload message) {
    add(_ServerMessageReceived(message));
  }

  void _onMessageReceived(
    _ServerMessageReceived event,
    Emitter<ServerState> emit,
  ) {
    final updated = <IncomingPayload>[event.message, ...state.messages];
    emit(state.copyWith(messages: updated.take(20).toList()));
  }

  @override
  Future<void> close() async {
    await _messageSubscription?.cancel();
    return super.close();
  }
}
