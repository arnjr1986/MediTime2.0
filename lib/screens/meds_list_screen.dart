import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medi_time/data/models/medication_model.dart';
import 'package:medi_time/providers/medication_provider.dart';
import 'package:medi_time/screens/add_medication_screen.dart';

class MedsListScreen extends ConsumerWidget {
  const MedsListScreen({super.key});

  void _openForm(BuildContext context, {Medication? med}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(medication: med),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Medicamentos')),
      body: meds.isEmpty
          ? const Center(child: Text('Nenhum medicamento cadastrado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meds.length,
              itemBuilder: (context, index) {
                final med = meds[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        _getIconForType(med.type),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      med.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${med.type} • ${med.dosage}'),
                        Text(
                          med.scheduleMode == 'fixed'
                              ? 'Horários: ${med.timeList.join(", ")}'
                              : 'A cada ${med.intervalHours}h',
                        ),
                        if (med.doctorName?.isNotEmpty == true)
                          Text(
                            'Dr(a): ${med.doctorName}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openForm(context, med: med),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(medicationProvider.notifier)
                                .deleteMedication(med.id!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        label: const Text('Novo Medicamento'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'comprimido':
        return Icons.circle;
      case 'cápsula':
        return Icons.circle_outlined;
      case 'líquido':
        return Icons.water_drop;
      case 'injetável':
        return Icons.vaccines;
      case 'pomada':
        return Icons.healing;
      case 'gotas':
        return Icons.opacity;
      case 'spray':
        return Icons.air;
      default:
        return Icons.medication;
    }
  }
}
