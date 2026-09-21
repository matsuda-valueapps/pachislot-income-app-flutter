import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../services/data_backup_service.dart';
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
  // Drawer
  //==================================================

  /// MainPageのScaffold用Key
  ///
  /// ハンバーガーメニューから
  /// Drawerを開閉するために使用する。
  final GlobalKey<ScaffoldState>
      _scaffoldKey =
      GlobalKey<ScaffoldState>();

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
  // Navigator Observer
  //==================================================

  /// 各タブNavigatorのRoute変更を監視する。
  ///
  /// 子画面へ遷移した場合：
  ///
  /// ハンバーガーメニューを非表示
  ///
  /// ルート画面へ戻った場合：
  ///
  /// ハンバーガーメニューを再表示
  ///
  /// とするために使用する。
  late final List<NavigatorObserver>
      _navigatorObservers;

  /// ハンバーガーメニューを表示するかどうか。
  ///
  /// true：
  /// 現在のタブがルート画面
  ///
  /// false：
  /// 現在のタブが子画面
  bool _showMenuButton = true;

  //==================================================
  // Lifecycle
  //==================================================

  @override
  void initState() {
    super.initState();

    //================================================
    // 各タブNavigatorのObserverを作成
    //================================================

    _navigatorObservers =
        List<NavigatorObserver>.generate(
      _navigatorKeys.length,
      (index) {
        return _MainTabNavigatorObserver(
          onRouteChanged:
              _scheduleMenuButtonUpdate,
        );
      },
    );
  }

  //==================================================
  // Drawer
  //==================================================

  /// Drawerを開く。
  void _openDrawer() {
    _scaffoldKey.currentState
        ?.openDrawer();
  }

  /// Drawerを閉じる。
  void _closeDrawer() {
    _scaffoldKey.currentState
        ?.closeDrawer();
  }

  //==================================================
  // Menu Button
  //==================================================

  /// ハンバーガーメニュー表示状態の更新を
  /// 次のフレームへ予約する。
  ///
  /// Navigatorのpush/pop直後に直接setState()を行うと、
  /// build中にStateが更新される可能性があるため、
  /// addPostFrameCallback()を使用する。
  void _scheduleMenuButtonUpdate() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _updateMenuButtonVisibility();
      },
    );
  }

  /// 現在選択されているタブのNavigator状態を確認し、
  /// ハンバーガーメニューの表示・非表示を更新する。
  void _updateMenuButtonVisibility() {
    if (!mounted) {
      return;
    }

    final navigator =
        _navigatorKeys[_selectedIndex]
            .currentState;

    //================================================
    // Navigatorがまだ取得できない場合
    //================================================
    //
    // 初期表示時などはNavigatorがまだ
    // 構築されていない可能性がある。
    //
    // その場合はハンバーガーを表示したままにする。
    //================================================

    final shouldShow =
        navigator == null ||
            !navigator.canPop();

    if (_showMenuButton ==
        shouldShow) {
      return;
    }

    setState(() {
      _showMenuButton =
          shouldShow;
    });
  }

  //==================================================
  // Backup
  //==================================================

  /// JSONバックアップを実行する。
  Future<void> _handleBackup() async {
    //================================================
    // Drawerを閉じる
    //================================================

    _closeDrawer();

    try {
      //================================================
      // バックアップ保存
      //================================================

      final path =
          await DataBackupService
              .instance
              .saveBackup();

      //================================================
      // キャンセル
      //================================================

      if (path == null) {
        return;
      }

      //================================================
      // State確認
      //================================================

      if (!mounted) {
        return;
      }

      //================================================
      // 保存成功
      //================================================

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'バックアップを保存しました。',
          ),
          duration:
              Duration(
            seconds: 3,
          ),
        ),
      );
    } catch (e) {
      //================================================
      // State確認
      //================================================

      if (!mounted) {
        return;
      }

      //================================================
      // 保存失敗
      //================================================

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            'バックアップに失敗しました。\n$e',
          ),
          duration:
              const Duration(
            seconds: 4,
          ),
        ),
      );
    }
  }

  //==================================================
  // Restore
  //==================================================

  /// JSONバックアップからデータを復元する。
  ///
  /// 復元前に確認ダイアログを表示し、
  /// ユーザーが明示的に「復元」を選択した場合のみ
  /// SQLiteデータを置き換える。
  Future<void> _handleRestore() async {
    //================================================
    // Drawerを閉じる
    //================================================

    _closeDrawer();

    try {
      //================================================
      // バックアップファイルを選択
      //================================================

      final json =
          await DataBackupService
              .instance
              .pickBackupJson();

      //================================================
      // キャンセル
      //================================================

      if (json == null) {
        return;
      }

      //================================================
      // State確認
      //================================================

      if (!mounted) {
        return;
      }

      //================================================
      // 復元確認
      //================================================
      //
      // JSONファイルを選択しただけでは、
      // SQLiteのデータは変更しない。
      //
      // 「復元」を選択した場合のみ、
      // restoreFromJson()を実行する。
      //================================================

      final shouldRestore =
          await DialogService.showConfirm(
        context: context,
        title: 'データを復元しますか？',
        message:
            '選択したバックアップの内容で、'
            '現在の「収支・メモ・小役カウンター」データを置き換えます。\n\n'
            '現在のデータは復元後の状態に戻せません。\n'
            '必要であれば、先に現在のデータをバックアップしてください。',
        confirmText: '復元',
      );

      //================================================
      // キャンセル
      //================================================

      if (!shouldRestore) {
        return;
      }

      //================================================
      // State確認
      //================================================

      if (!mounted) {
        return;
      }

      //================================================
      // 復元実行
      //================================================

      final result =
          await DataBackupService
              .instance
              .restoreFromJson(
        json,
      );

      //================================================
      // 復元後の画面を再読み込み
      //================================================
      //
      // 各Navigatorのルート画面を再生成することで、
      // 復元後のSQLiteデータを各画面へ反映する。
      //================================================

      _resetAllNavigators();

      //================================================
      // State確認
      //================================================

      if (!mounted) {
        return;
      }

      //================================================
      // 復元成功
      //================================================

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            'データを復元しました。\n'
            '収支 ${result.incomeCount}件 / '
            'メモ ${result.memoCount}件 / '
            'カウンター ${result.counterCount}件',
          ),
          duration:
              const Duration(
            seconds: 4,
          ),
        ),
      );
    } catch (e) {
      //================================================
      // State確認
      //================================================

      if (!mounted) {
        return;
      }

      //================================================
      // 復元失敗
      //================================================

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            '復元に失敗しました。\n$e',
          ),
          duration:
              const Duration(
            seconds: 5,
          ),
        ),
      );
    }
  }

  //==================================================
  // Restore / Reload
  //==================================================

  /// 復元後、全タブのルート画面を再生成する。
  ///
  /// IndexedStackは各Navigatorの状態を保持するため、
  /// DBを復元しただけでは表示中の画面が
  /// 古いデータを保持している可能性がある。
  ///
  /// そこで各Navigatorのルート画面を再生成し、
  /// 復元後のSQLiteデータを各画面へ反映する。
  void _resetAllNavigators() {
    //================================================
    // HomeProviderを現在年月へ戻す
    //================================================

    final provider =
        context.read<HomeProvider>();

    provider.resetToCurrentMonth();

    //================================================
    // BottomNavigationの履歴をクリア
    //================================================

    _tabHistory.clear();

    //================================================
    // ホームを選択
    //================================================

    _selectedIndex = 0;

    //================================================
    // 全Navigatorを再生成
    //================================================

    for (
      var index = 0;
      index < _navigatorKeys.length;
      index++
    ) {
      final navigator =
          _navigatorKeys[index]
              .currentState;

      if (navigator == null) {
        continue;
      }

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              _buildRootPage(
            index,
          ),
        ),
        (route) => false,
      );
    }

    //================================================
    // State更新
    //================================================

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = 0;
    });

    _scheduleMenuButtonUpdate();
  }

  /// 指定されたタブのルート画面を作成する。
  Widget _buildRootPage(
    int index,
  ) {
    switch (index) {
      //================================================
      // ホーム
      //================================================

      case 0:
        return HomePage(
          key: UniqueKey(),
        );

      //================================================
      // 入力
      //================================================

      case 1:
        return const InputPage();

      //================================================
      // メモ
      //================================================

      case 2:
        return const MemoPage();

      //================================================
      // 小役
      //================================================

      case 3:
        return const CounterPage();

      //================================================
      // 検索
      //================================================

      case 4:
        return const SearchPage();

      //================================================
      // その他
      //================================================

      default:
        return const HomePage();
    }
  }

  //==================================================
  // Drawer
  //==================================================

  /// ハンバーガーメニューのDrawerを作成する。
  Widget _buildDrawer(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding:
              EdgeInsets.zero,
          children: [
            //================================================
            // Drawer Header
            //================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                24,
              ),
              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    colorScheme
                        .surface,
                    colorScheme
                        .surfaceContainerHighest,
                  ],
                ),
                border: Border(
                  bottom:
                      BorderSide(
                    color: colorScheme
                        .outlineVariant
                        .withValues(
                          alpha: 0.45,
                        ),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  //============================================
                  // メニューアイコン
                  //============================================

                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color: colorScheme
                          .primary
                          .withValues(
                            alpha: 0.10,
                          ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .settings_rounded,
                      color: colorScheme
                          .primary,
                      size: 26,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  //============================================
                  // アプリ名
                  //============================================

                  Text(
                    'パチスロ収支',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.w900,
                      color:
                          colorScheme
                              .onSurface,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'メニュー',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color:
                          colorScheme
                              .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            //================================================
            // データ管理
            //================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                8,
              ),
              child: Text(
                'データ管理',
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                  color:
                      colorScheme
                          .primary,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),

            //================================================
            // バックアップ
            //================================================

            ListTile(
              leading: Icon(
                Icons
                    .backup_rounded,
                color:
                    colorScheme.primary,
              ),
              title: Text(
                'バックアップ',
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              subtitle:
                  const Text(
                '収支・メモ・小役カウンターデータを保存',
              ),
              trailing:
                  const Icon(
                Icons
                    .chevron_right_rounded,
              ),
              onTap:
                  _handleBackup,
            ),

            //================================================
            // 復元
            //================================================

            ListTile(
              leading: Icon(
                Icons
                    .restore_rounded,
                color:
                    colorScheme.primary,
              ),
              title: Text(
                '復元',
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              subtitle:
                  const Text(
                'JSONバックアップからデータを復元',
              ),
              trailing:
                  const Icon(
                Icons
                    .chevron_right_rounded,
              ),
              onTap:
                  _handleRestore,
            ),

            //================================================
            // 区切り
            //================================================

            const Divider(
              height: 32,
            ),

            //================================================
            // Drawerを閉じる
            //================================================

            ListTile(
              leading: const Icon(
                Icons
                    .close_rounded,
              ),
              title: Text(
                '閉じる',
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              onTap:
                  _closeDrawer,
            ),
          ],
        ),
      ),
    );
  }

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

    _scheduleMenuButtonUpdate();
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

    _scheduleMenuButtonUpdate();

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

    _scheduleMenuButtonUpdate();
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

      _scheduleMenuButtonUpdate();

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

      _scheduleMenuButtonUpdate();

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

    _scheduleMenuButtonUpdate();
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
  /// ① Drawerが開いている
  ///    ↓
  ///    Drawerを閉じる
  ///
  /// ② 現在タブの子画面がある
  ///    ↓
  ///    子画面を1つ戻る
  ///
  /// ③ 現在タブがルート画面
  ///    ↓
  ///    BottomNavigationの直前のタブへ戻る
  ///
  /// ④ 現在タブがホーム以外で、
  ///    タブ履歴がない
  ///    ↓
  ///    ホームへ戻る
  ///
  /// ⑤ ホームのルート画面で、
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
    // Drawerが開いている場合
    //================================================
    //
    // Drawer表示中のAndroid戻るは、
    // タブ移動やアプリ終了よりも先に
    // Drawerを閉じる。
    //================================================

    if (_scaffoldKey.currentState
            ?.isDrawerOpen ??
        false) {
      _closeDrawer();
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
      _scheduleMenuButtonUpdate();
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
      // Navigator Observer
      //================================================
      //
      // このNavigatorで、
      //
      // ・push
      // ・pop
      // ・remove
      // ・replace
      //
      // が発生した場合に、
      // ハンバーガーメニューの表示状態を更新する。
      //================================================

      observers: [
        _navigatorObservers[index],
      ],

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
      // ・Drawer
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
        // Scaffold Key
        //================================================

        key: _scaffoldKey,

        //================================================
        // Drawer
        //================================================
        //
        // ハンバーガーメニューの本体。
        //
        // BottomNavigationには追加せず、
        // 日常操作とデータ管理機能を分離する。
        //================================================

        drawer: _buildDrawer(
          context,
        ),

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

        body: Stack(
          children: [
            IndexedStack(
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
            // ハンバーガーボタン
            //================================================
            //
            // 現在のタブがルート画面の場合のみ表示する。
            //
            // 子画面へ遷移すると、
            // NavigatorObserverによって
            // _showMenuButtonがfalseになり、
            // このボタンは非表示になる。
            //
            // これにより、
            //
            // 収支DATA一覧
            // メモDATA一覧
            // 小役DATA一覧
            //
            // などの子画面にある「←戻る」と
            // ハンバーガーメニューが重ならない。
            //================================================

            if (_showMenuButton)
              Positioned(
                top:
                    MediaQuery.of(
                          context,
                        ).padding.top +
                        8,
                left: 8,
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    onTap:
                        _openDrawer,
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
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
          // 選択中・非選択時ともに
          // FontWeight.w900を使用する。
          //
          // さらにShadowを複数方向へ重ねることで、
          // 文字の外周を擬似的に太くする。
          //
          // ・選択中
          //     w900
          //     ＋ 強めの疑似ストローク
          //
          // ・非選択時
          //     w900
          //     ＋ 弱めの疑似ストローク
          //
          // そのため、
          //
          //     選択中 ＞ 非選択時
          //
          // の太さになる。
          //
          // 文字サイズ・色・アイコン・
          // NavigationBarの構造は変更しない。
          //================================================

          labelTextStyle:
              WidgetStateProperty.resolveWith<
                  TextStyle?>(
            (states) {
              final baseStyle =
                  Theme.of(context)
                      .textTheme
                      .labelMedium;

              final isSelected =
                  states.contains(
                WidgetState.selected,
              );

              final labelColor =
                  isSelected
                      ? const Color(0xFF0D47A1)
                      : const Color(0xFF2962FF);

              //================================================
              // 疑似ストロークの太さ
              //================================================
              //
              // 選択中を非選択時より少し太くする。
              //================================================

              final thickness =
                  isSelected ? 0.50 : 0.22;

              return baseStyle?.copyWith(
                color: labelColor,
                //================================================
                // フォント自体は両方ともw900
                //================================================

                fontWeight:
                    FontWeight.w900,

                //================================================
                // 文字の外周を8方向へ重ねて
                // 実質的に文字を太く見せる。
                //================================================

                shadows: [
                  Shadow(
                    color: labelColor,
                    offset: Offset(
                      thickness,
                      0,
                    ),
                    blurRadius: 0,
                  ),
                  Shadow(
                    color: labelColor,
                    offset: Offset(
                      -thickness,
                      0,
                    ),
                    blurRadius: 0,
                  ),
                  Shadow(
                    color: labelColor,
                    offset: Offset(
                      0,
                      thickness,
                    ),
                    blurRadius: 0,
                  ),
                  Shadow(
                    color: labelColor,
                    offset: Offset(
                      0,
                      -thickness,
                    ),
                    blurRadius: 0,
                  ),
                  Shadow(
                    color: labelColor,
                    offset: Offset(
                      thickness,
                      thickness,
                    ),
                    blurRadius: 0,
                  ),
                  Shadow(
                    color: labelColor,
                    offset: Offset(
                      -thickness,
                      -thickness,
                    ),
                    blurRadius: 0,
                  ),
                  Shadow(
                    color: labelColor,
                    offset: Offset(
                      thickness,
                      -thickness,
                    ),
                    blurRadius: 0,
                  ),
                  Shadow(
                    color: labelColor,
                    offset: Offset(
                      -thickness,
                      thickness,
                    ),
                    blurRadius: 0,
                  ),
                ],
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
              label: '収支入力',
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

//==================================================
// Navigator Observer
//==================================================

/// タブNavigatorのRoute変更を検知するObserver。
///
/// 子画面へpushされた場合や、
/// 子画面からpopしてルートへ戻った場合に、
/// MainPageへ通知する。
class _MainTabNavigatorObserver
    extends NavigatorObserver {
  final VoidCallback onRouteChanged;

  _MainTabNavigatorObserver({
    required this.onRouteChanged,
  });

  @override
  void didPush(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    onRouteChanged();
  }

  @override
  void didPop(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    onRouteChanged();
  }

  @override
  void didRemove(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    onRouteChanged();
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    onRouteChanged();
  }
}