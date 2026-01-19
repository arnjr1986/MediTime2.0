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
                Color stockColor;

                switch (med.stockStatus) {
                  case 'CRITICAL':
                    stockColor = Colors.red;
                    break;
                  case 'LOW':
                    stockColor = Colors.orange;
                    break;
                  case 'SURPLUS':
                    stockColor = Colors.green;
                    break;
                  default:
                    stockColor = Colors.blue;
                }

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(color: Color(med.color), width: 6),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Color(med.color).withAlpha(50),
                            child: Icon(
                              _getIconForType(med.type),
                              color: Color(med.color),
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
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: stockColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: stockColor.withAlpha(100),
                                  ),
                                ),
                                child: Text(
                                  med.stockDescription,
                                  style: TextStyle(
                                    color: stockColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: "Tomar Dose (-${med.quantityPerDose})",
                            icon: Icon(
                              Icons.medication_liquid,
                              color: Color(med.color),
                              size: 32,
                            ),
                            onPressed: () {
                              ref
                                  .read(medicationProvider.notifier)
                                  .takeDose(med.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Dose registrada!")),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 8.0,
                            bottom: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("EDITAR"),
                                onPressed: () => _openForm(context, med: med),
                              ),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                label: const Text(
                                  "EXCLUIR",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  ref
                                      .read(medicationProvider.notifier)
                                      .deleteMedication(med.id!);
                                },
                              ),
                            ],
                          ),
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
