import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../services/dialog_service.dart';
import '../widgets/common/bottomnavigation_icon.dart';
import 'counter_page.dart';
import 'home_page.dart';
import 'input_page.dart';
import 'memo_page.dart';
import 'search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() =>
      _MainPageState();
}

class _MainPageState
    extends State<MainPage> {
  //==================================================
  // BottomNavigation
  //==================================================

  /// 現在選択されているBottomNavigationのIndex
  int _selectedIndex = 0;

  /// BottomNavigationの移動履歴
  ///
  /// 例：
  ///
  /// ホーム
  /// ↓
  /// 入力
  /// ↓
  /// メモ
  ///
  /// この場合、
  ///
  /// [_tabHistory] = [0, 1]
  ///
  /// となる。
  ///
  /// Android戻るを押すと、
  ///
  /// メモ
  /// ↓
  /// 入力
  ///
  /// へ戻る。
  final List<int> _tabHistory = [];

  /// アプリ終了確認ダイアログが
  /// 現在表示中かどうか。
  ///
  /// Androidの戻る操作が短時間に複数回発生した場合に、
  /// ダイアログが重複表示されることを防ぐ。
  bool _isExitDialogShowing = false;

  /// 各タブ専用NavigatorのKey
  ///
  /// 各タブごとに独立したNavigatorを持たせることで、
  /// 子画面へ遷移してもMainPageのBottomNavigationを
  /// 常時表示できるようにする。
  final List<GlobalKey<NavigatorState>>
      _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  //==================================================
  // Home Navigator
  //==================================================

  /// ホームタブを現在年月＋今日の選択状態へ戻す。
  ///
  /// ホームタブ内で、
  ///
  /// HomePage
  /// ↓
  /// InputPage
  /// ↓
  /// IncomeDetailPage
  ///
  /// などの子画面へ進んでいた場合も、
  /// すべて閉じてHomePageへ戻す。
  void _resetHomeNavigator() {
    final provider =
        context.read<HomeProvider>();

    //================================================
    // HomeProviderの表示年月を現在年月へ戻す
    //================================================

    provider.resetToCurrentMonth();

    //================================================
    // Home Navigatorを取得
    //================================================

    final navigator =
        _navigatorKeys[0].currentState;

    if (navigator == null) {
      return;
    }

    //================================================
    // HomePageを再生成
    //================================================
    //
    // HomePageを再生成することで、
    // CalendarCardも再生成される。
    //
    // CalendarCardのinitState()により、
    // 現在年月の場合は今日が選択状態になる。
    //================================================

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            HomePage(
          key: UniqueKey(),
        ),
      ),
      (route) => false,
    );
  }

  //==================================================
  // Tab History
  //==================================================

  /// BottomNavigationのタブ履歴へ追加する。
  ///
  /// 同じタブを連続して追加しない。
  void _addTabHistory(
    int index,
  ) {
    if (_tabHistory.isNotEmpty &&
        _tabHistory.last == index) {
      return;
    }

    _tabHistory.add(index);
  }

  /// 直前のBottomNavigationタブへ戻る。
  ///
  /// 戻るタブが存在する場合はtrue。
  ///
  /// 戻るタブが存在しない場合はfalse。
  bool _popTabHistory() {
    if (_tabHistory.isEmpty) {
      return false;
    }

    final previousIndex =
        _tabHistory.removeLast();

    if (!mounted) {
      return true;
    }

    setState(() {
      _selectedIndex =
          previousIndex;
    });

    return true;
  }

  //==================================================
  // Homeへ戻る
  //==================================================

  /// BottomNavigation履歴に関係なく、
  /// ホームへ戻す。
  ///
  /// 現在のホームNavigatorに子画面が残っている場合も
  /// すべて閉じる。
  void _goHome() {
    if (!mounted) {
      return;
    }

    //================================================
    // Home Navigatorを現在年月へリセット
    //================================================

    _resetHomeNavigator();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = 0;
    });
  }

  //==================================================
  // BottomNavigation
  //==================================================

  /// BottomNavigationのタップ処理
  void _onItemTapped(
    int index,
  ) {
    //================================================
    // 現在と同じタブ
    //================================================

    if (_selectedIndex == index) {
      // 同じタブを再度タップした場合は、
      // そのタブのNavigatorをルート画面まで戻す。
      //
      // 例：
      //
      // ホーム
      // ↓
      // 収支詳細
      // ↓
      // 編集
      //
      // ホームを再度タップ
      // ↓
      // HomePage
      final navigator =
          _navigatorKeys[index]
              .currentState;

      navigator?.popUntil(
        (route) => route.isFirst,
      );

      // ホームの場合は、
      // 現在年月＋今日へ戻す。
      if (index == 0) {
        _resetHomeNavigator();
      }

      return;
    }

    //================================================
    // ホームへ移動
    //================================================

    if (index == 0) {
      // 現在のタブを履歴へ保存する。
      _addTabHistory(
        _selectedIndex,
      );

      // ホームへ戻る場合は、
      // 現在年月＋今日へ戻す。
      _resetHomeNavigator();

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedIndex = 0;
      });

      return;
    }

    //================================================
    // その他のタブへ移動
    //================================================

    // 現在のタブを履歴へ保存する。
    _addTabHistory(
      _selectedIndex,
    );

    setState(() {
      _selectedIndex = index;
    });
  }

  //==================================================
  // Android / Exit Dialog
  //==================================================

  /// アプリ終了確認ダイアログを表示する。
  ///
  /// HomePageで使用している
  /// DialogService.showConfirm()を使用することで、
  /// 他の確認ダイアログとUIを統一する。
  ///
  /// 「キャンセル」
  ///     ↓
  /// 現在の画面に留まる。
  ///
  /// 「終了」
  ///     ↓
  /// アプリを終了する。
  Future<void>
      _showExitConfirmationDialog() async {
    //================================================
    // すでにダイアログ表示中の場合
    //================================================

    if (_isExitDialogShowing) {
      return;
    }

    //================================================
    // Stateが有効か確認
    //================================================

    if (!mounted) {
      return;
    }

    //================================================
    // ダイアログ表示中フラグ
    //================================================

    _isExitDialogShowing = true;

    //================================================
    // 共通確認ダイアログを表示
    //================================================
    //
    // HomePageの、
    //
    // DialogService.showConfirm()
    //
    // と同じ処理を使用する。
    //
    // これにより、
    //
    // ・角丸
    // ・背景
    // ・タイトル
    // ・本文
    // ・キャンセルボタン
    // ・確定ボタン
    //
    // などのUIを統一できる。
    //================================================

    final shouldExit =
        await DialogService.showConfirm(
      context: context,
      title: 'アプリを終了しますか？',
      message:
          '「終了」を選択すると、現在のアプリ画面は閉じます。',
      confirmText: '終了',
    );

    //================================================
    // ダイアログ表示中フラグを解除
    //================================================

    _isExitDialogShowing = false;

    //================================================
    // Stateが有効か確認
    //================================================

    if (!mounted) {
      return;
    }

    //================================================
    // アプリ終了
    //================================================
    //
    // 「終了」が選択された場合のみ、
    // Androidアプリを終了する。
    //================================================

    if (shouldExit) {
      if (Theme.of(context).platform ==
          TargetPlatform.android) {
        SystemNavigator.pop();
      }
    }
  }

  //==================================================
  // Android / System Back
  //==================================================

  /// Androidの戻るボタン・システムBack処理
  ///
  /// 戻る順序：
  ///
  /// ① 現在タブの子画面がある
  ///    ↓
  ///    子画面を1つ戻る
  ///
  /// ② 現在タブがルート画面
  ///    ↓
  ///    BottomNavigationの直前のタブへ戻る
  ///
  /// ③ 現在タブがホーム以外で、
  ///    タブ履歴がない
  ///    ↓
  ///    ホームへ戻る
  ///
  /// ④ ホームのルート画面で、
  ///    タブ履歴もない
  ///    ↓
  ///    「アプリを終了しますか？」を表示
  ///
  ///    ↓
  ///    キャンセル
  ///        → 現在画面に留まる
  ///
  ///    ↓
  ///    終了
  ///        → アプリ終了
  void _handlePopInvoked(
    bool didPop,
  ) {
    //================================================
    // すでにPop処理が完了している場合
    //================================================

    if (didPop) {
      return;
    }

    //================================================
    // 現在のタブのNavigator
    //================================================

    final navigator =
        _navigatorKeys[_selectedIndex]
            .currentState;

    //================================================
    // ① 現在のタブに子画面がある場合
    //================================================
    //
    // 例：
    //
    // HomePage
    // ↓
    // IncomeDetailPage
    //
    // Android戻る
    // ↓
    // HomePage
    //
    // また、
    //
    // HomePage
    // ↓
    // IncomeDetailPage
    // ↓
    // InputPage
    //
    // Android戻る
    // ↓
    // IncomeDetailPage
    //
    // となる。
    //==================================================

    if (navigator != null &&
        navigator.canPop()) {
      navigator.pop();
      return;
    }

    //================================================
    // ② BottomNavigationの直前のタブへ戻る
    //================================================

    if (_popTabHistory()) {
      return;
    }

    //================================================
    // ③ ホーム以外のタブで履歴がない場合
    //================================================
    //
    // このケースでは、
    // いきなりアプリを終了させない。
    //
    // 既存仕様どおり、
    // ホームへ戻す。
    //================================================

    if (_selectedIndex != 0) {
      _goHome();
      return;
    }

    //================================================
    // ④ ホームのルート画面
    //================================================
    //
    // ここまで戻ってきた場合は、
    // これ以上戻る画面が存在しない。
    //
    // Android 16などでBack処理が想定外に
    // アプリ終了へ進んでしまうケースに備え、
    // ここでは直接SystemNavigator.pop()せず、
    // 必ず終了確認ダイアログを表示する。
    //================================================

    if (Theme.of(context).platform ==
        TargetPlatform.android) {
      _showExitConfirmationDialog();
    }
  }

  //==================================================
  // Navigator
  //==================================================

  /// 指定されたタブのNavigatorを作成する。
  Widget _buildNavigator(
    int index,
  ) {
    return Navigator(
      key: _navigatorKeys[index],

      //================================================
      // 初期Route
      //================================================

      onGenerateRoute: (
        settings,
      ) {
        Widget page;

        switch (index) {
          //================================================
          // ホーム
          //================================================

          case 0:
            page = const HomePage();
            break;

          //================================================
          // 入力
          //================================================

          case 1:
            page = const InputPage();
            break;

          //================================================
          // メモ
          //================================================

          case 2:
            page = const MemoPage();
            break;

          //================================================
          // 小役
          //================================================

          case 3:
            page = const CounterPage();
            break;

          //================================================
          // 検索
          //================================================

          case 4:
            page = const SearchPage();
            break;

          //================================================
          // その他
          //================================================

          default:
            page = const HomePage();
        }

        return MaterialPageRoute(
          builder: (context) =>
              page,
          settings: settings,
        );
      },
    );
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return PopScope(
      //================================================
      // PopScope
      //================================================
      //
      // 常にfalseにする。
      //
      // MainPageがAndroidの戻る操作を受け取り、
      // _handlePopInvoked()で、
      //
      // ・子Navigator
      // ・BottomNavigation履歴
      // ・ホームへのフォールバック
      // ・アプリ終了確認ダイアログ
      //
      // の順番を制御する。
      //
      // canPop: false にすることで、
      // AndroidのBack操作によってMainPage自身が
      // 直接popされてアプリ終了することを防ぐ。
      //================================================

      canPop: false,

      onPopInvokedWithResult: (
        didPop,
        result,
      ) {
        _handlePopInvoked(
          didPop,
        );
      },

      child: Scaffold(
        //================================================
        // タブ画面
        //================================================
        //
        // IndexedStackを使用することで、
        // タブを切り替えても各Navigatorの状態を維持する。
        //
        // 例えば、
        //
        // ホーム
        // ↓
        // 7月を表示
        // ↓
        // 入力タブへ移動
        // ↓
        // ホームへ戻る
        //
        // としても、各Navigator自体は維持される。
        //
        // ホームへ戻る操作時には
        // _resetHomeNavigator()によって
        // 明示的に現在月へ戻す。
        //================================================

        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildNavigator(0),
            _buildNavigator(1),
            _buildNavigator(2),
            _buildNavigator(3),
            _buildNavigator(4),
          ],
        ),

        //================================================
        // Bottom Navigation
        //================================================
        //
        // MainPageのScaffoldに固定されているため、
        // 各Navigator内でNavigator.push()して
        // 子画面へ移動しても消えない。
        //================================================

        bottomNavigationBar:
            NavigationBar(
          selectedIndex:
              _selectedIndex,

          onDestinationSelected:
              _onItemTapped,

          //================================================
          // ラベル文字スタイル
          //================================================
          //
          // 選択中のBottomNavigationラベルだけを
          // 太字で表示する。
          //
          // 未選択：
          //   FontWeight.normal
          //
          // 選択中：
          //   FontWeight.bold
          //
          // アイコン・選択背景・文字サイズなど、
          // 既存のNavigationBarデザインは変更しない。
          //================================================

          labelTextStyle:
              WidgetStateProperty.resolveWith<
                  TextStyle?>(
            (states) {
              final baseStyle =
                  Theme.of(context)
                      .textTheme
                      .labelMedium;

              return baseStyle?.copyWith(
                fontWeight:
                    states.contains(
                  WidgetState.selected,
                )
                        ? FontWeight.bold
                        : FontWeight.normal,
              );
            },
          ),

          destinations: const [
            //================================================
            // ホーム
            //================================================

            NavigationDestination(
              icon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .home,
              ),
              selectedIcon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .home,
              ),
              label: 'ホーム',
            ),

            //================================================
            // 入力
            //================================================

            NavigationDestination(
              icon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .input,
              ),
              selectedIcon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .input,
              ),
              label: '入力',
            ),

            //================================================
            // メモ
            //================================================

            NavigationDestination(
              icon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .memo,
              ),
              selectedIcon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .memo,
              ),
              label: 'メモ',
            ),

            //================================================
            // 小役
            //================================================

            NavigationDestination(
              icon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .counter,
              ),
              selectedIcon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .counter,
              ),
              label: 'カウンター',
            ),

            //================================================
            // 検索
            //================================================

            NavigationDestination(
              icon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .search,
              ),
              selectedIcon:
                  BottomNavigationIcon(
                type:
                    BottomNavigationIconType
                        .search,
              ),
              label: '検索',
            ),
          ],
        ),
      ),
    );
  }
}