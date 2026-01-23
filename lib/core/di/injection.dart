import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

/// Global service locator instance.
///
/// Access injectable services throughout the application via:
/// ```dart
/// final logger = getIt<AppLogger>();
/// final config = getIt<EnvConfig>();
/// ```
final GetIt getIt = GetIt.instance;

/// Configures dependency injection for the application.
///
/// This function initializes the get_it service locator with all
/// injectable classes marked with @injectable, @singleton, or @lazySingleton.
///
/// Must be called in main() before runApp():
/// ```dart
/// await configureDependencies();
/// ```
///
/// The actual registration happens in the generated injection.config.dart file
/// created by running: flutter pub run build_runner build
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
}