import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/core/theme/theme_preferences_local_data_source.dart';
import 'package:kivu_haqms/core/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._dataSource)
      : super(const ThemeState(themeMode: ThemeMode.light)) {
    _loadThemeMode();
  }

  final ThemePreferencesLocalDataSource _dataSource;

  Future<void> _loadThemeMode() async {
    final themeMode = await _dataSource.getThemeMode();
    emit(ThemeState(themeMode: themeMode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(ThemeState(themeMode: mode));
    await _dataSource.setThemeMode(mode);
  }
}
