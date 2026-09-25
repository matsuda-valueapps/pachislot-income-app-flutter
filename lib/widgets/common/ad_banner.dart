import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

///==================================================
/// 共通AdMobバナー
///==================================================
///
/// アプリ内の複数画面で共通利用する
/// Anchored Adaptive Banner Widget。
///
/// 基本構成：
///
/// AppBar
/// ↓
/// AdBanner
/// ↓
/// 既存コンテンツ
///
/// 開発・実機テスト時は
/// Google公式のテスト広告ユニットIDを使用する。
///
/// Releaseビルド時は
/// Android / iOSそれぞれの
/// 本番用AdMob広告ユニットIDを使用する。
///
/// なお、adUnitIdを明示的に指定した場合は、
/// その広告ユニットIDを優先して使用する。
///==================================================

class AdBanner extends StatefulWidget {
  const AdBanner({
    super.key,
    this.adUnitId,
  });

  /// 広告ユニットIDを明示的に指定する場合に使用する。
  ///
  /// nullの場合は、現在のビルド種別と
  /// OSに応じて以下を自動選択する。
  ///
  /// Debug / Profile：
  ///   Google公式テスト広告ユニットID
  ///
  /// Release：
  ///   Android / iOSの本番広告ユニットID
  final String? adUnitId;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  //==================================================
  // BannerAd
  //==================================================

  /// 読み込み中のBannerAd
  BannerAd? _bannerAd;

  /// Adaptive Bannerのサイズ
  AdSize? _adSize;

  /// 広告が正常に読み込まれたかどうか
  bool _isAdLoaded = false;

  /// 広告読み込み失敗時の状態。
  ///
  /// trueでも広告枠そのものは残す。
  /// これにより、広告読み込みによって
  /// アプリ本体が突然移動することを防ぐ。
  bool _hasLoadError = false;

  /// 広告枠の最低確保高さ。
  ///
  /// 一般的なスマートフォン向け
  /// Anchored Adaptive Bannerの表示領域を
  /// 確保するために使用する。
  static const double _reservedHeight = 50.0;

  //==================================================
  // Ad Unit ID
  //==================================================

  //==================================================
  // Android本番用バナー広告ID
  //==================================================

  static const String _androidProductionAdUnitId =
      'ca-app-pub-7409422327092258/6859024522';

  //==================================================
  // iOS本番用バナー広告ID
  //==================================================

  static const String _iosProductionAdUnitId =
      'ca-app-pub-7409422327092258/9390567526';

  //==================================================
  // Android公式テスト用バナー広告ID
  //==================================================

  static const String _androidTestAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  //==================================================
  // iOS公式テスト用バナー広告ID
  //==================================================

  static const String _iosTestAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  /// 現在のプラットフォームに応じた
  /// 本番広告ユニットIDを返す。
  String get _productionAdUnitId {
    if (Platform.isIOS) {
      return _iosProductionAdUnitId;
    }

    return _androidProductionAdUnitId;
  }

  /// 現在のプラットフォームに応じた
  /// テスト広告ユニットIDを返す。
  String get _testAdUnitId {
    if (Platform.isIOS) {
      return _iosTestAdUnitId;
    }

    return _androidTestAdUnitId;
  }

  /// 使用する広告ユニットID。
  ///
  /// 1.
  /// widget.adUnitIdが明示指定されている場合
  ///     → 指定されたIDを使用
  ///
  /// 2.
  /// Debug / Profileビルドの場合
  ///     → Google公式テストIDを使用
  ///
  /// 3.
  /// Releaseビルドの場合
  ///     → 本番用AdMob広告ユニットIDを使用
  String get _adUnitId {
    //================================================
    // 明示指定がある場合は最優先
    //================================================

    if (widget.adUnitId != null) {
      return widget.adUnitId!;
    }

    //================================================
    // Release以外はテスト広告を使用
    //================================================

    if (!kReleaseMode) {
      return _testAdUnitId;
    }

    //================================================
    // Releaseでは本番広告を使用
    //================================================

    return _productionAdUnitId;
  }

  //==================================================
  // Init
  //==================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //================================================
    // すでに広告作成済みの場合は何もしない。
    //================================================

    if (_bannerAd != null || _adSize != null) {
      return;
    }

