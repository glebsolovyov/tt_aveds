import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';

abstract interface class AuthRepository {
  Future<void> login(String email);
  Future<Token> confirmCode({required String email, required String code});
  Future<String> getUserId();
  Stream<AuthenticationStatus> get authStatus;
}
