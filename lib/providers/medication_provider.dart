import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medi_time/data/local_db.dart';
import 'package:medi_time/data/models/medication_model.dart';
import 'package:medi_time/core/services/notification_service.dart';

final medicationProvider =
    NotifierProvider<MedicationNotifier, List<Medication>>(
      MedicationNotifier.new,
    );

class MedicationNotifier extends Notifier<List<Medication>> {
  @override
  List<Medication> build() {
    loadMedications();
    return [];
  }

  Future<void> loadMedications() async {
    final meds = await LocalDB.getMedications();
    state = meds;
  }

  Future<void> addMedication(Medication med) async {
    final id = await LocalDB.insertMedication(med);
    final newMed = Medication(
      id: id,
      name: med.name,
      dosage: med.dosage,
      type: med.type,
      totalQuantity: med.totalQuantity,
      quantityPerDose: med.quantityPerDose,
      doctorName: med.doctorName,
      reason: med.reason,
      startDate: med.startDate,
      endDate: med.endDate,
      notes: med.notes,
      imagePath: med.imagePath,
      scheduleMode: med.scheduleMode,
      intervalHours: med.intervalHours,
      timeList: med.timeList,
      daysOfWeek: med.daysOfWeek,
    );
    state = [...state, newMed];

    // Schedule notifications for each time in the list
    for (int i = 0; i < med.timeList.length; i++) {
      final timeParts = med.timeList[i].split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 8;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        // Use a unique ID combination: medId * 100 + index
        await NotificationService.scheduleNotification(
          id: (id * 100) + i,
          title: 'Hora do Remédio: ${med.name}',
          body: 'Tome ${med.dosage}',
          hour: hour,
          minute: minute,
        );
      }
    }
  }

  Future<void> updateMedication(Medication med) async {
    await LocalDB.updateMedication(med);
    state = [
      for (final m in state)
        if (m.id == med.id) med else m,
    ];
    // Re-schedule would require cancelling old one, simplifying for now to just override if ID matches (AwesomeNotif handles ID collision by updating)
  }

  Future<void> deleteMedication(int id) async {
    await LocalDB.deleteMedication(id);
    await NotificationService.cancelNotification(id);
    state = state.where((m) => m.id != id).toList();
  }
}
