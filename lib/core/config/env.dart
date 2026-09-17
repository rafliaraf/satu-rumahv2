enum AppEnv { dev, staging, prod }

class Env {
  static const AppEnv current = AppEnv.dev;

  static String get baseUrl {
    switch (current) {
      case AppEnv.dev:
        return 'https://dev-saturumah.tasikmalayakota.go.id/api';
      case AppEnv.staging:
        return 'https://staging-saturumah.tasikmalayakota.go.id/api';
      case AppEnv.prod:
        return 'https://saturumah.tasikmalayakota.go.id/api';
    }
  }
}
