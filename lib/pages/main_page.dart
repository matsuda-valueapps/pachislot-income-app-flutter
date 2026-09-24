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
    extends State<MainPage>
    with WidgetsBindingObserver {
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

  //==================================================
  // App Lifecycle
  //==================================================

  /// アプリがバックグラウンドへ移動したあと、
  /// 再び前面へ戻ったかどうか。
  ///
  /// 検索画面からYouTubeなどの外部アプリを開いた場合、
  /// Flutterアプリはいったん非アクティブになります。
  ///
  /// その後Androidの戻るボタンでアプリへ戻った際に、
  /// 検索画面をトップへ戻すために使用する。
  bool _shouldResetSearchOnResume =
      false;

  //==================================================
  // Navigator
  //==================================================

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
  // Tab Scroll Controller
  //==================================================

  /// 各タブのルート画面用ScrollController。
  ///
  /// ・メモDATA入力
  /// ・小役カウンター
  /// ・検索
  ///
  /// のルート画面がPrimaryScrollControllerを使用する場合、
  /// MainPage側からスクロール位置をトップへ戻すために使用する。
  ///
  /// 収支DATA入力についてはInputPageStateの
  /// scrollToTop()を使用するため、
  /// こちらのControllerは直接使用しない。
  final List<ScrollController>
      _tabScrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];

  //==================================================
  // Input Page Key
  //==================================================

  /// 収支DATA入力画面のStateへアクセスするためのKey。
  ///
  /// InputPageState.scrollToTop()を
  /// MainPageから呼び出すために使用する。
  GlobalKey<InputPageState>
      _inputPageKey =
      GlobalKey<InputPageState>();

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
    // App Lifecycle Observer
    //================================================

    WidgetsBinding.instance
        .addObserver(this);

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
          onRoutePopped: () =>
              _handleNavigatorRoutePopped(index),
        );
      },
    );
  }

  @override
  void dispose() {
    //================================================
    // App Lifecycle Observer解除
    //================================================

    WidgetsBinding.instance
        .removeObserver(this);

    //================================================
    // Tab ScrollController破棄
    //================================================

    for (final controller
        in _tabScrollControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  //==================================================
  // App Lifecycle
  //==================================================

  /// アプリのライフサイクル変更を監視する。
  ///
  /// 検索画面からYouTubeなどの外部アプリを開いた場合、
  ///
  /// 検索
  /// ↓
  /// YouTube
  ///
  /// となり、Flutterアプリは一度バックグラウンドへ
  /// 移動する。
  ///
  /// その後、
  ///
  /// YouTube
  /// ↓ Android戻る
  /// 検索
  ///
  /// と戻ってきたタイミングで、
  /// 検索画面をトップへ戻す。
  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    super.didChangeAppLifecycleState(
      state,
    );

    //================================================
    // アプリが非アクティブになった
    //================================================
    //
    // 外部アプリ起動やバックグラウンド移行を検知する。
    //================================================

    if (state ==
            AppLifecycleState.inactive ||
        state ==
            AppLifecycleState.paused) {
      _shouldResetSearchOnResume =
          true;
      return;
    }

    //================================================
    // アプリが再び前面へ戻った
    //================================================

    if (state ==
            AppLifecycleState.resumed &&
        _shouldResetSearchOnResume) {
      _shouldResetSearchOnResume =
          false;

      //================================================
      // 検索タブの場合のみ
      // トップへ戻す。
      //================================================

      if (_selectedIndex == 4) {
        _resetTabScrollPosition(4);
      }
    }
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
  // Tab Scroll Reset
  //==================================================

  /// 指定されたタブのルート画面を
  /// スクロールトップへ戻す。
  ///
  /// ホームは既存の
  /// _resetHomeNavigator()
  /// を使用する。
  ///
  /// 収支DATA入力は、
  /// InputPageState.scrollToTop()
  /// を使用する。
  ///
  /// メモ・小役・検索は、
  /// PrimaryScrollControllerへ接続された
  /// ScrollControllerを使用する。
  void _resetTabScrollPosition(
    int index,
  ) {
    //================================================
    // ホーム
    //================================================
    //
    // ホームは既存仕様どおり、
    // HomePageを再生成する。
    //================================================

    if (index == 0) {
      return;
    }

    //================================================
    // 次のフレームで実行
    //================================================
    //
    // BottomNavigation切り替え直後や、
    // Navigator.pop()直後は、
    // 対象画面のWidget構築が完了していない
    // 可能性があるため、
    // addPostFrameCallback()を使用する。
    //================================================

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        //================================================
        // 収支DATA入力
        //================================================

        if (index == 1) {
          _inputPageKey.currentState
              ?.scrollToTop();

          return;
        }

        //================================================
        // メモ / 小役 / 検索
        //================================================

        final controller =
            _tabScrollControllers[
                index];

        if (!controller.hasClients) {
          return;
        }

        controller.jumpTo(
          controller.position
              .minScrollExtent,
        );
      },
    );
  }

  //==================================================
  // Child Route Back Scroll Reset
  //==================================================

  /// 子画面からAndroid戻るで
  /// タブのルート画面へ戻った場合に、
  /// そのルート画面をトップへ戻す。
  ///
  /// 重要：
  ///
  /// Navigatorを追加でpopすることはしない。
  ///
  /// すでに実行された1回のpop後に、
  /// Navigatorがルート画面になったかだけを確認する。
  void _resetScrollAfterChildPop(
    int index,
  ) {
    //================================================
    // 今回トップへ戻したい対象タブ
    //================================================
    //
    // 収支入力については、
    // 編集 → 詳細 → 一覧 → ホーム
    // などの既存Navigator階層を
    // 絶対に壊さないため、
    // ここでは対象外とする。
    //================================================

    if (index != 2 &&
        index != 3 &&
        index != 4) {
      return;
    }

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        final currentNavigator =
            _navigatorKeys[index]
                .currentState;

        if (currentNavigator == null) {
          return;
        }

        //================================================
        // まだ子画面が残っている場合
        //================================================
        //
        // 例：
        //
        // メモDATA一覧
        // ↓
        // メモDATA詳細
        //
        // 詳細から戻って一覧になっただけなら、
        // まだcanPop() == trueなので
        // スクロールリセットしない。
        //================================================

        if (currentNavigator
            .canPop()) {
          return;
        }

        //================================================
        // ルート画面へ戻った場合のみ
        // トップへ戻す。
        //================================================

        _resetTabScrollPosition(
          index,
        );
      },
    );
  }

  //==================================================
  // Navigator Route Pop
  //==================================================

  /// Navigatorのpopによってタブのルート画面へ戻った場合、
  /// 対象タブのスクロール位置をトップへ戻す。
  ///
  /// Androidの戻るだけでなく、
  /// AppBarの「←戻る」などNavigator.pop()を直接呼ぶ
  /// 操作にも対応する。
  ///
  /// メモ・小役・検索のみを対象とし、
  /// 収支DATA入力とホームの既存動作は変更しない。
  void _handleNavigatorRoutePopped(
    int index,
  ) {
    //================================================
    // 対象タブ
    //================================================

    if (index != 2 &&
        index != 3 &&
        index != 4) {
      return;
    }

    //================================================
    // pop直後は次のフレームで判定
    //================================================

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        final navigator =
            _navigatorKeys[index]
                .currentState;

        if (navigator == null) {
          return;
        }

        //================================================
        // まだ子画面が残っている場合
        //================================================
        //
        // 例：
        // メモDATA詳細
        // ↓ AppBar戻る
        // メモDATA一覧
        //
        // この時点ではcanPop() == trueなので、
        // 一覧画面のスクロール位置は変更しない。
        //================================================

        if (navigator.canPop()) {
          return;
        }

        //================================================
        // ルート画面へ戻った場合のみ
        // トップへ戻す。
        //================================================

        _resetTabScrollPosition(
          index,
        );
      },
    );
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
            '又、現在のデータは復元後、元の状態には戻せません。\n'
            '必要であれば、先に現在のデータをバックアップして下さい。',
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
    // すべてのScrollControllerをトップへ戻す
    //================================================

    for (final controller
        in _tabScrollControllers) {
      if (!controller.hasClients) {
        continue;
      }

      controller.jumpTo(
        controller.position
            .minScrollExtent,
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
  ///
  /// ルート画面の縦スクロールをMainPageから
  /// 制御できるよう、PrimaryScrollControllerを
  /// 各タブ専用Controllerへ接続する。
  Widget _buildRootPage(
    int index,
  ) {
    late final Widget page;

    switch (index) {
      //================================================
      // ホーム
      //================================================

      case 0:
        page = HomePage(
          key: UniqueKey(),
        );
        break;

      //================================================
      // 入力
      //================================================

      case 1:
        //================================================
        // InputPageStateへアクセスするKeyを
        // 毎回新しく生成する。
        //
        // 復元時などにNavigatorのルートを
        // 再生成する場合でも、
        // 既存RouteとのGlobalKey重複を防ぐ。
        //================================================

        _inputPageKey =
            GlobalKey<InputPageState>();

        page = InputPage(
          key: _inputPageKey,
        );
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

    //================================================
    // ルート画面へScrollControllerを接続
    //================================================

    return PrimaryScrollController(
      controller:
          _tabScrollControllers[index],
      child: page,
    );
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

                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Image.asset(
                        'assets/images/drawer/gear.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                      ),
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
              leading: Image.asset(
                'assets/images/drawer/backup.png',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
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
                '「収支・メモ・小役カウンター」データを保存',
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
              leading: Image.asset(
                'assets/images/drawer/restore.png',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
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
                'バックアップデータからデータを復元',
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
            _buildRootPage(0),
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

    //================================================
    // タブ復帰時はトップへ戻す
    //================================================

    if (previousIndex == 0) {
      _resetHomeNavigator();
    } else {
      _resetTabScrollPosition(
        previousIndex,
      );
    }

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

      //================================================
      // ホーム
      //================================================

      if (index == 0) {
        _resetHomeNavigator();

        _scheduleMenuButtonUpdate();

        return;
      }

      //================================================
      // その他のタブ
      //================================================

      _resetTabScrollPosition(
        index,
      );

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

    //================================================
    // タブ復帰時はトップへ戻す
    //================================================

    _resetTabScrollPosition(
      index,
    );

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
  ///    ※ メモ・小役・検索は、
  ///       ルート画面まで戻った場合のみ
  ///       スクロールをトップへ戻す。
  ///
  /// ③ 現在タブがルート画面
  ///    ↓
  ///    BottomNavigationの直前のタブへ戻る
  ///
  /// ④ 現在タブがホーム以外で、
  ///    タブ履歴がない
  ///    ↓
  ///    ホームへ戻す
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
    //
    // ※ Navigator.pop()は必ず1回だけ。
    //==================================================

    if (navigator != null &&
        navigator.canPop()) {
      navigator.pop();

      //================================================
      // 子画面からメモ・小役・検索の
      // ルート画面へ戻った場合のみ、
      // スクロールをトップへ戻す。
      //
      // 収支DATA入力をここでリセットしないことで、
      // 既存の
      //
      // 編集
      // ↓
      // 詳細
      // ↓
      // 一覧
      // ↓
      // ホーム
      //
      // の階層を維持する。
      //================================================

      _resetScrollAfterChildPop(
        _selectedIndex,
      );

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
        final page =
            _buildRootPage(index);

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
  final VoidCallback onRoutePopped;

  _MainTabNavigatorObserver({
    required this.onRouteChanged,
    required this.onRoutePopped,
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
    onRoutePopped();
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