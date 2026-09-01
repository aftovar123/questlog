# Questlog

Catálogo de videojuegos hecho en Flutter, pensado como proyecto de práctica —
la idea de fondo ("Letterboxd para videojuegos") es más grande; esta v1 se
recorta a demostrar Clean Architecture, manejo de estado con Cubit, consumo
real de API con Dio, y testing en tres capas.

## Arquitectura

```
lib/
  app/            # composición: router, inyección de dependencias, widget raíz
  core/           # Result/Failure y el cliente Dio, compartidos entre features
  features/
    games/
      domain/       # Game (entidad), GamesRepository (contrato), GetGames (caso de uso)
      data/         # GameModel, GamesRemoteDataSource (RAWG), GamesRepositoryImpl
      presentation/ # GamesCubit + estados, páginas y widgets
  l10n/           # app_en.arb / app_es.arb + código generado (gen-l10n)
```

Regla de dependencia: `domain` no importa Flutter ni Dio. `data` implementa
las interfaces que `domain` define. `presentation` solo conoce `domain`
(a través del caso de uso) y a Flutter.

Los errores se modelan como valores: `Result<T>` sellado (`Ok` / `Err`), nunca
excepciones subiendo hasta la UI. El repositorio traduce `DioException` a un
`Failure` de dominio; el Cubit expone estados `Initial/Loading/Empty/Loaded/Failed`.

## Requisitos

- Flutter 3.47.2 (la misma versión fijada en el proyecto real que motivó esto)
- Una API key gratuita de [RAWG](https://rawg.io/apidocs) (20k requests/mes)

## Cómo correrlo

```bash
flutter pub get
flutter run -d chrome --dart-define=RAWG_API_KEY=tu_api_key
```

Sin la key, la app corre igual mostrando el estado de error con botón de
reintentar — es intencional, demuestra el manejo de errores de red.

## Tests

```bash
flutter test
flutter analyze
```

7 tests: 2 de caso de uso (repositorio mockeado con mocktail), 3 de `GamesCubit`
(con `bloc_test`, cubriendo éxito/vacío/error), 2 de parseo de `GameModel.fromJson`.

## Nota conocida: portadas en gris al correr en Chrome/web

`Image.network` muestra un placeholder gris para las portadas cuando se corre
con `flutter run -d chrome` o `-d web-server`. La API sí devuelve las URLs
correctamente — es que el renderer web de Flutter (CanvasKit) decodifica las
imágenes vía `fetch()` y necesita que el servidor envíe cabeceras CORS; el CDN
de RAWG (`media.rawg.io`) no las envía. Es una limitación conocida de
Flutter Web con imágenes de terceros sin CORS, no un bug de esta app — en
Android/iOS (la plataforma real objetivo) la carga nativa de imágenes no
depende de CORS y esto no ocurre.

## Qué falta (v2, fuera de alcance de esta v1)

- Pantalla de detalle trae los datos ya cargados vía navegación (`extra`), no
  hace una segunda llamada a `/games/{id}` — sería la extensión natural.
- El "diario" personal (marcar jugado/backlog, calificar, reseñar) con
  persistencia local es la parte que lo hace un Letterboxd de verdad; se dejó
  fuera a propósito para no bloquear tener algo funcional y testeado primero.
- Paginación infinita en el grid (por ahora solo pide la primera página).
