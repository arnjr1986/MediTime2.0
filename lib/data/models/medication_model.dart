import 'dart:convert';

class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String type; // comprimido, cápsula, etc.
  final int totalQuantity;
  final int quantityPerDose;
  final String? doctorName;
  final String? reason;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final String? imagePath;

  // Schedule
  final String scheduleMode; // 'fixed' or 'interval'
  final int? intervalHours; // e.g., 8 (every 8 hours)
  final List<String> timeList; // List of times ["08:00", "20:00"]
  final List<int> daysOfWeek; // 1=Mon, 7=Sun

  // Legacy field support (getter) or mapped to new structure
  String get frequency {
    if (scheduleMode == 'interval') {
      return "A cada $intervalHours horas";
    } else {
      return "Horários fixos: ${timeList.join(', ')}";
    }
  }

  String get time => timeList.isNotEmpty ? timeList.first : '';

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.totalQuantity,
    required this.quantityPerDose,
    this.doctorName,
    this.reason,
    required this.startDate,
    this.endDate,
    this.notes,
    this.imagePath,
    required this.scheduleMode,
    this.intervalHours,
    required this.timeList,
    required this.daysOfWeek,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'type': type,
      'totalQuantity': totalQuantity,
      'quantityPerDose': quantityPerDose,
      'doctorName': doctorName,
      'reason': reason,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'imagePath': imagePath,
      'scheduleMode': scheduleMode,
      'intervalHours': intervalHours,
      'timeList': jsonEncode(timeList),
      'daysOfWeek': jsonEncode(daysOfWeek),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    // Handle migration from old simple model if needed, or assume clean slate/defaults
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      type: map['type'] ?? 'Comprimido',
      totalQuantity: map['totalQuantity'] ?? 0,
      quantityPerDose: map['quantityPerDose'] ?? 1,
      doctorName: map['doctorName'],
      reason: map['reason'],
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      notes: map['notes'],
      imagePath: map['imagePath'],
      scheduleMode: map['scheduleMode'] ?? 'fixed',
      intervalHours: map['intervalHours'],
      timeList: map['timeList'] != null
          ? List<String>.from(jsonDecode(map['timeList']))
          : (map['time'] != null ? [map['time']] : []),
      daysOfWeek: map['daysOfWeek'] != null
          ? List<int>.from(jsonDecode(map['daysOfWeek']))
          : [1, 2, 3, 4, 5, 6, 7], // Default all days
    );
  }
}
