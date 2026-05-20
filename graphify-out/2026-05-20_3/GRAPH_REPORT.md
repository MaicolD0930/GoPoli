# Graph Report - GoPoli  (2026-05-20)

## Corpus Check
- 107 files · ~56,835 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1261 nodes · 1325 edges · 104 communities (81 shown, 23 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 62 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c6dd6438`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 77|Community 77]]
- [[_COMMUNITY_Community 78|Community 78]]
- [[_COMMUNITY_Community 79|Community 79]]
- [[_COMMUNITY_Community 80|Community 80]]
- [[_COMMUNITY_Community 82|Community 82]]
- [[_COMMUNITY_Community 84|Community 84]]
- [[_COMMUNITY_Community 85|Community 85]]
- [[_COMMUNITY_Community 86|Community 86]]
- [[_COMMUNITY_Community 87|Community 87]]
- [[_COMMUNITY_Community 88|Community 88]]
- [[_COMMUNITY_Community 89|Community 89]]
- [[_COMMUNITY_Community 103|Community 103]]

## God Nodes (most connected - your core abstractions)
1. `DefaultCohort` - 153 edges
2. `price_regex` - 63 edges
3. `domain_page_locales` - 52 edges
4. `market_domain_regex_map` - 52 edges
5. `autofill_class_map` - 50 edges
6. `autofill_field_confidence_bar` - 50 edges
7. `default_locale_map` - 40 edges
8. `aee_config` - 33 edges
9. `currency_symbol_regex_map` - 31 edges
10. `Servicio` - 22 edges

## Surprising Connections (you probably didn't know these)
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  frontend/linux/runner/my_application.cc → frontend/linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  frontend/linux/runner/main.cc → frontend/linux/runner/my_application.cc
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  frontend/windows/runner/flutter_window.cpp → frontend/windows/runner/win32_window.cpp
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  frontend/windows/runner/flutter_window.cpp → frontend/windows/runner/win32_window.cpp
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  frontend/windows/runner/main.cpp → frontend/windows/runner/utils.cpp

## Communities (104 total, 23 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.01
Nodes (153): 21f3388b-c2a5-4791-8f6e-a4cad6d17f4f.Bubble, 2354565a-f412-4654-b89c-f92eaa9dbd20.BingHomePage.Bubble, 2354565a-f412-4654-b89c-f92eaa9dbd20.Covid.Bubble, 2354565a-f412-4654-b89c-f92eaa9dbd20.Finance.Bubble, 2354565a-f412-4654-b89c-f92eaa9dbd20.Jobs.Bubble, 2354565a-f412-4654-b89c-f92eaa9dbd20.KnowledgeCard.Bubble, 2354565a-f412-4654-b89c-f92eaa9dbd20.Local.Bubble, 2354565a-f412-4654-b89c-f92eaa9dbd20.NotifySearchPage.Bubble (+145 more)

### Community 1 - "Community 1"
Cohesion: 0.05
Nodes (8): assets_for_linking, status, timestamp, ServicioController, Servicio, ServicioUsuario, ServicioRepository, ServicioUsuarioRepository

### Community 2 - "Community 2"
Cohesion: 0.04
Nodes (52): market_domain_regex_map, ae, ar, at, au, be, bg, br (+44 more)

### Community 3 - "Community 3"
Cohesion: 0.04
Nodes (52): domain_page_locales, ajio.com, asda.com, bigbasket.com, blakelyclothing.com, boat-lifestyle.com, dangdang.com, discogs.com (+44 more)

### Community 4 - "Community 4"
Cohesion: 0.04
Nodes (50): ACCOUNT_CREATION_PASSWORD, ADDRESS_HOME_CITY, ADDRESS_HOME_COUNTRY, ADDRESS_HOME_LINE1, ADDRESS_HOME_LINE2, ADDRESS_HOME_LINE3, ADDRESS_HOME_STATE, ADDRESS_HOME_STREET_ADDRESS (+42 more)

### Community 5 - "Community 5"
Cohesion: 0.04
Nodes (50): 0, 1, 10, 11, 12, 13, 14, 15 (+42 more)

### Community 6 - "Community 6"
Cohesion: 0.04
Nodes (45): price_regex, am, au, aw, az, bd, bn, bs (+37 more)

### Community 7 - "Community 7"
Cohesion: 0.05
Nodes (38): build, CrearServicioPage, _CrearServicioPageState, Scaffold, _ajustarCamara, _alCrearServicio, _aplicarSalidaLlegadaEnMapa, build (+30 more)

### Community 8 - "Community 8"
Cohesion: 0.08
Nodes (26): FlutterWindow(), OnCreate(), wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), Create(), Destroy() (+18 more)

### Community 9 - "Community 9"
Cohesion: 0.05
Nodes (40): default_locale_map, bg, bs, cs, da, de, el, en (+32 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (5): AuthController, ServicioUsuarioId, Usuario, UsuarioRepository, Serializable

### Community 11 - "Community 11"
Cohesion: 0.06
Nodes (34): notification_max_quick_dismiss_count, ArbitrationSignal, baseConfigVersion, notification_max_quick_dismiss_count, notification_max_quick_dismiss_count, notification_max_quick_dismiss_count, configVersion, CopilotModeBypass (+26 more)

### Community 12 - "Community 12"
Cohesion: 0.06
Nodes (31): currency_symbol_regex_map, AED, AFN, AMD, AWG, AZN, BDT, BGN (+23 more)

### Community 13 - "Community 13"
Cohesion: 0.09
Nodes (23): es, price_regex, product_terms, ar, bo, cl, co, cr (+15 more)

### Community 14 - "Community 14"
Cohesion: 0.09
Nodes (22): build, _buildAccionesCreador, _buildErrorEstado, _buildListaMiembros, _buildSalirMiembro, Card, _cargarMiembros, Center (+14 more)

### Community 15 - "Community 15"
Cohesion: 0.09
Nodes (22): build, Card, _cargarServicios, Column, dispose, Function, HomePage, _HomePageState (+14 more)

### Community 16 - "Community 16"
Cohesion: 0.09
Nodes (21): build, _cabeceraDecorada, Card, Center, Container, dispose, Expanded, Function (+13 more)

### Community 17 - "Community 17"
Cohesion: 0.10
Nodes (20): RouteService, ActionChip, build, Column, CrearServicioForm, _CrearServicioFormState, didUpdateWidget, dispose (+12 more)

### Community 18 - "Community 18"
Cohesion: 0.10
Nodes (20): target_ndk_api, assets, ar, cc, ld, android, c_compiler, link_mode_preference (+12 more)

### Community 19 - "Community 19"
Cohesion: 0.12
Nodes (4): ApplicationRunner, UbicacionCoordenadasSeeder, GoPoliApplication, Ubicacion

### Community 20 - "Community 20"
Cohesion: 0.11
Nodes (7): fl_register_plugins(), main(), my_application_activate(), my_application_new(), _MyApplication, dart_entrypoint_arguments, parent_instance

### Community 21 - "Community 21"
Cohesion: 0.11
Nodes (18): aee_config, ar, autofill, character_cutoff, de, ee_timeout_threshold_seconds, el, en (+10 more)

### Community 22 - "Community 22"
Cohesion: 0.12
Nodes (16): price_regex, be, ca, cd, fr, gf, gh, gn (+8 more)

### Community 23 - "Community 23"
Cohesion: 0.15
Nodes (12): AlertDialog, build, CrearUsuarioPage, _CrearUsuarioPageState, initState, mostrarError, Scaffold, SizedBox (+4 more)

### Community 24 - "Community 24"
Cohesion: 0.17
Nodes (11): build, Expanded, LoginPage, _LoginPageState, Scaffold, SizedBox, Text, TextSpan (+3 more)

### Community 25 - "Community 25"
Cohesion: 0.18
Nodes (9): build, main, MaterialApp, MyApp, main, package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:gopoli/main.dart (+1 more)

### Community 26 - "Community 26"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 27 - "Community 27"
Cohesion: 0.18
Nodes (10): 1) Backend + PostgreSQL, 2) URL publica del backend, 3) Frontend Flutter apuntando a Railway, 4) Migrar datos de BD local a Railway (opcional), 5) Checklist final, code:bash (flutter run --dart-define=API_URL=https://gopoli-backend.up.), code:bash (flutter build apk --release --dart-define=API_URL=https://go), code:bash (pg_dump -h localhost -U postgres -d gopoli -F c -f gopoli.du) (+2 more)

### Community 28 - "Community 28"
Cohesion: 0.22
Nodes (9): equivalent_locale_map, en-gb-au, en-gb-ca, en-gb-gb, en-gb-in, -tw, us-en, zh-hans-cn (+1 more)

### Community 29 - "Community 29"
Cohesion: 0.29
Nodes (7): autofill_onnx_model_config, default, en, autofill_class_num, autofill_language_confidence_bar, autofill_max_sequence_length, autofill_sliding_window

### Community 30 - "Community 30"
Cohesion: 0.22
Nodes (8): build, _cerrarSesion, PerfilPage, _PerfilPageState, Scaffold, SizedBox, login_page.dart, ../utils/session_manager.dart

### Community 31 - "Community 31"
Cohesion: 0.22
Nodes (3): FlutterAppDelegate, FlutterImplicitEngineDelegate, AppDelegate

### Community 32 - "Community 32"
Cohesion: 0.25
Nodes (8): price_regex, price_regex, at, ch, de, it, li, lu

### Community 33 - "Community 33"
Cohesion: 0.25
Nodes (7): configVersion, flutterRoot, flutterVersion, generator, generatorVersion, packages, pubCache

### Community 34 - "Community 34"
Cohesion: 0.25
Nodes (7): contrasenaValida, correoInstitucional, documentoValido, nombreValido, RegExp, telefonoValido, Validaciones

### Community 37 - "Community 37"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 38 - "Community 38"
Cohesion: 0.33
Nodes (6): largest_contentful_paint_thresholds, proactive_contentful_paint_delay_seconds, secondary_no_mutations_observed_ext_seconds, secondary_no_mutations_observed_seconds, secondary_observe_mutations_max_seconds, secondary_observer_mutations_ext_max_seconds

### Community 39 - "Community 39"
Cohesion: 0.33
Nodes (6): price_regex, ae, dz, eg, ma, sa

### Community 40 - "Community 40"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 41 - "Community 41"
Cohesion: 0.33
Nodes (5): build_end, build_start, code_assets, data_assets, dependencies

### Community 42 - "Community 42"
Cohesion: 0.33
Nodes (5): build_end, build_start, code_assets, data_assets, dependencies

### Community 43 - "Community 43"
Cohesion: 0.33
Nodes (5): build_end, build_start, code_assets, data_assets, dependencies

### Community 44 - "Community 44"
Cohesion: 0.33
Nodes (5): _PluginRegistrant, register, dart:io, package:google_maps_flutter_android/google_maps_flutter_android.dart, package:google_maps_flutter_ios/google_maps_flutter_ios.dart

### Community 45 - "Community 45"
Cohesion: 0.33
Nodes (5): Getting Started, GoPoli (mapas y ubicaciones), Guides, Maven Parent overrides, Reference Documentation

### Community 46 - "Community 46"
Cohesion: 0.40
Nodes (4): cerrarSesion, etiquetaTipoUsuario, iniciarSesion, SessionManager

### Community 47 - "Community 47"
Cohesion: 0.40
Nodes (4): Facturación, Google Maps: qué es la “API key” y cómo sacarla, Pasos (unos 5 minutos), Si no pones clave

### Community 48 - "Community 48"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 51 - "Community 51"
Cohesion: 0.50
Nodes (4): da, price_regex, product_terms, dk

### Community 52 - "Community 52"
Cohesion: 0.50
Nodes (4): et, price_regex, product_terms, ee

### Community 53 - "Community 53"
Cohesion: 0.50
Nodes (4): is, price_regex, product_terms, is

### Community 54 - "Community 54"
Cohesion: 0.50
Nodes (4): ko, price_regex, product_terms, kr

### Community 55 - "Community 55"
Cohesion: 0.50
Nodes (4): bg, price_regex, product_terms, bg

### Community 56 - "Community 56"
Cohesion: 0.50
Nodes (4): bs, price_regex, product_terms, ba

### Community 57 - "Community 57"
Cohesion: 0.50
Nodes (4): hr, price_regex, product_terms, hr

### Community 58 - "Community 58"
Cohesion: 0.50
Nodes (4): lv, price_regex, product_terms, lv

### Community 59 - "Community 59"
Cohesion: 0.50
Nodes (4): fa, price_regex, product_terms, ir

### Community 60 - "Community 60"
Cohesion: 0.50
Nodes (4): ja, price_regex, product_terms, jp

### Community 61 - "Community 61"
Cohesion: 0.50
Nodes (4): lt, price_regex, product_terms, lt

### Community 62 - "Community 62"
Cohesion: 0.50
Nodes (4): cs, price_regex, product_terms, cz

### Community 63 - "Community 63"
Cohesion: 0.50
Nodes (4): hu, price_regex, product_terms, hu

### Community 64 - "Community 64"
Cohesion: 0.50
Nodes (4): fi, price_regex, product_terms, fi

### Community 65 - "Community 65"
Cohesion: 0.50
Nodes (4): he, price_regex, product_terms, il

### Community 67 - "Community 67"
Cohesion: 0.50
Nodes (3): registerPlugins, package:flutter_web_plugins/flutter_web_plugins.dart, package:google_maps_flutter_web/google_maps_flutter_web.dart

### Community 68 - "Community 68"
Cohesion: 0.50
Nodes (3): configVersion, packages, roots

### Community 72 - "Community 72"
Cohesion: 0.67
Nodes (3): price_regex, cy, gr

### Community 103 - "Community 103"
Cohesion: 0.10
Nodes (19): 1) Crear el proyecto en Neon, 2) Variables para Spring Boot, 3) Migrar tu BD local (`gopoli`) a Neon, 4) Arrancar el backend contra Neon, 5) pgAdmin con Neon (opcional), 6) Compañeros: checklist rápido, 7) Backend en Railway + BD en Neon, 8) Buenas prácticas en equipo (+11 more)

## Knowledge Gaps
- **857 isolated node(s):** `java.compile.nullAnalysis.mode`, `CarreraRepository`, `TipoUsuarioRepository`, `UbicacionRepository`, `configVersion` (+852 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **23 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `aee_config` connect `Community 21` to `Community 2`, `Community 3`, `Community 9`, `Community 12`, `Community 13`, `Community 28`, `Community 38`, `Community 51`, `Community 52`, `Community 53`, `Community 54`, `Community 55`, `Community 56`, `Community 57`, `Community 58`, `Community 59`, `Community 60`, `Community 61`, `Community 62`, `Community 63`, `Community 64`, `Community 65`?**
  _High betweenness centrality (0.141) - this node is a cross-community bridge._
- **Why does `autofill_onnx_model_config` connect `Community 29` to `Community 5`, `Community 4`, `Community 21`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Why does `autofill` connect `Community 21` to `Community 29`?**
  _High betweenness centrality (0.058) - this node is a cross-community bridge._
- **What connects `java.compile.nullAnalysis.mode`, `CarreraRepository`, `TipoUsuarioRepository` to the rest of the system?**
  _858 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.013071895424836602 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.05493863237872589 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.038461538461538464 - nodes in this community are weakly interconnected._