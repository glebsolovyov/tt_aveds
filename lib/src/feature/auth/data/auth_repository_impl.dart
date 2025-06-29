import 'dart:async';
import 'dart:developer';

import 'package:tt_aveds/src/core/interceptor/token_storage.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_data_source.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_repository.dart';
import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(AuthDataSource dataSource, TokenStorage tokenStorage)
      : _dataSource = dataSource,
        _tokenStorage = tokenStorage;

  final AuthDataSource _dataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<Token> confirmCode(
      {required String email, required String code}) async {
    final token = await _dataSource.confirmCode(email: email, code: code);
    _tokenStorage.save(token);
    log(token.accessToken);
    return token;
  }

  @override
  Future<void> login(String email) async {
    return _dataSource.login(email);
  }

  @override
  Stream<AuthenticationStatus> get authStatus => _tokenStorage.getStream().map(
        (token) => token != null
            ? AuthenticationStatus.authenticated
            : AuthenticationStatus.unauthenticated,
      );

  @override
  Future<String> getUserId() async {
    return await _dataSource.getUserId();
  }
}
