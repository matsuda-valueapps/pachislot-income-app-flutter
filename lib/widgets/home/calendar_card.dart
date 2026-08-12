import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:holiday_jp/holiday_jp.dart';

import '../../providers/home_provider.dart';
import '../../theme/app_colors.dart';
import '../common/app_card.dart';

/// ホーム画面用カレンダーカード
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
  late DateTime _selectedDay;

  /// 初期化
  @override
  void initState() {
    super.initState();

    final provider =
        context.read<HomeProvider>();

    _focusedDay =
        provider.focusedMonth;

    _selectedDay = DateTime.now();
  }

  //==================================================
  // 休日
  //==================================================

  /// 祝日判定
  bool _isHoliday(DateTime day) {
    return isHoliday(day);
  }

  //==================================================
  // 収支マーカー
  //==================================================

  /// 現在保存されている収支データから
  /// 該当日の収支がプラスか判定
  bool _isProfitDay(
    DateTime day,
    HomeProvider provider,
  ) {
    for (final record
        in provider.incomeRecords) {
      try {
        final recordDate =
            DateTime.parse(record.date);

        if (isSameDay(recordDate, day)) {
          return record.profit > 0;
        }
      } catch (_) {
        // 日付が不正な場合は無視
      }
    }

    return false;
  }

  /// 現在保存されている収支データから
  /// 該当日の収支がマイナスか判定
  bool _isLossDay(
    DateTime day,
    HomeProvider provider,
  ) {
    for (final record
        in provider.incomeRecords) {
      try {
        final recordDate =
            DateTime.parse(record.date);

        if (isSameDay(recordDate, day)) {
          return record.profit < 0;
        }
      } catch (_) {
        // 日付が不正な場合は無視
      }
    }

    return false;
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
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<HomeProvider>();

    return AppCard(
      child: TableCalendar(
        locale: 'ja_JP',

        firstDay: DateTime(2020),
        lastDay: DateTime(2035),

        focusedDay: _focusedDay,

        calendarFormat:
            CalendarFormat.month,

        daysOfWeekHeight: 32,

        selectedDayPredicate: (day) =>
            isSameDay(
              _selectedDay,
              day,
            ),

        //==================================================
        // 日付選択
        //==================================================

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
          provider.setFocusedMonth(
            focusedDay,
          );

          // タップされた日付を親Widgetへ通知する。
          //
          // SQLite検索・確認ダイアログ・画面遷移は
          // CalendarCardでは行わない。
          _handleDateSelected(
            selectedDay,
          );
        },

        //==================================================
        // 月変更
        //==================================================

        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay =
                focusedDay;
          });

          // カレンダーの表示月が変更されたら
          // HomeProviderへ通知する。
          provider.setFocusedMonth(
            focusedDay,
          );
        },

        //==================================================
        // ヘッダー
        //==================================================

        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),

        //==================================================
        // カレンダースタイル
        //==================================================

        calendarStyle:
            const CalendarStyle(
          outsideDaysVisible: true,
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
              color = Colors.red;
            } else if (day.weekday ==
                DateTime.saturday) {
              color = Colors.blue;
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
                  _defaultTextColor(day),
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
            if (_isProfitDay(
              day,
              provider,
            )) {
              return _buildMarker(
                Colors.green,
              );
            }

            if (_isLossDay(
              day,
              provider,
            )) {
              return _buildMarker(
                Colors.red,
              );
            }

            return null;
          },
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
        ),
      ),
    );
  }

  //==================================================
  // 円形日付表示
  //==================================================

  Widget _buildCircleDay(
    DateTime day,
    Color color,
  ) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  //==================================================
  // 収支マーカー
  //==================================================

  Widget _buildMarker(
    Color color,
  ) {
    return Align(
      alignment:
          Alignment.bottomCenter,
      child: Container(
        width: 6,
        height: 6,
        margin:
            const EdgeInsets.only(
          bottom: 4,
        ),
        decoration:
            BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}