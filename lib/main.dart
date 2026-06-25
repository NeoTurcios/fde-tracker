import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/query_points_repository.dart';
import 'data/services/rewarded_ad_service.dart';
import 'presentation/blocs/theme_cubit.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await MobileAds.instance.initialize();
  } catch (_) {
    // AdMob initialization failed — ads won't work but app should not crash
  }

  final historyRepository = HistoryRepository();
  await historyRepository.load();

  final queryPointsRepository = QueryPointsRepository();
  await queryPointsRepository.load();

  final rewardedAdService = RewardedAdService();

  final prefs = await SharedPreferences.getInstance();
  final themeCubit = ThemeCubit();

  final themeModeStr = prefs.getString(AppConstants.prefsKeyThemeMode) ?? 'system';
  switch (themeModeStr) {
    case 'light':
      themeCubit.setThemeMode(ThemeMode.light);
      break;
    case 'dark':
      themeCubit.setThemeMode(ThemeMode.dark);
      break;
    default:
      themeCubit.setThemeMode(ThemeMode.system);
  }

  themeCubit.addListener(() async {
    final p = await SharedPreferences.getInstance();
    String modeStr;
    switch (themeCubit.value) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      default:
        modeStr = 'system';
    }
    await p.setString(AppConstants.prefsKeyThemeMode, modeStr);
  });

  runApp(FDEApp(
    historyRepository: historyRepository,
    themeCubit: themeCubit,
    queryPointsRepository: queryPointsRepository,
    rewardedAdService: rewardedAdService,
  ));
}
