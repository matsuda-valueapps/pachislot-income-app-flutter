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
  // 収支マーカー
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
  ///
  /// TableCalendarの標準操作自体は変更せず、
  /// 見た目だけを変更する。
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
  // Build
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider =
        context.watch<HomeProvider>();

    return Container(
      decoration:
          _buildGlassDecoration(),
      padding:
          const EdgeInsets.all(
        AppSpacing.md,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        child: Stack(
          children: [
            //==================================================
            // ガラス内側ハイライト
            //==================================================
            //
            // 外側の青い枠とは別に、
            // 内側へごく薄い白～ブルーのラインを入れる。
            //
            // 重要：
            // このハイライトはTableCalendarより
            // 背面に配置する。
            //
            // これにより、収支金額（+10,000など）と
            // ハイライトラインが重なっても、
            // 収支文字が常に前面に表示される。
            //
            // IgnorePointerにより、
            // この装飾が日付タップ操作を邪魔することもない。
            //==================================================

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      21,
                    ),
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

            //================================================
            // カレンダー本体
            //================================================

            TableCalendar(
              locale: 'ja_JP',

              firstDay:
                  DateTime(2020),

              lastDay:
                  DateTime(2100),

              focusedDay:
                  _focusedDay,

              calendarFormat:
                  CalendarFormat.month,

              daysOfWeekHeight:
                  32,

              selectedDayPredicate:
                  (day) =>
                      isSameDay(
                    _selectedDay,
                    day,
                  ),

              //================================================
              // 日付選択
              //================================================

              onDaySelected: (
                selectedDay,
                focusedDay,
              ) {
                setState(() {
                  _selectedDay =
                      selectedDay;

                  _focusedDay =
                      focusedDay;
                });

                // 表示年月が変更された場合、
                // HomeProviderへ通知する。
                provider
                    .setFocusedMonth(
                  focusedDay,
                );

                // タップされた日付を
                // 親Widgetへ通知する。
                //
                // SQLite検索・確認ダイアログ・
                // 画面遷移はCalendarCardでは行わない。
                _handleDateSelected(
                  selectedDay,
                );
              },

              //================================================
              // 月変更
              //================================================

              onPageChanged: (
                focusedDay,
              ) {
                final now =
                    DateTime.now();

                setState(() {
                  _focusedDay =
                      focusedDay;

                  //================================================
                  // 現在年月の場合
                  //================================================
                  //
                  // 今日を選択状態にする。
                  //
                  // 例：
                  // 2026年8月
                  // → 2026年8月26日を選択
                  //================================================

                  if (focusedDay.year ==
                          now.year &&
                      focusedDay.month ==
                          now.month) {
                    _selectedDay = now;
                  }

                  //================================================
                  // 過去月・未来月の場合
                  //================================================
                  //
                  // 月を移動した直後は無選択にする。
                  //
                  // 例：
                  // 8月 → 7月
                  // → 無選択
                  //
                  // 例：
                  // 8月 → 9月
                  // → 無選択
                  //================================================

                  else {
                    _selectedDay =
                        null;
                  }
                });

                // カレンダーの表示月が変更されたら
                // HomeProviderへ通知する。
                provider
                    .setFocusedMonth(
                  focusedDay,
                );
              },

              //==================================================
              // ヘッダー
              //==================================================

              headerStyle:
                  HeaderStyle(
                titleCentered: true,

                formatButtonVisible:
                    false,

                //================================================
                // 月タイトル
                //================================================

                titleTextStyle:
                    const TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.black87,
                ),

                //================================================
                // 左右の月移動ボタン
                //================================================

                leftChevronIcon:
                    _buildChevronButton(
                  Icons.chevron_left,
                ),

                rightChevronIcon:
                    _buildChevronButton(
                  Icons.chevron_right,
                ),
              ),

              //==================================================
              // カレンダースタイル
              //==================================================

              calendarStyle:
                  const CalendarStyle(
                outsideDaysVisible:
                    true,

                //================================================
                // ガラスカードの背景を
                // そのまま見せる。
                //================================================

                defaultDecoration:
                    BoxDecoration(
                  color:
                      Colors.transparent,
                ),

                weekendDecoration:
                    BoxDecoration(
                  color:
                      Colors.transparent,
                ),

                outsideDecoration:
                    BoxDecoration(
                  color:
                      Colors.transparent,
                ),

                todayDecoration:
                    BoxDecoration(
                  color:
                      Colors.transparent,
                ),

                selectedDecoration:
                    BoxDecoration(
                  color:
                      Colors.transparent,
                ),
              ),

              //==================================================
              // カレンダーBuilder
              //==================================================

              calendarBuilders:
                  CalendarBuilders(
                //==================================================
                // 曜日
                //==================================================

                dowBuilder: (
                  context,
                  day,
                ) {
                  final text = [
                    '日',
                    '月',
                    '火',
                    '水',
                    '木',
                    '金',
                    '土',
                  ][day.weekday % 7];

                  Color color =
                      Colors.black87;

                  if (day.weekday ==
                      DateTime.sunday) {
                    color =
                        Colors.red;
                  } else if (day.weekday ==
                      DateTime.saturday) {
                    color =
                        Colors.blue;
                  }

                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: color,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  );
                },

                //==================================================
                // 通常日
                //==================================================

                defaultBuilder: (
                  context,
                  day,
                  focusedDay,
                ) {
                  return _buildDay(
                    day,
                    textColor:
                        _defaultTextColor(
                      day,
                    ),
                  );
                },

                //==================================================
                // 範囲外の日付
                //==================================================

                outsideBuilder: (
                  context,
                  day,
                  focusedDay,
                ) {
                  return _buildDay(
                    day,
                    textColor:
                        Colors.grey.shade400,
                  );
                },

                //==================================================
                // 今日
                //==================================================

                todayBuilder: (
                  context,
                  day,
                  focusedDay,
                ) {
                  return _buildCircleDay(
                    day,
                    AppColors.primary,
                  );
                },

                //==================================================
                // 選択中の日付
                //==================================================

                selectedBuilder: (
                  context,
                  day,
                  focusedDay,
                ) {
                  return _buildCircleDay(
                    day,
                    Colors.indigo,
                  );
                },

                //==================================================
                // 収支マーカー
                //==================================================

                markerBuilder: (
                  context,
                  day,
                  events,
                ) {
                  final profit =
                      _getProfitForDay(
                    day,
                    provider,
                  );

                  //================================================
                  // 収支データなし
                  //================================================

                  if (profit == null) {
                    return null;
                  }

                  //================================================
                  // プラス収支
                  //================================================

                  if (profit > 0) {
                    return _buildResultLabel(
                      _formatProfit(
                        profit,
                      ),
                      AppColors.profit,
                    );
                  }

                  //================================================
                  // マイナス収支
                  //================================================

                  if (profit < 0) {
                    return _buildResultLabel(
                      _formatProfit(
                        profit,
                      ),
                      AppColors.loss,
                    );
                  }

                  return null;
                },
              ),
            ),

            //==================================================
            // 上部ガラスハイライト
            //==================================================
            //
            // カード上部だけにごく薄い白い光を入れ、
            // ガラス表面の反射感を演出する。
            //==================================================

            Positioned(
              left: 18,
              right: 18,
              top: 8,
              child: IgnorePointer(
                child: Container(
                  height: 2,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      2,
                    ),
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
        width: 32,
        height: 32,
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
    return Align(
      alignment:
          Alignment.bottomCenter,
      child: Transform.translate(
        offset: const Offset(
          0,
          8,
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(
            bottom: 2,
          ),
          child: FittedBox(
            fit:
                BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
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
    );
  }
}