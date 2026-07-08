# my_app — Trabajo de Grado

Aplicación móvil en **Flutter** orientada al **bienestar personal y la formación de hábitos saludables**, con un sistema de **gamificación** (una planta virtual que crece según tu progreso), foro de la comunidad, biblioteca de lectura con seguimiento de progreso y seguimiento de hábitos con rachas y estadísticas.

Este repositorio corresponde al proyecto de trabajo de grado, construido con **Flutter + BLoC** siguiendo **Clean Architecture** y respaldado por **Firebase** (Auth, Firestore, Storage).

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)
![BLoC](https://img.shields.io/badge/State%20Management-flutter__bloc-1D7A6B)
![Architecture](https://img.shields.io/badge/architecture-Clean%20Architecture-blueviolet)

---

## Tabla de contenido

- [Características](#características)
- [Arquitectura](#arquitectura)
- [Módulos de la aplicación](#módulos-de-la-aplicación)
- [Stack tecnológico](#stack-tecnológico)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Puesta en marcha](#puesta-en-marcha)
- [Configuración de Firebase](#configuración-de-firebase)
- [Modelo de gamificación](#modelo-de-gamificación)
- [Plataformas soportadas](#plataformas-soportadas)

---

## Características

- 🔐 **Autenticación** con Firebase Auth (login / registro), sesión persistente y refresco de token en segundo plano (`workmanager`).
- 🌱 **Gamificación con planta virtual**: una animación (Rive) que crece o decae según la constancia del usuario en los distintos módulos (hábitos, foro, lectura), con niveles, puntos, salud e insignias desbloqueables.
- ✅ **Seguimiento de hábitos**: creación de hábitos con frecuencia configurable (diaria o N veces por semana), registro de cumplimiento, cálculo de rachas actuales/mejores, tasa de éxito semanal y mensual, mapa de calor (heatmap) y gráficos de tendencia.
- 💬 **Foro comunitario**: publicaciones por categoría, likes, respuestas, búsqueda, publicaciones populares e historial de publicaciones por usuario.
- 📚 **Biblioteca digital**: catálogo de libros en PDF por categoría, búsqueda, libros guardados/favoritos y seguimiento de progreso de lectura en tiempo real (stream) con lectura in-app (`syncfusion_flutter_pdfviewer`).
- 🏅 **Insignias**: catálogo de insignias con requisitos configurables, desbloqueo automático según el historial de eventos del usuario.
- 🧑 **Perfil de usuario** editable con avatar cacheado.
- 🎓 **Onboarding y showcase** (tour guiado) para nuevos usuarios, con persistencia de progreso vía `shared_preferences`.
- 🌗 **Tema claro/oscuro** adaptado al sistema.

## Arquitectura

El proyecto sigue **Clean Architecture** por *feature*, con inyección de dependencias centralizada mediante `get_it` (`lib/core/di/injector.dart`) y gestión de estado con **BLoC** en cada módulo:

```
lib/
├── core/
│   ├── di/                # Inyección de dependencias (injector.dart) y manejo de errores de Firebase
│   ├── failures/           # Tipos de Failure de dominio (usados con `dartz` / Either)
│   └── usescases/          # Contrato base de caso de uso
│
├── <feature>/
│   ├── data/
│   │   ├── datasources/     # Acceso a Firestore/Storage
│   │   ├── models/            # Serialización Firestore ↔ entity
│   │   └── repositories/        # Implementación del repositorio
│   ├── domain/
│   │   ├── entities/            # Modelos de dominio puros
│   │   ├── repositories/         # Contratos abstractos
│   │   └── usecases/              # Casos de uso (un caso de uso por acción)
│   └── presentation/
│       ├── bloc(s)/                # Eventos, estados y lógica de UI
│       ├── screens|pages/            # Pantallas
│       └── widgets/                    # Widgets reutilizables del módulo
```

Cada caso de uso encapsula una única operación de negocio (p. ej. `CreateHabitUsecase`, `LikeForumPost`, `CheckAndUnlockInsignias`), lo que facilita testear la lógica de forma aislada del framework de UI y de Firebase.

## Módulos de la aplicación

| Módulo          | Responsabilidad                                                                 |
|------------------|-----------------------------------------------------------------------------------|
| `login` / `register` | Autenticación de usuarios con Firebase Auth                                    |
| `profile`         | Perfil del usuario (datos, avatar)                                                 |
| `habits`          | Creación y seguimiento de hábitos, cálculo de progreso, rachas y tendencias           |
| `gamification`     | Estado de la planta virtual, niveles, puntos, insignias e historial de eventos          |
| `forum`            | Publicaciones de la comunidad, likes, respuestas, categorías y búsqueda                    |
| `library`           | Catálogo de libros, lectura de PDF, libros guardados y progreso de lectura                   |
| `onboarding` / `showcase` | Introducción a la app y tour guiado de funcionalidades para nuevos usuarios       |
| `splash`             | Pantalla de carga inicial y verificación de sesión                                          |

## Stack tecnológico

| Categoría                  | Paquete(s)                                                     |
|------------------------------|-------------------------------------------------------------------|
| Framework                    | Flutter / Dart                                                       |
| Gestión de estado            | `flutter_bloc`, `equatable`                                            |
| Backend / datos               | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`  |
| Inyección de dependencias      | `get_it`                                                                   |
| Manejo funcional de errores     | `dartz` (Either / Failure)                                                   |
| Navegación                        | `go_router`                                                                     |
| Animaciones                         | `rive` (planta animada), `animations`, `page_transition`                          |
| Lectura de PDF                        | `syncfusion_flutter_pdfviewer`, `syncfusion_flutter_pdf`                             |
| Gráficos                                | `syncfusion_flutter_charts`, `flutter_heatmap_calendar`                                |
| Persistencia local                        | `shared_preferences`                                                                     |
| Tareas en segundo plano                     | `workmanager` (mantener sesión activa)                                                      |
| Imágenes                                      | `cached_network_image`, `flutter_cache_manager`                                               |
| Onboarding guiado                               | `showcaseview`                                                                                  |
| Temas                                              | `adaptive_theme`                                                                                    |
| Fechas / zonas horarias                              | `intl`, `time`, `timezone`                                                                             |

## Estructura del proyecto

```
my_app/
├── android/ ios/                 # Proyectos nativos (incluye google-services.json)
├── assets/
│   ├── images/                    # Ilustraciones (ajolotes, árboles, onboarding, insignias, etc.)
│   ├── insignias/                   # Íconos de insignias
│   └── *.riv                          # Animaciones Rive de la planta/árbol
├── lib/
│   ├── core/                            # DI, failures, usecases base
│   ├── config/app_router.dart             # Definición de rutas nombradas
│   ├── login/ register/ profile/            # Autenticación y perfil
│   ├── habits/                                 # Hábitos
│   ├── gamification/                             # Planta virtual, insignias, progreso
│   ├── forum/                                      # Foro comunitario
│   ├── library/                                      # Biblioteca y lectura de PDF
│   ├── onboarding/ showcase/                            # Onboarding y tour guiado
│   ├── splash/                                            # Pantalla de arranque
│   ├── widgets/                                             # Widgets compartidos
│   ├── app.dart                                               # Configuración de MaterialApp, BLoCs globales y tema
│   └── main.dart                                                # Punto de entrada, inicialización de Firebase/Rive/timezone
├── test/
├── pubspec.yaml
└── analysis_options.yaml
```

## Puesta en marcha

### Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ≥ 2.17, compatible con Dart 3)
- Un proyecto de **Firebase** con Authentication, Firestore y Storage habilitados
- Archivo de configuración de Firebase para cada plataforma (`google-services.json` para Android, `GoogleService-Info.plist` para iOS)

### Instalación

```bash
git clone https://github.com/N4him/Trabajodegrado.git
cd Trabajodegrado/my_app

flutter pub get
```

> El repositorio contiene varias ramas de desarrollo (`main`, `Details`, `Rama__test`, `habits_module`); `main` es la rama principal.

### Ejecución

```bash
flutter run
```

## Configuración de Firebase

La app se inicializa contra Firebase en `main.dart` mediante `Firebase.initializeApp()`. Se requiere:

1. Registrar la app Android/iOS en la consola de Firebase.
2. Colocar `google-services.json` en `android/app/` (ya incluido como plantilla en este repo; reemplázalo por el de tu propio proyecto).
3. Habilitar **Authentication** (correo/contraseña), **Cloud Firestore** y **Cloud Storage**.
4. Ejecutar `flutterfire configure` si necesitas regenerar `firebase_options.dart` para otras plataformas.

La app mantiene la sesión activa refrescando el ID token de Firebase mediante una tarea periódica con `workmanager`.

## Modelo de gamificación

El módulo `gamification` centraliza el progreso motivacional del usuario:

- **`EstadoGeneral`**: valor y salud de la "planta" virtual, y su etapa de crecimiento — se actualiza según la constancia del usuario.
- **`ModuloProgreso`**: contador de progreso por módulo (`habits`, `forum`, `library`, etc.), incluyendo días cumplidos, racha actual, publicaciones, lecturas, tests aprobados y puntos obtenidos.
- **`Insignia`**: catálogo de logros con un `Requisito` (tipo + valor) que determina cuándo se desbloquea automáticamente (`CheckAndUnlockInsignias`), otorgando puntos adicionales.
- **`historialEventos`**: registro de eventos (timestamps) usado como base para calcular rachas y desbloqueos.

Esta capa se alimenta de eventos disparados por los demás módulos (completar un hábito, publicar en el foro, terminar un libro), reforzando el hábito mediante una recompensa visual inmediata.

## Plataformas soportadas

Android e iOS (proyecto Flutter estándar, sin configuración específica para web o escritorio en este repositorio).

---

Proyecto de trabajo de grado — aplicación de bienestar y formación de hábitos con gamificación.
