# Caja de Herramientas — Flutter

Aplicación académica para ITLA. Tema oscuro con acentos turquesa.

## Requisitos
- Flutter SDK estable
- Android Studio / Android SDK
- Conexión a internet para consumir las API

## Ejecutar
```bash
flutter pub get
flutter run
```

## Generar APK
Conecta un emulador o dispositivo Android y ejecuta:
```bash
flutter build apk --release
```
El archivo suele generarse en `build/app/outputs/flutter-apk/app-release.apk`.

## Funciones
1. Inicio con identidad visual de caja de herramientas.
2. Predicción de género — Genderize.
3. Persona aleatoria — Random User.
4. Universidades por país — proxy de Adamix.
5. Clima de Santo Domingo — Open-Meteo.
6. Pokémon — PokéAPI, habilidades, experiencia y audio latest.
7. Tres noticias de Kinsta — WordPress REST API.
8. Acerca de con foto y contacto.

## Publicar en GitHub
Crea un repositorio vacío en https://github.com/new y, desde esta carpeta:
```bash
git init
git add .
git commit -m "Proyecto Flutter Caja de Herramientas"
git branch -M main
git remote add origin https://github.com/Stivenjpeg/caja-herramientas-flutter.git
git push -u origin main
```
Si ya existe un repositorio con otro nombre, sustituye la URL del remoto.


