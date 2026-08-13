import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import 'counter_page.dart';
import 'home_page.dart';
import 'input_page.dart';
import 'memo_page.dart';
import 'search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() =>
      _MainPageState();
}

class _MainPageState
    extends State<MainPage> {
  /// 現在選択されているBottomNavigationのIndex
  int _selectedIndex = 0;

  /// 各画面
  ///
  /// HomePageはホームへ戻った際に
  /// 再生成できるよう、変更可能なListにする。
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const HomePage(),
      const InputPage(),
      const MemoPage(),
      const CounterPage(),
      const SearchPage(),
    ];
  }

  //==================================================
  // BottomNavigation
  //==================================================

  /// BottomNavigationのタップ処理
  void _onItemTapped(int index) {
    //================================================
    // ホームへ戻る場合
    //================================================

    if (index == 0 &&
        _selectedIndex != 0) {
      final provider =
          context.read<HomeProvider>();

      // 現在年月へ戻す。
      //
      // 例：
      // 2026年7月表示
      //     ↓
      // 2026年8月表示
      provider.resetToCurrentMonth();

      setState(() {
        // HomePageを再生成する。
        //
        // CalendarCardも再生成されるため、
        // 現在年月の場合は今日が選択状態になる。
        _pages[0] = HomePage(
          key: UniqueKey(),
        );

        _selectedIndex = 0;
      });

      return;
    }

    //================================================
    // その他の画面
    //================================================

    setState(() {
      _selectedIndex = index;
    });
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      //================================================
      // Bottom Navigation
      //================================================

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            _selectedIndex,

        onDestinationSelected:
            _onItemTapped,

        destinations: const [

          //================================================
          // ホーム
          //================================================

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'ホーム',
          ),

          //================================================
          // 入力
          //================================================

          NavigationDestination(
            icon: Icon(
              Icons.edit_note_outlined,
            ),
            selectedIcon: Icon(
              Icons.edit_note,
            ),
            label: '入力',
          ),

          //================================================
          // メモ
          //================================================

          NavigationDestination(
            icon: Icon(
              Icons.description_outlined,
            ),
            selectedIcon: Icon(
              Icons.description,
            ),
            label: 'メモ',
          ),

          //================================================
          // 小役
          //================================================

          NavigationDestination(
            icon: Icon(
              Icons.calculate_outlined,
            ),
            selectedIcon: Icon(
              Icons.calculate,
            ),
            label: '小役',
          ),

          //================================================
          // 検索
          //================================================

          NavigationDestination(
            icon: Icon(
              Icons.search_outlined,
            ),
            selectedIcon: Icon(
              Icons.search,
            ),
            label: '検索',
          ),
        ],
      ),
    );
  }
}