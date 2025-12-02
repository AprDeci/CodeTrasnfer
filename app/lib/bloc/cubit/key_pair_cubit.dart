import 'package:bloc/bloc.dart';
import 'package:code_transfer/rust/api/crypto.dart';

enum KeyPairStatus { initial, loading, success, failure }

class KeyPairState {
  final KeyPairStatus status;
  final KeyPair? keyPair;
  final String? errorMessage;

  const KeyPairState({
    this.status = KeyPairStatus.initial,
    this.keyPair,
    this.errorMessage,
  });
}

class KeyPairCubit extends Cubit<KeyPairState> {
  KeyPairCubit() : super(const KeyPairState());

  Future<void> generate() async {
    emit(const KeyPairState(status: KeyPairStatus.loading));
    try {
      final pair = await generateKeyPair();
      emit(KeyPairState(
        status: KeyPairStatus.success,
        keyPair: pair,
      ));
    } catch (e) {
      emit(KeyPairState(
        status: KeyPairStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
