import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'pages/main_page.dart';
import 'providers/calculator_provider.dart';
import 'providers/counter_provider.dart';
import 'providers/home_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  //==================================================
  // Flutter初期化
  //==================================================

  WidgetsFlutterBinding.ensureInitialized();

  //==================================================
  // アプリ起動
  //==================================================
  //
  // AdMobの初期化完了を待たずに、
  // 先にアプリ画面の表示を開始する。
  //
  //==================================================

  runApp(
    const PachislotIncomeApp(),
  );

  //==================================================
  // Google Mobile Ads 初期化
  //==================================================
  //
  // アプリ画面の表示開始後にAdMobを初期化する。
  //
  // 初期化完了を待たずに処理を進めることで、
  // AdMobの初期化時間が画面表示開始を直接遅らせない
  // 構成にする。
  //
  //==================================================

  MobileAds.instance.initialize().then((_) {
    // AdMob初期化完了
  }).catchError((Object error) {
    // AdMob初期化失敗時のエラー処理
    debugPrint(
      '[AdMob] Initialization failed: $error',
    );
  });
}

class PachislotIncomeApp extends StatelessWidget {
  const PachislotIncomeApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MultiProvider(
      providers: [
        // ==========================================
        // 電卓
        // ==========================================

        ChangeNotifierProvider(
          create: (_) => CalculatorProvider(),
        ),

        // ==========================================
        // 小役カウンター
        // ==========================================

        ChangeNotifierProvider(
          create: (_) => CounterProvider(),
        ),

        // ==========================================
        // ホーム画面
        // ==========================================

        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'パチスロ収支表',

        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,

        // 日本語ロケール対応
        locale: const Locale(
          'ja',
          'JP',
        ),

        supportedLocales: const [
          Locale(
            'ja',
            'JP',
          ),
        ],

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        home: const MainPage(),
      ),
    );
  }
}