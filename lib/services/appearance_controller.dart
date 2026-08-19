import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hell, dunkel oder wie das System.
///
/// Voreinstellung ist „System": Wer nachts übt, hat sein Telefon meist schon
/// umgestellt, und eine App, die sich darüber hinwegsetzt, blendet.
class AppearanceController extends Notifier<ThemeMode> {
  static const String storageKey = 'theme_mode_v1';

  @override
  ThemeMode build() {
    final raw = ref.watch(storageServiceProvider).themeModeId;
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(storageServiceProvider).saveThemeModeId(mode.name);
  }

  static String label(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Hell',
        ThemeMode.dark => 'Dunkel',
        ThemeMode.system => 'System',
      };
}

final themeModeProvider =
    NotifierProvider<AppearanceController, ThemeMode>(AppearanceController.new);
