import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medi_time/providers/medication_provider.dart';
import 'package:medi_time/data/models/medication_model.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Medication> _getEventsForDay(DateTime day, List<Medication> allMeds) {
    // Logic to determine if meds should be shown for this day.
    // For simplicity/demo: showing all meds every day as a recurring event
    return allMeds;
  }

  @override
  Widget build(BuildContext context) {
    final meds = ref.watch(medicationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário de Uso')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) => _getEventsForDay(day, meds),
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text("Selecione um dia"))
                : ListView.builder(
                    itemCount: meds.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(meds[index].name),
                        subtitle: Text("Horário: ${meds[index].time}"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