    _loadAdaptiveBanner();
  }

  //==================================================
  // Adaptive Banner Load
  //==================================================

  /// Anchored Adaptive Bannerを読み込む。
  Future<void> _loadAdaptiveBanner() async {
    //================================================
    // 広告コンテナの横幅を取得
    //================================================

    final screenWidth = MediaQuery.sizeOf(context).width;

    //================================================
    // 幅が取得できない場合
    //================================================

    if (screenWidth <= 0) {
      return;
    }

    //================================================
    // Adaptive Bannerサイズ取得
    //================================================
    //
    // google_mobile_ads 5.3.1で使用可能な
    // 現在の向きに合わせたAdaptive Banner。
    //================================================

    final adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      screenWidth.truncate(),
    );

    //================================================
    // Widgetが破棄されている場合
    //================================================

    if (!mounted) {
      return;
    }

    //================================================
    // サイズ取得失敗
    //================================================

    if (adaptiveSize == null) {
      setState(() {
        _hasLoadError = true;
      });

      return;
    }

    //================================================
    // 以前のBannerAdが存在する場合
    //================================================

    _bannerAd?.dispose();

    //================================================
    // Adaptive Size保存
    //================================================

    _adSize = adaptiveSize;

    //================================================
    // BannerAd生成
    //================================================

    final bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: adaptiveSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        //============================================
        // 広告読み込み成功
        //============================================

        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
            _hasLoadError = false;
          });
        },

        //============================================
        // 広告読み込み失敗
        //============================================

        onAdFailedToLoad: (
          ad,
          error,
        ) {
          //==========================================
          // 失敗した広告を破棄
          //==========================================

          ad.dispose();

          if (!mounted) {
            return;
          }

          setState(() {
            _bannerAd = null;
            _isAdLoaded = false;
            _hasLoadError = true;
          });
        },

        //============================================
        // 広告クリック
        //============================================

        onAdClicked: (ad) {
          // 現時点では追加処理なし。
        },

        //============================================
        // 広告表示
        //============================================

        onAdOpened: (ad) {
          // 現時点では追加処理なし。
        },

        //============================================
        // 広告を閉じた
        //============================================

        onAdClosed: (ad) {
          // バナー広告では通常この処理は使用しない。
        },

        //============================================
        // インプレッション
        //============================================

        onAdImpression: (ad) {
          // 現時点では追加処理なし。
        },
      ),
    );

    //================================================
    // 広告読み込み開始
    //================================================

    bannerAd.load();
  }

  //==================================================
  // Dispose
  //==================================================

  @override
  void dispose() {
    _bannerAd?.dispose();

    _bannerAd = null;

    super.dispose();
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    //================================================
    // 広告高さ
    //================================================
    //
    // Adaptiveサイズ取得後は、
    // Googleが決定した広告高さを使用する。
    //
    // サイズ取得前は最低50pxを確保する。
    //
    // これにより広告読み込み前後で
    // アプリ本体が大きく移動するのを防ぐ。
    //================================================

    final height =
        _adSize?.height.toDouble() ??
        _reservedHeight;

    return Container(
      //================================================
      // 広告エリア
      //================================================
      //
      // アプリ本体とは独立した領域として扱う。
      //================================================

      width: double.infinity,

      height: height,

      alignment: Alignment.center,

      color: Colors.white,

      child: _buildAdContent(
        context,
      ),
    );
  }

  //==================================================
  // Ad Content
  //==================================================

  Widget _buildAdContent(
    BuildContext context,
  ) {
    //================================================
    // 広告読み込み済み
    //================================================

    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        width:
            _adSize?.width.toDouble() ??
            double.infinity,
        height:
            _adSize?.height.toDouble() ??
            _reservedHeight,
        child: AdWidget(
          ad: _bannerAd!,
        ),
      );
    }

    //================================================
    // 広告読み込み失敗
    //================================================
    //
    // 広告が表示されない場合でも、
    // 広告エリアそのものは確保する。
    //
    // これにより、広告が失敗した場合と
    // 成功した場合でアプリ本体の位置が
    // 大きく変化することを防ぐ。
    //================================================

    if (_hasLoadError) {
      return const SizedBox.expand();
    }

    //================================================
    // 読み込み中
    //================================================
    //
    // 広告枠だけを確保し、
    // アプリ本体のコンテンツは
    // 下へ確保した状態にする。
    //================================================

    return const SizedBox.expand();
  }
}