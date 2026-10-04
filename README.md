# ArquiTech Mobile

Aplicación Flutter para la gestión móvil de obras de ArquiTech.

## Requisitos

- Flutter compatible con Dart `^3.13.5`
- Android Studio/Xcode según la plataforma objetivo

## Ejecución

Producción es la configuración predeterminada:

```bash
flutter pub get
flutter run
```

Backend local desde Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

La base URL se define únicamente en `lib/core/config/app_config.dart`.

## Calidad

```bash
dart format .
flutter analyze
flutter test
```

## Arquitectura y handoff

La aplicación usa Feature First con separación Data / Domain / Presentation, Riverpod, Dio, go_router, secure storage e internacionalización ES/EN.

La documentación completa de la Parte 1 y las instrucciones de continuidad están en [docs/mobile-part1-handoff.md](docs/mobile-part1-handoff.md).
