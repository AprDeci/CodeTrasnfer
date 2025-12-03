part of 'server_bloc.dart';

const _serverNoChange = Object();

class ServerState {
  const ServerState({
    required this.port,
    this.isRunning = false,
    this.messages = const [],
    this.errorMessage,
  });

  factory ServerState.initial(int port) => ServerState(port: port);

  final int port;
  final bool isRunning;
  final List<IncomingPayload> messages;
  final String? errorMessage;

  ServerState copyWith({
    int? port,
    bool? isRunning,
    List<IncomingPayload>? messages,
    Object? errorMessage = _serverNoChange,
  }) {
    return ServerState(
      port: port ?? this.port,
      isRunning: isRunning ?? this.isRunning,
      messages: messages ?? this.messages,
      errorMessage: identical(errorMessage, _serverNoChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
