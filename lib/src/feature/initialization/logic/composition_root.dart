import 'package:http/http.dart';
import 'package:intercepted_client/intercepted_client.dart';
import 'package:logging/logging.dart' hide Logger;
import 'package:clock/clock.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt_aveds/src/core/constant/application_config.dart';
import 'package:tt_aveds/src/core/interceptor/token_storage.dart';
import 'package:tt_aveds/src/core/utils/logger/logger.dart';
import 'package:tt_aveds/src/feature/auth/bloc/auth_bloc.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_data_source_impl.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_repository_impl.dart';
import 'package:tt_aveds/src/feature/auth/data/token_storage_sp.dart';
import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';
import 'package:tt_aveds/src/feature/auth/logic/authorization_client.dart';
import 'package:tt_aveds/src/feature/initialization/model/dependencies_container.dart';

/// {@template composition_root}
/// A place where top-level dependencies are initialized.
/// {@endtemplate}
///
/// {@template composition_process}
/// Composition of dependencies is a process of creating and configuring
/// instances of classes that are required for the application to work.
/// {@endtemplate}
final class CompositionRoot {
  /// {@macro composition_root}
  const CompositionRoot({
    required this.config,
    required this.logger,
  });

  /// Application configuration
  final ApplicationConfig config;

  /// Logger used to log information during composition process.
  final Logger logger;

  /// Composes dependencies and returns result of composition.
  Future<CompositionResult> compose() async {
    final stopwatch = clock.stopwatch()..start();

    logger.info('Initializing dependencies...');
    // initialize dependencies
    final dependencies = await DependenciesFactory(
      config: config,
      logger: logger,
    ).create();
    stopwatch.stop();
    logger.info(
        'Dependencies initialized successfully in ${stopwatch.elapsedMilliseconds} ms.');
    final result = CompositionResult(
      dependencies: dependencies,
      millisecondsSpent: stopwatch.elapsedMilliseconds,
    );

    return result;
  }
}

/// {@template composition_result}
/// Result of composition
///
/// {@macro composition_process}
/// {@endtemplate}
final class CompositionResult {
  /// {@macro composition_result}
  const CompositionResult({
    required this.dependencies,
    required this.millisecondsSpent,
  });

  /// The dependencies container
  final DependenciesContainer dependencies;

  /// The number of milliseconds spent
  final int millisecondsSpent;

  @override
  String toString() => '$CompositionResult('
      'dependencies: $dependencies, '
      'millisecondsSpent: $millisecondsSpent'
      ')';
}

/// Value with time.
typedef ValueWithTime<T> = ({T value, Duration timeSpent});

/// {@template factory}
/// Factory that creates an instance of [T].
/// {@endtemplate}
abstract class Factory<T> {
  /// {@macro factory}
  const Factory();

  /// Creates an instance of [T].
  T create();
}

/// {@template async_factory}
/// Factory that creates an instance of [T] asynchronously.
/// {@endtemplate}
abstract class AsyncFactory<T> {
  /// {@macro async_factory}
  const AsyncFactory();

  /// Creates an instance of [T].
  Future<T> create();
}

/// {@template dependencies_factory}
/// Factory that creates an instance of [DependenciesContainer].
/// {@endtemplate}
class DependenciesFactory extends AsyncFactory<DependenciesContainer> {
  /// {@macro dependencies_factory}
  const DependenciesFactory({
    required this.config,
    required this.logger,
  });

  /// Application configuration
  final ApplicationConfig config;

  /// Logger used to log information during composition process.
  final Logger logger;

  @override
  Future<DependenciesContainer> create() async {
    final client = Client();
    final sharedPreferences = SharedPreferencesAsync();
    final storage = TokenStorageSP(sharedPreferences: sharedPreferences);
    final token = await storage.load();

    final authInterceptor = AuthInterceptor(
      tokenStorage: storage,
      authorizationClient: JWTAuthorizationClient(client),
      retryClient: client,
      token: token,
    );

    final interceptedClient = InterceptedClient(
      inner: client,
      interceptors: [authInterceptor],
    );

    final packageInfo = await PackageInfo.fromPlatform();
    final authBloc =
        await AuthBlocFactory(interceptedClient, storage, token).create();

    return DependenciesContainer(
      logger: logger,
      config: config,
      packageInfo: packageInfo,
      authBloc: authBloc,
    );
  }
}

/// {@template app_logger_factory}
/// Factory that creates an instance of [AppLogger].
/// {@endtemplate}
class AppLoggerFactory extends Factory<AppLogger> {
  /// {@macro app_logger_factory}
  const AppLoggerFactory({this.observers = const []});

  /// List of observers that will be notified when a log message is received.
  final List<LogObserver> observers;

  @override
  AppLogger create() => AppLogger(observers: observers);
}

/// {@template auth_bloc_factory}
/// Factory that creates an instance of [AuthBloc].
///
/// The [AuthBloc] should be initialized during the application startup
/// {@endtemplate}
class AuthBlocFactory extends AsyncFactory<AuthBloc> {
  /// {@macro auth_bloc_factory}
  const AuthBlocFactory(this.client, this.storage, this.token);

  /// Client instance
  final Client client;

  /// TokenStorage instance
  final TokenStorage<Token> storage;

  final Token? token;

  @override
  Future<AuthBloc> create() async {
    final status = token == null
        ? AuthenticationStatus.unauthenticated
        : AuthenticationStatus.authenticated;
    final authRepository =
        AuthRepositoryImpl(AuthDataSourceImpl(client), storage);

    return AuthBloc(AuthState.idle(status: status),
        authRepository: authRepository);
  }
}
