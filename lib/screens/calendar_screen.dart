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
    return allMeds.where((med) {
      // 1. Check Date Range
      if (day.isBefore(DateUtils.dateOnly(med.startDate))) return false;
      if (med.endDate != null &&
          day.isAfter(DateUtils.dateOnly(med.endDate!))) {
        return false;
      }

      // 2. Check Day of Week (med.daysOfWeek uses 1=Mon...7=Sun, DateTime uses same)
      return med.daysOfWeek.contains(day.weekday);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final meds = ref.watch(medicationProvider);
    final selectedEvents = _selectedDay == null
        ? []
        : _getEventsForDay(_selectedDay!, meds);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário de Uso')),
      body: Column(
        children: [
          TableCalendar<Medication>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            eventLoader: (day) => _getEventsForDay(day, meds),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(128),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(4).map((med) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Color(med.color),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text("Selecione um dia"))
                : selectedEvents.isEmpty
                ? const Center(child: Text("Sem medicamentos para este dia"))
                : ListView.builder(
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final med = selectedEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(med.color).withAlpha(50),
                            child: Icon(
                              Icons.medication,
                              color: Color(med.color),
                            ),
                          ),
                          title: Text(
                            med.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            med.scheduleMode == 'fixed'
                                ? "Horários: ${med.timeList.join(', ')}"
                                : "A cada ${med.intervalHours}h",
                          ),
                          trailing: Checkbox(
                            value: false,
                            onChanged: (v) {},
                          ), // Placeholder for future "Mark as Done" per day
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
