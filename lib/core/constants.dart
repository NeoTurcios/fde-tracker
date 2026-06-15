class AppConstants {
  static const String baseUrlGuatemala = 'https://rastreo.forzadelivery.com/fd/Home.aspx/API';
  static const String baseUrlHonduras = 'https://portal.forzadelivery.com/fdHN/Home.aspx/API';
  static const String defaultBaseUrl = baseUrlGuatemala;

  static const String trackingPublicPath = 'Tracking/GetTrackingPublic';
  static const String trackingNewDeliveryPath = 'Tracking/GetNewDeliveryTracking';
  static const String trackingPrivatePath = 'Tracking/GetTrackingPrivate';
  static const String getInfoPackagesPath = 'Tracking/GetInfoPackages';
  static const String getDeliveryVoucherUrlPath = 'Tracking/GetDeliveryVoucherURL';
  static const String getQualifyServicePath = 'Tracking/GetQualifyServiceTracking';
  static const String getQueryQualifyServicePath = 'Tracking/GetQueryQualifyService';
  static const String setReschedulingDatePath = 'Tracking/SetReschedulingDate';
  static const String setNewDeliveryAddressPath = 'Tracking/SetNewDeliveryAddress';

  static const String unauthenticatedToken = 'user no logged in tracking';

  static const String prefsKeyThemeMode = 'theme_mode';
  static const String prefsKeyCacheLimit = 'cache_limit';
  static const String prefsKeyDefaultCountry = 'default_country';
  static const String prefsKeyNotificationsEnabled = 'notifications_enabled';
  static const String prefsKeyAutoRefresh = 'auto_refresh';
  static const String prefsKeyRefreshInterval = 'refresh_interval';

  static const int defaultCacheLimit = 20;
  static const int maxCacheLimit = 100;
  static const int minCacheLimit = 5;

  static const String hiveBoxHistory = 'tracking_history';
  static const String hiveBoxSettings = 'settings';
}

enum Country { guatemala, honduras }

extension CountryExtension on Country {
  String get baseUrl {
    switch (this) {
      case Country.guatemala:
        return AppConstants.baseUrlGuatemala;
      case Country.honduras:
        return AppConstants.baseUrlHonduras;
    }
  }

  String get displayName {
    switch (this) {
      case Country.guatemala:
        return 'Guatemala';
      case Country.honduras:
        return 'Honduras';
    }
  }

  String get flagEmoji {
    switch (this) {
      case Country.guatemala:
        return '🇬🇹';
      case Country.honduras:
        return '🇭🇳';
    }
  }
}

enum ThemeModeOption { system, light, dark }

extension ThemeModeOptionExtension on ThemeModeOption {
  String get displayName {
    switch (this) {
      case ThemeModeOption.system:
        return 'Sistema';
      case ThemeModeOption.light:
        return 'Claro';
      case ThemeModeOption.dark:
        return 'Oscuro';
    }
  }
}