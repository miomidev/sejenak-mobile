import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:table_calendar/table_calendar.dart';

class SejenakCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final Color color;
  const SejenakCalendar({
    Key? key,
    this.color = SejenakColor.primary,
    this.initialDate,
    this.onDateSelected,
  }) : super(key: key);

  @override
  _SejenakCalendarState createState() => _SejenakCalendarState();
}

class _SejenakCalendarState extends State<SejenakCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate ?? DateTime.now();
    _selectedDay = widget.initialDate;
  }

  bool click = false;
  double opacity = 1.0;
  double offsetY = 0.0;

  Future<void> _onclick() async {
    setState(() {
      click = true;
      opacity = 0.6;
      offsetY = 4.0;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      click = false;
      opacity = 1.0;
      offsetY = 0.0;
    });
    // await widget.action();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: Colors.grey[900]!,
          ),
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: !click
              ? [
                  const BoxShadow(
                    color: SejenakColor.black,
                    spreadRadius: 0.2,
                    blurRadius: 0,
                    offset: Offset(0.1, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ...['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                    .map((hari) => Expanded(
                          child: Center(
                            child: SejenakText(
                              text: hari,
                              type: SejenakTextType.regular,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.0,
                  color: Colors.grey[900]!,
                ),
                color: SejenakColor.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: !click
                    ? [
                        const BoxShadow(
                          color: SejenakColor.black,
                          spreadRadius: 0.2,
                          blurRadius: 0,
                          offset: Offset(-2, -4),
                        ),
                      ]
                    : [],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  widget.onDateSelected?.call(selectedDay);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                shouldFillViewport: false,
                pageAnimationEnabled: true,
                pageAnimationDuration: Duration(milliseconds: 100),
                calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: SejenakColor.secondary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: SejenakColor.purple,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                        color: SejenakColor.stroke,
                        wordSpacing: 0.4),
                    weekendTextStyle: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                        color: SejenakColor.purple,
                        wordSpacing: 0.4)),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                      fontSize: 14.24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                      color: SejenakColor.dark,
                      wordSpacing: 0.4),
                ),
                headerVisible: false,
                daysOfWeekVisible: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
