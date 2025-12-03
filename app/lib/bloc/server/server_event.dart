part of 'server_bloc.dart';

abstract class ServerEvent {
  const ServerEvent();
}

class ServerStarted extends ServerEvent {
  const ServerStarted({this.port});

  final int? port;
}

class _ServerMessageReceived extends ServerEvent {
  const _ServerMessageReceived(this.message);

  final IncomingPayload message;
}
