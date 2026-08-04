import 'dart:io';

abstract class EnvironmentProvider {
  Map<String, String?> get environment;
  static EnvironmentProvider _instance = DefaultEnvironmentProvider();
  static EnvironmentProvider get instance => _instance;
  static void setToDefault() => _instance = DefaultEnvironmentProvider();
}

class DefaultEnvironmentProvider implements EnvironmentProvider {
  @override
  Map<String, String?> get environment => Platform.environment;
}
