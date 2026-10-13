import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:holiday_jp/holiday_jp.dart';

import '../../providers/home_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// ホーム画面用カレンダーカード
///
/// 現在のカレンダー機能・日付配置・収支表示・
/// 操作方法は維持したまま、
///
/// ・薄いブルーのガラス調背景
/// ・二重のハイライト枠
/// ・柔らかい立体シャドウ
/// ・プレミアム感のある月移動ボタン
/// ・立体感のある今日／選択日
///
/// を追加したプレミアム3Dガラスカード。
class CalendarCard extends StatefulWidget {
  const CalendarCard({
    super.key,
    this.onDateSelected,
  });

  /// 日付タップ時のコールバック
  ///
  /// CalendarCard自身ではSQLiteや画面遷移を行わず、
  /// タップされた日付だけを親Widgetへ通知する。
  final ValueChanged<DateTime>? onDateSelected;

  @override
  State<CalendarCard> createState() =>
      _CalendarCardState();
}

class _CalendarCardState
    extends State<CalendarCard> {
  /// 現在カレンダーで表示している年月
  late DateTime _focusedDay;

  /// 選択中の日付
  ///
  /// nullの場合は「無選択」。
  DateTime? _selectedDay;

  //==================================================
  // 初期化
  //==================================================

  @override
  void initState() {
    super.initState();

    final provider =
        context.read<HomeProvider>();

    _focusedDay =
        provider.focusedMonth;

    final now =
        DateTime.now();

    //==================================================
    // 初期選択状態
    //==================================================
    //
    // 現在年月を表示している場合
    // → 今日を選択
    //
    // 過去月・未来月の場合
    // → 無選択
    //==================================================

    if (_focusedDay.year ==
            now.year &&
        _focusedDay.month ==
            now.month) {
      _selectedDay = now;
    } else {
      _selectedDay = null;
    }
  }

  //==================================================
  // プレミアムガラスカード
  //==================================================

  /// 薄いブルーの高級ガラスカード用Decoration。
  ///
  /// 白をベースに、ごく薄いブルーを重ねることで
  /// 「青いカード」ではなく
  /// 「光を反射するガラス」の印象にする。
  BoxDecoration _buildGlassDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(
            255,
            255,
            255,
            0.98,
          ),
          Color.fromRGBO(
            247,
            251,
            255,
            0.98,
          ),
          Color.fromRGBO(
            239,
            247,
            255,
            0.98,
          ),
        ],
        stops: [
          0.0,
          0.52,
          1.0,
        ],
      ),
      borderRadius:
          BorderRadius.circular(
        28,
      ),
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
        //================================================
        // 下方向の柔らかい影
        //================================================
        BoxShadow(
          color: Color.fromRGBO(
            92,
            143,
            196,
            0.18,
          ),
          blurRadius: 22,
          spreadRadius: 2,
          offset: Offset(
            0,
            10,
          ),
        ),

        //================================================
        // 近距離の立体影
        //================================================
        BoxShadow(
          color: Color.fromRGBO(
            125,
            170,
            215,
            0.12,
          ),
          blurRadius: 8,
          spreadRadius: 0,
          offset: Offset(
            0,
            3,
          ),
        ),
      ],
    );
  }

  //==================================================
  // 休日
  //==================================================

  /// 祝日判定
  bool _isHoliday(
    DateTime day,
  ) {
    return isHoliday(day);
  }

  //==================================================
  // 収支データ取得
  //==================================================

  /// 現在保存されている収支データから
  /// 該当日の収支金額を取得する。
  ///
  /// 収支データが存在しない場合はnullを返す。
  int? _getProfitForDay(
    DateTime day,
    HomeProvider provider,
  ) {
    for (final record
        in provider.incomeRecords) {
      try {
        final recordDate =
            DateTime.parse(
          record.date,
        );

        if (isSameDay(
          recordDate,
          day,
        )) {
          // 収支が0円の場合は
          // マーカーを表示しない。
          if (record.profit == 0) {
            return null;
          }

          return record.profit;
        }
      } catch (_) {
        // 日付が不正な場合は無視
      }
    }

    return null;
  }

  /// 収支金額をカンマ区切りにする。
  ///
  /// 例：
  /// 1000    → 1,000
  /// 10000   → 10,000
  /// 1000000 → 1,000,000
  String _formatNumber(
    int number,
  ) {
    final numberString =
        number.abs().toString();

    return numberString.replaceAllMapped(
      RegExp(
        r'\B(?=(\d{3})+(?!\d))',
      ),
      (match) => ',',
    );
  }

  /// 収支金額をカレンダー表示用の文字列にする。
  ///
  /// プラス：
  /// +10,000
  ///
  /// マイナス：
  /// -10,000
  String _formatProfit(
    int profit,
  ) {
    if (profit > 0) {
      return '+${_formatNumber(profit)}';
    }

    return '-${_formatNumber(profit)}';
  }

  //==================================================
  // 日付カラー
  //==================================================

  /// 通常の日付文字色
  Color _defaultTextColor(
    DateTime day,
  ) {
    if (_isHoliday(day) ||
        day.weekday ==
            DateTime.sunday) {
      return Colors.red;
    }

    if (day.weekday ==
        DateTime.saturday) {
      return Colors.blue;
    }

    return Colors.black87;
  }

  //==================================================
  // 日付タップ
  //==================================================

  /// 日付タップ処理
  ///
  /// CalendarCardではSQLite検索や画面遷移を行わず、
  /// タップされた日付を親Widgetへ通知する。
  void _handleDateSelected(
    DateTime selectedDay,
  ) {
    widget.onDateSelected?.call(
      selectedDay,
    );
  }

  //==================================================
  // 月移動ボタン
  //==================================================

  /// プレミアムガラス調の月移動ボタン。
  Widget _buildChevronButton(
    IconData icon,
  ) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(
              255,
              255,
              255,
              0.98,
            ),
            Color.fromRGBO(
              232,
              243,
              255,
              0.95,
            ),
          ],
        ),
        border: Border.all(
          color: const Color.fromRGBO(
            175,
            209,
            240,
            0.55,
          ),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              101,
              151,
              202,
              0.14,
            ),
            blurRadius: 7,
            offset: Offset(
              0,
              3,
            ),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: Colors.black87,
        size: 27,
      ),
    );
  }

  //==================================================
  // 月移動
  //==================================================

  /// 月を移動する。
  ///
  /// amount:
  /// -1 → 前月
  ///  1 → 翌月
  void _changeMonth(int amount) {
    final nextMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + amount,
      1,
    );

    final now = DateTime.now();

    setState(() {
      _focusedDay = nextMonth;

      // 現在年月に戻った場合は今日を選択する。
      // 過去月・未来月へ移動した場合は無選択にする。
      if (nextMonth.year == now.year &&
          nextMonth.month == now.month) {
        _selectedDay = now;
      } else {
        _selectedDay = null;
      }
    });

    context
        .read<HomeProvider>()
        .setFocusedMonth(nextMonth);
  }

  //==================================================
  // カスタムカレンダーの日付セル
  //==================================================

  /// 日付と収支金額を同じセル内に配置する。
  ///
  /// セルの高さを引数で受け取ることで、
  /// 最終週だけ表示スペースを広げられる。
  Widget _buildCalendarDayCell(
    DateTime day,
    HomeProvider provider, {
    required double height,
  }) {
    final isSelected =
        isSameDay(_selectedDay, day);

    final isToday =
        isSameDay(DateTime.now(), day);

    final profit =
        _getProfitForDay(day, provider);

    Widget dateWidget;

    if (isSelected || isToday) {
      dateWidget = _buildCircleDay(
        day,
        isSelected
            ? Colors.indigo
            : AppColors.primary,
      );
    } else {
      dateWidget = _buildDay(
        day,
        textColor: _defaultTextColor(day),
      );
    }

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDay = day;
              _focusedDay = day;
            });

            provider.setFocusedMonth(day);

            _handleDateSelected(day);
          },
          borderRadius:
              BorderRadius.circular(8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 日付をセルの上側に配置
              Positioned(
                top: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: dateWidget,
                ),
              ),

              //================================================
              // 収支金額の表示位置
              //================================================
              //
              // セルの下端ではなく、セル上端からの位置を固定する。
              // これにより、最終週の高さを広げても
              // 日付と収支金額の間隔が広がらない。
              //
              // 通常週・最終週ともにtop: 42で統一する。
              //================================================

              if (profit != null && profit != 0)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 36,
                  child: _buildResultLabel(
                    _formatProfit(profit),
                    profit > 0
                        ? AppColors.profit
                        : AppColors.loss,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<HomeProvider>();

    // 表示月の初日
    final firstDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      1,
    );

    // 表示月の日数
    final daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;

    // DateTime.weekday は月曜=1～日曜=7。
    // カレンダーは日曜始まりのため、日曜=0に変換する。
    final leadingEmptyCells =
        firstDay.weekday % 7;

    final totalCells =
        leadingEmptyCells + daysInMonth;

    final weekCount =
        (totalCells / 7).ceil();

    //==================================================
    // 週ごとの高さ
    //==================================================
    //
    // 通常週：60px
    // 最終週：82px
    //
    // 最終週だけ独立して高さを指定するため、
    // 31日など月末の日付に収支がある場合も
    // 金額の表示スペースを確保できる。
    //==================================================

    const normalWeekHeight = 60.0;
    const finalWeekHeight = 82.0;

    final weekRows = <Widget>[];

    for (var week = 0;
        week < weekCount;
        week++) {
      final isFinalWeek =
          week == weekCount - 1;

      final rowHeight = isFinalWeek
          ? finalWeekHeight
          : normalWeekHeight;

      final dayCells = <Widget>[];

      for (var weekday = 0;
          weekday < 7;
          weekday++) {
        final cellIndex =
            week * 7 + weekday;

        final dayNumber =
            cellIndex - leadingEmptyCells + 1;

        Widget cell;

        // 表示月に含まれないセルは空欄にする。
        if (dayNumber < 1 ||
            dayNumber > daysInMonth) {
          cell = SizedBox(
            height: rowHeight,
          );
        } else {
          final day = DateTime(
            _focusedDay.year,
            _focusedDay.month,
            dayNumber,
          );

          cell = _buildCalendarDayCell(
            day,
            provider,
            height: rowHeight,
          );
        }

        dayCells.add(
          Expanded(
            child: cell,
          ),
        );
      }

      weekRows.add(
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: dayCells,
        ),
      );
    }

    return Container(
      decoration: _buildGlassDecoration(),
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(22),
        child: Stack(
          children: [
            //==================================================
            // ガラス内側ハイライト
            //==================================================
            //
            // カレンダー本体の背面に配置する。
            // IgnorePointerにより日付タップを妨げない。
            //==================================================

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(21),
                    border: Border.all(
                      color:
                          const Color.fromRGBO(
                        255,
                        255,
                        255,
                        0.82,
                      ),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            //==================================================
            // 独自配置カレンダー
            //==================================================

            GestureDetector(
              // 左右スワイプで月を移動する。
              onHorizontalDragEnd: (details) {
                final velocity =
                    details.primaryVelocity ?? 0;

                if (velocity < -100) {
                  // 左スワイプ：翌月
                  _changeMonth(1);
                } else if (velocity > 100) {
                  // 右スワイプ：前月
                  _changeMonth(-1);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //================================================
                  // 月タイトルと月移動ボタン
                  //================================================

                  SizedBox(
                    height: 76,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _changeMonth(-1),
                          child: _buildChevronButton(
                            Icons.chevron_left,
                          ),
                        ),

                        Expanded(
                          child: Center(
                            child: Text(
                              '${_focusedDay.year}年${_focusedDay.month}月',
                              style:
                                  const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Colors.black87,
                              ),
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () =>
                              _changeMonth(1),
                          child: _buildChevronButton(
                            Icons.chevron_right,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //================================================
                  // 曜日
                  //================================================

                  SizedBox(
                    height: 32,
                    child: Row(
                      children: [
                        for (var weekday = 0;
                            weekday < 7;
                            weekday++)
                          Expanded(
                            child: Center(
                              child: Text(
                                const [
                                  '日',
                                  '月',
                                  '火',
                                  '水',
                                  '木',
                                  '金',
                                  '土',
                                ][weekday],
                                style: TextStyle(
                                  color: weekday == 0
                                      ? Colors.red
                                      : weekday == 6
                                          ? Colors.blue
                                          : Colors.black87,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  //================================================
                  // 日付セル
                  //================================================
                  //
                  // 各週の高さは weekRows を生成する段階で
                  // 設定済み。
                  //
                  // 最終週だけ高さを広げることで、
                  // 月末の収支金額の表示スペースを確保する。
                  //================================================

                  for (final row in weekRows)
                    row,
                ],
              ),
            ),

            //==================================================
            // 上部ガラスハイライト
            //==================================================

            Positioned(
              left: 18,
              right: 18,
              top: 8,
              child: IgnorePointer(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(2),
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color.fromRGBO(
                          255,
                          255,
                          255,
                          0.0,
                        ),
                        Color.fromRGBO(
                          255,
                          255,
                          255,
                          0.85,
                        ),
                        Color.fromRGBO(
                          255,
                          255,
                          255,
                          0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // 日付表示
  //==================================================

  Widget _buildDay(
    DateTime day, {
    required Color textColor,
  }) {
    return Center(
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  //==================================================
  // 円形日付表示
  //==================================================

  /// 今日・選択中の日付を
  /// プレミアム3D調の円形で表示する。
  Widget _buildCircleDay(
    DateTime day,
    Color color,
  ) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          //================================================
          // 上から下へ少し濃くなることで
          // 平面的な円ではなく立体感を出す。
          //================================================

          gradient:
              LinearGradient(
            begin:
                Alignment.topLeft,
            end:
                Alignment.bottomRight,
            colors: [
              Color.lerp(
                    Colors.white,
                    color,
                    0.08,
                  ) ??
                  color,
              color,
              Color.lerp(
                    color,
                    Colors.black,
                    0.14,
                  ) ??
                  color,
            ],
            stops: const [
              0.0,
              0.48,
              1.0,
            ],
          ),

          border: Border.all(
            color:
                const Color.fromRGBO(
              255,
              255,
              255,
              0.48,
            ),
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color: color.withValues(
                alpha: 0.28,
              ),
              blurRadius: 7,
              spreadRadius: 1,
              offset: const Offset(
                0,
                3,
              ),
            ),
          ],
        ),
        alignment:
            Alignment.center,
        child: Text(
          '${day.day}',
          style:
              const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  //==================================================
  // 収支結果ラベル
  //==================================================

  /// 日付の下に収支金額を表示する。
  ///
  /// プラス収支 → 緑
  /// 例：+10,000
  ///
  /// マイナス収支 → 赤
  /// 例：-10,000
  Widget _buildResultLabel(
    String text,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                text,
                maxLines: 1,
                softWrap: false,
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}