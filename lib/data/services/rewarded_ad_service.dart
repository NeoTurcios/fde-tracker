import 'package:google_mobile_ads/google_mobile_ads.dart';

enum RewardedAdStatus { loading, ready, failed, dismissed, rewarded }

class RewardedAdService {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  String? _primaryAdUnitId;
  String? _fallbackAdUnitId;
  void Function(RewardedAdStatus)? _pendingOnStatus;

  bool get isLoading => _isLoading;

  void loadAd({
    required String primaryAdUnitId,
    String? fallbackAdUnitId,
    required void Function(RewardedAdStatus status) onStatus,
  }) {
    if (_isLoading || _adReady) return;
    _isLoading = true;
    _primaryAdUnitId = primaryAdUnitId;
    _fallbackAdUnitId = fallbackAdUnitId;
    _pendingOnStatus = onStatus;
    onStatus(RewardedAdStatus.loading);
    _loadInterstitial();
  }

  void showAd({
    required void Function(RewardedAdStatus status) onStatus,
  }) {
    if (_rewardedInterstitialAd != null) {
      _showRewardedInterstitial(onStatus);
    } else if (_rewardedAd != null) {
      _showRewardedVideo(onStatus);
    } else {
      onStatus(RewardedAdStatus.failed);
    }
  }

  bool get _adReady =>
      _rewardedInterstitialAd != null || _rewardedAd != null;

  void _loadInterstitial() {
    RewardedInterstitialAd.load(
      adUnitId: _primaryAdUnitId!,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isLoading = false;
          _retryCount = 0;
          _pendingOnStatus?.call(RewardedAdStatus.ready);
        },
        onAdFailedToLoad: (error) {
          _fallbackToVideo();
        },
      ),
    );
  }

  void _fallbackToVideo() {
    if (_fallbackAdUnitId == null) {
      _handleRetry();
      return;
    }
    RewardedAd.load(
      adUnitId: _fallbackAdUnitId!,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          _retryCount = 0;
          _pendingOnStatus?.call(RewardedAdStatus.ready);
        },
        onAdFailedToLoad: (error) {
          _handleRetry();
        },
      ),
    );
  }

  void _handleRetry() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      Future.delayed(_retryDelay, () {
        _loadInterstitial();
      });
    } else {
      _isLoading = false;
      _retryCount = 0;
      _pendingOnStatus?.call(RewardedAdStatus.failed);
    }
  }

  void _showRewardedInterstitial(
    void Function(RewardedAdStatus status) onStatus,
  ) {
    final ad = _rewardedInterstitialAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        onStatus(RewardedAdStatus.dismissed);
        _preloadNext();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        if (_rewardedAd != null) {
          _showRewardedVideo(onStatus);
        } else {
          onStatus(RewardedAdStatus.failed);
        }
      },
    );
    ad.show(
      onUserEarnedReward: (ad, reward) {
        onStatus(RewardedAdStatus.rewarded);
      },
    );
  }

  void _showRewardedVideo(
    void Function(RewardedAdStatus status) onStatus,
  ) {
    final ad = _rewardedAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onStatus(RewardedAdStatus.dismissed);
        _preloadNext();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onStatus(RewardedAdStatus.failed);
      },
    );
    ad.show(
      onUserEarnedReward: (ad, reward) {
        onStatus(RewardedAdStatus.rewarded);
      },
    );
  }

  void _preloadNext() {
    if (_primaryAdUnitId != null) {
      loadAd(
        primaryAdUnitId: _primaryAdUnitId!,
        fallbackAdUnitId: _fallbackAdUnitId,
        onStatus: (_) {},
      );
    }
  }

  void dispose() {
    _rewardedInterstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd = null;
    _rewardedAd = null;
  }
}
