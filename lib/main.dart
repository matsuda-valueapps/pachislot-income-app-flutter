import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'pages/main_page.dart';
import 'providers/calculator_provider.dart';
import 'providers/counter_provider.dart';
import 'providers/home_provider.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PachislotIncomeApp());
}

class PachislotIncomeApp extends StatelessWidget {
  const PachislotIncomeApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        locale: const Locale('ja', 'JP'),

        supportedLocales: const [
          Locale('ja', 'JP'),
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