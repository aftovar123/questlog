# Questlog

Catálogo de videojuegos hecho en Flutter, pensado como proyecto de práctica —
la idea de fondo ("Letterboxd para videojuegos") es más grande; esta v1 se
recorta a demostrar Clean Architecture, manejo de estado con Cubit, consumo
real de API con Dio, y testing en tres capas.

## Arquitectura

```
lib/
  app/            # composición: router, inyección de dependencias, widget raíz
  core/           # Result/Failure, cliente Dio y widgets compartidos entre features
  features/
    games/
      domain/       # Game (entidad), GamesRepository (contrato), GetGames / GetGameDetail (casos de uso)
      data/         # GameModel, GamesRemoteDataSource (RAWG), GamesRepositoryImpl
      presentation/ # GamesCubit / GameDetailCubit + estados, páginas y widgets
    diary/
      domain/       # PlayStatus, DiaryEntry (entidad), DiaryRepository (contrato), casos de uso
      data/         # DiaryEntryModel, DiaryLocalDataSource (Hive), DiaryRepositoryImpl
      presentation/ # DiaryCubit + estado, DiarySection (chips de estado, estrellas, nota)
  l10n/           # app_en.arb / app_es.arb + código generado (gen-l10n)
```

Regla de dependencia: `domain` no importa Flutter ni Dio. `data` implementa
las interfaces que `domain` define. `presentation` solo conoce `domain`
(a través de los casos de uso) y a Flutter.

Los errores se modelan como valores: `Result<T>` sellado (`Ok` / `Err`), nunca
excepciones subiendo hasta la UI. El repositorio traduce `DioException` a un
`Failure` de dominio; `GamesCubit` expone estados `Initial/Loading/Empty/Loaded/Failed`.

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

## Funcionalidad

- Grid de juegos con búsqueda y filtro por género (chips: Action, RPG,
  Adventure, Shooter, Strategy, Indie, Puzzle), consumiendo `/games` de RAWG.
- Detalle de cada juego: la tarjeta ya trae nombre/imagen/rating/fecha vía
  navegación (para que el Hero transicione sin esperar red), y `GameDetailCubit`
  hace una segunda llamada real a `/games/{id}` que enriquece la pantalla con
  géneros, plataformas y una descripción expandible ("Leer más"). Si esa
  llamada falla, la pantalla se degrada con gracia a los datos que ya tenía.
- Imágenes con fade-in al cargar (`FadingNetworkImage`) en vez de aparecer de
  golpe, y placeholder consistente si la URL falla.
- Scroll infinito en el carrusel: al acercarse al final pide la siguiente
  página y la agrega a la lista (`GamesCubit.loadMore`), sabiendo si hay más
  por `GamesPage.hasMore` (calculado en el repositorio, no adivinado por la UI).
- Reentrada protegida: cada `loadGames`/`loadMore` lleva un número de secuencia
  interno en el Cubit — si el usuario busca o cambia de filtro varias veces
  seguidas, una respuesta vieja que llega tarde ya no puede pisar el estado de
  una más reciente. Es el patrón "restartable" hecho a mano, sin necesitar Bloc.
- Diario personal (v2): en el detalle de cada juego se puede marcar
  Backlog/Jugando/Completado, calificar de 1 a 5 estrellas y escribir una
  nota, persistido localmente con Hive (no `sqflite`, para que también
  funcione en Flutter Web vía IndexedDB). `DiaryCubit` espera su propia carga
  inicial (`_ready`) antes de aplicar cualquier actualización, para que una
  interacción muy rápida justo al abrir la pantalla no se pierda en silencio.

## Tests

```bash
flutter test
flutter analyze
```

44 tests en 4 capas: 6 de casos de uso de `games` (`GetGames`, `GetGameDetail`,
repositorio mockeado con mocktail), 10 de `GamesCubit`/`GameDetailCubit` (con
`bloc_test` y un test unitario directo, cubriendo éxito/vacío/error/degradación/
paginación/reentrada), 3 de parseo de `GameModel.fromJson`, 14 de `diary`
(casos de uso y `DiaryCubit` mockeados con mocktail/bloc_test, más el
repositorio contra una instancia real de Hive vía `hive_test` — ahí sí importa
probar la persistencia en sí, no un mock de ella), y 11 de widgets con
`testWidgets`: `GameCarousel` (renderizado, paginación al hacer scroll) y
`DiarySection` (estados de carga/guardado/error, y que tocar un chip, una
estrella o "Guardar nota" llama al método correcto de `DiaryCubit` con el
argumento correcto — mockeado con `MockCubit`/`whenListen` de `bloc_test`).

## Qué falta

- El filtro de género usa una lista curada de slugs en vez de traerlos desde
  `/genres` — evita un segundo endpoint solo para poblar una fila de chips.
- `hasMore` se calcula comparando el tamaño de la página contra `page_size`
  (RAWG no da un flag barato para esto) — si una página llega exactamente
  llena pero es la última, se hace una petición extra que vuelve vacía. Es una
  simplificación consciente, no un descuido.
