import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt_aveds/src/core/interceptor/token_storage.dart';
import 'package:tt_aveds/src/core/utils/persisted_entry.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_data_source.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockAuthDataSource extends Mock implements AuthDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

class MockStringPreferencesEntry extends Mock
    implements StringPreferencesEntry {}
