import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../theme/app_colors.dart';
import '../common/app_card.dart';

import 'package:holiday_jp/holiday_jp.dart';

/// ホーム画面用カレンダーカード
class CalendarCard extends StatefulWidget {
  const CalendarCard({
    super.key,
  });

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  /// 将来SQLiteから取得する収支データ
  ///
  /// 例：
  /// DateTime(2026, 7, 2): 8200
  /// DateTime(2026, 7, 5): -15000
  final Map<DateTime, int> _dailyIncome = {};

  bool _isHoliday(DateTime day) {
    return isHoliday(day);
  }

  bool _isProfitDay(DateTime day) {
    for (final entry in _dailyIncome.entries) {
      if (isSameDay(entry.key, day)) {
        return entry.value > 0;
      }
    }

    return false;
  }

  bool _isLossDay(DateTime day) {
    for (final entry in _dailyIncome.entries) {
      if (isSameDay(entry.key, day)) {
        return entry.value < 0;
      }
    }

    return false;
  }

  Color _defaultTextColor(DateTime day) {
    if (_isHoliday(day) || day.weekday == DateTime.sunday) {
      return Colors.red;
    }

    if (day.weekday == DateTime.saturday) {
      return Colors.blue;
    }

    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: TableCalendar(
        locale: 'ja_JP',

        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: _focusedDay,

        calendarFormat: CalendarFormat.month,

        daysOfWeekHeight: 32,

        selectedDayPredicate: (day) =>
            isSameDay(_selectedDay, day),

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },

        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),

        calendarStyle: const CalendarStyle(
          outsideDaysVisible: true,
        ),

        calendarBuilders: CalendarBuilders(

          dowBuilder: (context, day) {
            final text = ['日', '月', '火', '水', '木', '金', '土'][day.weekday % 7];

            Color color = Colors.black87;

            if (day.weekday == DateTime.sunday) {
              color = Colors.red;
            } else if (day.weekday == DateTime.saturday) {
              color = Colors.blue;
            }

            return Center(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
          
          defaultBuilder: (context, day, focusedDay) {
            return _buildDay(
              day,
              textColor: _defaultTextColor(day),
            );
          },

          outsideBuilder: (context, day, focusedDay) {
            return _buildDay(
              day,
              textColor: Colors.grey.shade400,
            );
          },

          todayBuilder: (context, day, focusedDay) {
            return _buildCircleDay(
              day,
              AppColors.primary,
            );
          },

          selectedBuilder: (context, day, focusedDay) {
            return _buildCircleDay(
              day,
              Colors.indigo,
            );
          },

          markerBuilder: (context, day, events) {
            if (_isProfitDay(day)) {
              return _buildMarker(Colors.green);
            }

            if (_isLossDay(day)) {
              return _buildMarker(Colors.red);
            }

            return null;
          },
        ),
      ),
    );
  }

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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMarker(Color color) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}