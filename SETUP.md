# Radha Radha - Setup Instructions

## Prerequisites
- Flutter SDK >= 3.2.0
- Android Studio or Xcode
- A device or emulator

## Setup Steps

### Step 1: Initialize Flutter Project
Open terminal in this directory and run:
```bash
flutter create . --org com.radhaapps --project-name radharadha --platforms android,ios
```
This generates the native project boilerplate (Xcode project, Gradle wrapper scripts, etc.).
Your custom source files will NOT be overwritten as Flutter create only generates missing files.

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Generate Localizations
```bash
flutter gen-l10n
```
This generates `lib/flutter_gen/gen_l10n/app_localizations.dart` from the ARB files.

### Step 4: Android Permissions
The `AndroidManifest.xml` is already configured. Make sure your `android/app/build.gradle`
has `minSdkVersion 21` (already set).

### Step 5: iOS Setup
In Xcode, enable these capabilities for the Runner target:
- Background Modes → Audio, AirPlay, and Picture in Picture

### Step 6: Run
```bash
flutter run
```

## Architecture Overview

```
main.dart          → App entry point, Hive init
app.dart           → MaterialApp, themes, localization
providers/         → Riverpod state management
services/          → Business logic (audio, recording, storage, bg service, phone)
screens/           → UI screens
widgets/           → Reusable UI components
models/            → Data models (Hive)
core/              → Theme, constants, utilities
l10n/              → Localization ARB files
```

## Key Features
- Background audio playback on configurable interval
- Record or upload audio files
- Phone call detection (skips interval during calls)
- Light/Dark theme
- English/Hindi localization
- Offline-first with Hive storage
