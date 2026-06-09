import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracking_history_entry.dart';
import '../../core/constants.dart';

class HistoryRepository extends ChangeNotifier {
  List<TrackingHistoryEntry> _entries = [];
  int _limit = AppConstants.defaultCacheLimit;

  List<TrackingHistoryEntry> get all => List.unmodifiable(_entries);

  int get limit => _limit;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _limit = prefs.getInt(AppConstants.prefsKeyCacheLimit) ?? AppConstants.defaultCacheLimit;

    final data = prefs.getString(AppConstants.hiveBoxHistory);
    if (data != null) {
      try {
        final list = jsonDecode(data) as List<dynamic>;
        _entries = list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _entries = [];
      }
    }
    notifyListeners();
  }

  Future<void> add(TrackingHistoryEntry entry) async {
    _entries.removeWhere((e) =>
        e.guideSerie == entry.guideSerie && e.guideNumber == entry.guideNumber);

    _entries.insert(0, entry);

    if (_entries.length > _limit) {
      _entries = _entries.sublist(0, _limit);
    }

    await _save();
    notifyListeners();
  }

  Future<void> remove(String guideSerie, String guideNumber) async {
    _entries.removeWhere((e) =>
        e.guideSerie == guideSerie && e.guideNumber == guideNumber);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _entries.clear();
    await _save();
    notifyListeners();
  }

  Future<void> setLimit(int limit) async {
    _limit = limit;
    if (_entries.length > _limit) {
      _entries = _entries.sublist(0, _limit);
      await _save();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefsKeyCacheLimit, limit);
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_entries.map((e) => _toJson(e)).toList());
    await prefs.setString(AppConstants.hiveBoxHistory, data);
  }

  Map<String, dynamic> _toJson(TrackingHistoryEntry entry) {
    return {
      'guideSerie': entry.guideSerie,
      'guideNumber': entry.guideNumber,
      'statusTitle': entry.statusTitle,
      'statusDescription': entry.statusDescription,
      'receiverName': entry.receiverName,
      'lastUpdate': entry.lastUpdate,
      'hasError': entry.hasError,
    };
  }

  TrackingHistoryEntry _fromJson(Map<String, dynamic> json) {
    return TrackingHistoryEntry(
      guideSerie: json['guideSerie'] as String? ?? '',
      guideNumber: json['guideNumber'] as String? ?? '',
      statusTitle: json['statusTitle'] as String? ?? '',
      statusDescription: json['statusDescription'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      lastUpdate: json['lastUpdate'] as String? ?? '',
      hasError: json['hasError'] as bool? ?? false,
    );
  }
}