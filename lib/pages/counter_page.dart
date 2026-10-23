import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/counter_record.dart';
import '../providers/counter_provider.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/action_button_icon.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/counter/counter_card.dart';
import '../widgets/counter/game_counter.dart';
import '../widgets/counter/start_game_counter.dart';
import '../widgets/search/service_icon.dart';
import 'counter_list_page.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  CounterPageState createState() => CounterPageState();
}

class CounterPageState extends State<CounterPage> {
  //==================================================
  // Controller
  //==================================================

  /// 開始ゲーム数
  final TextEditingController _startGameController =
      TextEditingController();

  /// 現在ゲーム数
  final TextEditingController _currentGameController =
      TextEditingController();

  /// タイトル
  final TextEditingController _titleController =
      TextEditingController();

  //==================================================
  // スクロール位置制御
  //==================================================

  /// ページ上部の位置
  final GlobalKey _topSectionKey = GlobalKey();

  /// 小役カードの位置
  final GlobalKey _counterSectionKey = GlobalKey();

  /// 小役カード付近までスクロールする。
  void scrollToCounterSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final targetContext = _counterSectionKey.currentContext;

      if (targetContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.05,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  /// ページ上部までスクロールする。
  void scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final targetContext = _topSectionKey.currentContext;

      if (targetContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        alignment: 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  //==================================================
  // プレミアムガラスカード
  //==================================================

  /// MemoPageと同じプレミアムガラスカード用Decoration。
  ///
  /// ・すごく薄いブルー～ごく薄いブルー～薄いブルーのグラデーション
  /// ・薄いブルーの外側Border
  /// ・柔らかい立体シャドウ
  ///
  /// ※ガラス内側ハイライトは使用しない。
  /// ※上部ガラスハイライトは使用しない。
  BoxDecoration _buildGlassDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(250, 253, 255, 0.98),
          Color.fromRGBO(247, 251, 255, 0.98),
          Color.fromRGBO(239, 247, 255, 0.98),
        ],
        stops: [
          0.0,
          0.52,
          1.0,
        ],
      ),
      borderRadius: AppRadius.card,
      border: Border.all(
        color: const Color.fromRGBO(
          157,
          201,
          246,
          0.78,
        ),
        width: 1.5,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(
            92,
            143,
            196,
            0.18,
          ),
          blurRadius: 22,
          spreadRadius: 2,
          offset: Offset(0, 10),
        ),
        BoxShadow(
          color: Color.fromRGBO(
            125,
            170,
            215,
            0.12,
          ),
          blurRadius: 8,
          spreadRadius: 0,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  //==================================================
  // 初期化
  //==================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final provider = context.read<CounterProvider>();

        await provider.loadDraft();

        if (!mounted) {
          return;
        }

        // ゲーム数
        _startGameController.text = provider.startGame == 0
            ? ''
            : provider.startGame.toString();

        _currentGameController.text = provider.currentGame == 0
            ? ''
            : provider.currentGame.toString();

        // タイトル
        _titleController.text = provider.title;
      },
    );
  }

  @override
  void dispose() {
    _startGameController.dispose();
    _currentGameController.dispose();
    _titleController.dispose();

    super.dispose();
  }

  //==================================================
  // 日付表示
  //==================================================

  /// 日付を「2026年8月18日(火)」の形式で表示する。
  String _formatDate(DateTime date) {
    return DateFormat(
      'yyyy年M月d日(E)',
      'ja_JP',
    ).format(date);
  }

  //==================================================
  // 日付選択
  //==================================================

  /// 日付を選択する。
  Future<void> _selectDate(
    CounterProvider provider,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ja', 'JP'),
    );

    if (pickedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    provider.setSelectedDate(pickedDate);
  }

  //==================================================
  // タイトル変更
  //==================================================

  /// タイトル変更
  void _onTitleChanged(
    CounterProvider provider,
    String value,
  ) {
    provider.setTitle(value);
  }

  //==================================================
  // SQLite保存用CounterRecord作成
  //==================================================

  /// SQLite保存用のCounterRecordを作成する。
  ///
  /// 保存時点の日付・タイトル・機種タイプ・ゲーム数・
  /// AタイプおよびATタイプの小役カウント・作成日時・更新日時を
  /// 正式保存用データへまとめる。
  CounterRecord _createCounterRecord(
    CounterProvider provider,
  ) {
    final now = DateTime.now();
    final counts = provider.activeCounts;

    return CounterRecord(
      // 基本情報
      date: provider.selectedDate
          .toIso8601String()
          .split('T')
          .first,
      title: provider.title.trim(),
      machineType: provider.machineType,

      // ゲーム数
      startGame: provider.startGame,
      currentGame: provider.currentGame,

      // Aタイプ小役
      cherry: counts['cherry'] ?? 0,
      bell: counts['bell'] ?? 0,
      suika: counts['suika'] ?? 0,
      grape: counts['grape'] ?? 0,
      chance: counts['chance'] ?? 0,

      // ATタイプ小役
      strongCherry: counts['strongCherry'] ?? 0,
      weakCherry: counts['weakCherry'] ?? 0,
      strongBell: counts['strongBell'] ?? 0,
      weakBell: counts['weakBell'] ?? 0,
      strongSuika: counts['strongSuika'] ?? 0,
      weakSuika: counts['weakSuika'] ?? 0,
      strongGrape: counts['strongGrape'] ?? 0,
      weakGrape: counts['weakGrape'] ?? 0,
      strongChance: counts['strongChance'] ?? 0,
      weakChance: counts['weakChance'] ?? 0,

      // 日時
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
  }

  //==================================================
  // 保存後の完全初期化
  //==================================================

  /// 小役カウンターの保存成功後に、
  /// 入力画面を初期状態へ戻す。
  ///
  /// ・フォーカス解除
  /// ・キーボード非表示
  /// ・Provider初期化
  /// ・TextField初期化
  ///
  /// 保存後のスクロール位置は強制変更しない。
  Future<void> _resetAfterSave(
    CounterProvider provider,
  ) async {
    // フォーカス解除
    FocusManager.instance.primaryFocus?.unfocus();

    // ソフトウェアキーボードを閉じる
    try {
      await SystemChannels.textInput.invokeMethod<void>(
        'TextInput.hide',
      );
    } catch (_) {
      // キーボード非表示に失敗しても、
      // 保存済みデータの処理には影響させない。
    }

    // Providerをリセット
    await provider.reset();

    if (!mounted) {
      return;
    }

    // TextFieldも初期状態へ戻す
    _startGameController.clear();
    _currentGameController.clear();
    _titleController.clear();

    // 保存成功後はページ上部へ戻す
    scrollToTop();
  }

  //==================================================
  // 保存
  //==================================================

  /// 小役カウンター保存
  ///
  /// 1. 保存確認
  /// 2. SQLiteへ正式保存
  /// 3. 下書き削除
  /// 4. カウンター初期化
  /// 5. フォーカス解除
  /// 6. キーボード非表示
  ///
  /// 保存後にスクロールトップへ強制移動しない。
  Future<void> _onSave(
    CounterProvider provider,
  ) async {
    final result = await DialogService.showConfirm(
      context: context,
      title: '保存しますか？',
      message: 'カウント内容を保存します。',
      confirmText: '保存',
    );

    if (!mounted) {
      return;
    }

    if (!result) {
      return;
    }

    try {
      // SQLite保存用データ作成
      final record = _createCounterRecord(provider);

      // SQLiteへ正式保存
      await DatabaseService.instance.insertCounterRecord(
        record,
      );

      if (!mounted) {
        return;
      }

      // SQLite保存成功後に画面を初期化
      await _resetAfterSave(provider);

      if (!mounted) {
        return;
      }

      // 保存完了
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存しました'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      // SQLite保存失敗時は下書きを残す。
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '保存に失敗しました。もう一度お試しください。',
          ),
        ),
      );
    }
  }

  //==================================================
  // リセット
  //==================================================

  /// 小役カウンターをリセットする。
  Future<void> _onReset(
    CounterProvider provider,
  ) async {
    final result = await DialogService.showConfirm(
      context: context,
      title: 'リセットしますか？',
      message: '入力内容をすべてリセットします。',
      confirmText: 'リセット',
    );

    if (!mounted) {
      return;
    }

    if (!result) {
      return;
    }

    // Providerをリセット
    await provider.reset();

    // TextFieldも初期状態へ戻す
    _startGameController.clear();
    _currentGameController.clear();
    _titleController.clear();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('リセットしました'),
      ),
    );
  }

  //==================================================
  // 保存小役データ一覧
  //==================================================

  /// 保存済み小役データ一覧画面を開く。
  Future<void> _openCounterListPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CounterListPage(),
      ),
    );
  }

  //==================================================
  // 日付フィールド
  //==================================================

  Widget _buildDateField(
    BuildContext context,
    CounterProvider provider,
  ) {
    final formattedDate = _formatDate(provider.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '日付',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDate(provider),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  const ServiceIcon(
                    icon: 'google_calendar',
                    size: 38,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.iconDisabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //==================================================
  // 機種タイプフィールド
  //==================================================

  Widget _buildMachineTypeField(
    CounterProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '機種タイプ',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: provider.machineType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          items: const [
            DropdownMenuItem<String>(
              value: 'Aタイプ',
              child: Text('Aタイプ'),
            ),
            DropdownMenuItem<String>(
              value: 'ATタイプ',
              child: Text('ATタイプ'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              provider.setMachineType(value);
            }
          },
        ),
      ],
    );
  }

  //==================================================
  // タイトルフィールド
  //==================================================

  Widget _buildTitleField(
    BuildContext context,
    CounterProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'タイトル',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _titleController,
          onChanged: (value) {
            _onTitleChanged(provider, value);
          },
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: '例：マルハン○○店○○7番台',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CounterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('小役カウンター'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AdMobバナー
            const AdBanner(),

            // ページ全体のスクロール領域
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: Container(
                  key: _topSectionKey,
                  margin: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                  ),
                  padding: AppSpacing.card,
                  decoration: _buildGlassDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 日付
                      _buildDateField(
                        context,
                        provider,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // 機種タイプ
                      _buildMachineTypeField(provider),

                      const SizedBox(height: AppSpacing.lg),

                      // タイトル
                      _buildTitleField(
                        context,
                        provider,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // 開始ゲーム数
                      StartGameCounter(
                        controller: _startGameController,
                        onChanged: provider.updateStartGame,
                      ),

                      // 現在ゲーム数
                      GameCounter(
                        controller: _currentGameController,
                        onChanged: provider.updateCurrentGame,
                      ),

                      //================================================
                      // 小役カウンター
                      //================================================
                      //
                      // Aタイプ：1列表示
                      // ATタイプ：2列表示
                      //
                      // GridView内部ではスクロールせず、
                      // ページ全体のスクロールを使用する。
                      //================================================

                      Container(
                        key: _counterSectionKey,
                        child: GridView.count(
                          crossAxisCount:
                              provider.machineType == 'Aタイプ' ? 1 : 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 4,
                          childAspectRatio:
                              provider.machineType == 'Aタイプ' ? 4.1 : 1.35,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: provider.items.map((item) {
                            return CounterCard(
                              item: item,
                              probability: provider.probability(
                                item.id,
                              ),
                              onIncrement: () {
                                provider.increment(item.id);
                              },
                              onDecrement: () {
                                provider.decrement(item.id);
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // リセット・保存
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _onReset(provider);
                              },
                              child: const Text('リセット'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                _onSave(provider);
                              },
                              child: const Text('保存'),
                            ),
                          ),
                        ],
                      ),

                      // 保存小役データ一覧
                      const SizedBox(height: AppSpacing.md),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openCounterListPage,
                          icon: const ActionButtonIcon.list(
                            size: 38,
                          ),
                          label: const Text('小役データリスト'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}