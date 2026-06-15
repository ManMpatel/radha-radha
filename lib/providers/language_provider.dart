import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(Locale(StorageService.getLanguage()));

  void setEnglish() {
    state = const Locale('en');
    StorageService.setLanguage('en');
  }

  void setHindi() {
    state = const Locale('hi');
    StorageService.setLanguage('hi');
  }

  void toggle() {
    if (state.languageCode == 'en') {
      setHindi();
    } else {
      setEnglish();
    }
  }

  bool get isHindi => state.languageCode == 'hi';
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
  (ref) => LanguageNotifier(),
);
