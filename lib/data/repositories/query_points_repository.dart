import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class QueryPointsRepository extends ChangeNotifier {
  int _balance = 0;
  bool _initialized = false;

  DateTime? _lastQueryTime;
  int _dailyAdCount = 0;
  String _lastAdDate = '';
  DateTime? _lastAdTime;

  int get balance => _balance;

  int get remainingDailyAds {
    _checkDailyReset();
    return AppConstants.maxDailyAds - _dailyAdCount;
  }

  bool get canWatchAd {
    _checkDailyReset();
    if (_dailyAdCount >= AppConstants.maxDailyAds) return false;
    if (_lastAdTime == null) return true;
    return DateTime.now().difference(_lastAdTime!) >=
        const Duration(seconds: AppConstants.adCooldownSeconds);
  }

  int get adCooldownRemaining {
    if (_lastAdTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastAdTime!).inSeconds;
    return (AppConstants.adCooldownSeconds - elapsed).clamp(0, AppConstants.adCooldownSeconds);
  }

  bool get canQuery {
    if (_lastQueryTime == null) return true;
    return DateTime.now().difference(_lastQueryTime!) >=
        const Duration(seconds: AppConstants.queryCooldownSeconds);
  }

  int get queryCooldownRemaining {
    if (_lastQueryTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastQueryTime!).inSeconds;
    return (AppConstants.queryCooldownSeconds - elapsed).clamp(0, AppConstants.queryCooldownSeconds);
  }

  bool get canAffordTrack => _balance >= AppConstants.costPerTrack;

  Future<void> load() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(AppConstants.prefsKeyQueryBalance) ?? -1;
    if (_balance == -1) {
      _balance = AppConstants.welcomePoints;
      await prefs.setInt(AppConstants.prefsKeyQueryBalance, _balance);
    }
    _dailyAdCount = prefs.getInt(AppConstants.prefsKeyDailyAdCount) ?? 0;
    _lastAdDate = prefs.getString(AppConstants.prefsKeyLastAdDate) ?? '';
    _checkDailyReset();
    _initialized = true;
    notifyListeners();
  }

  Future<bool> deduct() async {
    if (_balance < AppConstants.costPerTrack) return false;
    _balance -= AppConstants.costPerTrack;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefsKeyQueryBalance, _balance);
    notifyListeners();
    return true;
  }

  Future<void> add(int points) async {
    _balance += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefsKeyQueryBalance, _balance);
    notifyListeners();
  }

  void markQuery() {
    _lastQueryTime = DateTime.now();
    notifyListeners();
  }

  Future<void> markAdWatched() async {
    _dailyAdCount++;
    _lastAdDate = _todayStr();
    _lastAdTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefsKeyDailyAdCount, _dailyAdCount);
    await prefs.setString(AppConstants.prefsKeyLastAdDate, _lastAdDate);
    notifyListeners();
  }

  void _checkDailyReset() {
    final today = _todayStr();
    if (_lastAdDate != today) {
      _dailyAdCount = 0;
      _lastAdDate = today;
    }
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
