import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medi_time/data/models/medication_model.dart';
import 'package:medi_time/providers/medication_provider.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  final Medication? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _totalQtyController = TextEditingController();
  final _qtyPerDoseController = TextEditingController();
  final _doctorController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  // State variables
  String _selectedType = 'Comprimido';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isContinuous = false;
  File? _imageFile;
  String _scheduleMode = 'fixed'; // fixed, interval
  double _intervalHours = 8;
  List<TimeOfDay> _fixedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  final List<bool> _daysSelected = List.filled(7, true); // Mon-Sun

  final List<String> _commonMeds = [
    'Paracetamol',
    'Ibuprofeno',
    'Dipirona',
    'Amoxicilina',
    'Omeprazol',
    'Losartana',
  ];
  final List<String> _types = [
    'Comprimido',
    'Cápsula',
    'Líquido',
    'Injetável',
    'Pomada',
    'Gotas',
    'Spray',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      // Load existing data
      final med = widget.medication!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      _selectedType = med.type;
      _totalQtyController.text = med.totalQuantity.toString();
      _qtyPerDoseController.text = med.quantityPerDose.toString();
      _doctorController.text = med.doctorName ?? '';
      _reasonController.text = med.reason ?? '';
      _notesController.text = med.notes ?? '';
      _startDate = med.startDate;
      _endDate = med.endDate;
      _isContinuous = med.endDate == null;
      if (med.imagePath != null) _imageFile = File(med.imagePath!);

      _scheduleMode = med.scheduleMode;
      _intervalHours = (med.intervalHours ?? 8).toDouble();

      _fixedTimes = med.timeList.map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();

      // Map daysOfWeek (1-7) to _daysSelected (0-6)
      _daysSelected.fillRange(0, 7, false);
      for (final day in med.daysOfWeek) {
        if (day >= 1 && day <= 7) _daysSelected[day - 1] = true;
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    ); // Or gallery
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addFixedTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      setState(() {
        _fixedTimes.add(picked);
        _fixedTimes.sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
        );
      });
    }
  }

  void _selectDate(bool isStart) async {
    final initial = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate))
            _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_fixedTimes.isEmpty && _scheduleMode == 'fixed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um horário')),
      );
      return;
    }
    if (!_daysSelected.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um dia da semana')),
      );
      return;
    }

    // Convert fixed times to List<String>
    List<String> timeList = [];
    if (_scheduleMode == 'fixed') {
      timeList = _fixedTimes
          .map(
            (t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
          )
          .toList();
    } else {
      // For interval, calculate times starting from startDate 8:00 (simplification)
      // or just store the interval and handle display logic.
      // Requirements say "fixo multi time_picker OU slider".
      // Let's store empty timeList for interval or generate some base times?
      // Model expects timeList for compatibility, but logic handles scheduleMode.
      timeList = ['08:00']; // Default start for interval
    }

    final days = <int>[];
    for (int i = 0; i < 7; i++) {
      if (_daysSelected[i]) days.add(i + 1);
    }

    final newMed = Medication(
      id: widget.medication?.id,
      name: _nameController.text,
      dosage: _dosageController.text,
      type: _selectedType,
      totalQuantity: int.tryParse(_totalQtyController.text) ?? 0,
      quantityPerDose: int.tryParse(_qtyPerDoseController.text) ?? 1,
      doctorName: _doctorController.text,
      reason: _reasonController.text,
      startDate: _startDate,
      endDate: _isContinuous ? null : _endDate,
      notes: _notesController.text,
      imagePath: _imageFile?.path,
      scheduleMode: _scheduleMode,
      intervalHours: _scheduleMode == 'interval'
          ? _intervalHours.round()
          : null,
      timeList: timeList,
      daysOfWeek: days,
    );

    if (widget.medication == null) {
      ref.read(medicationProvider.notifier).addMedication(newMed);
    } else {
      ref.read(medicationProvider.notifier).updateMedication(newMed);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Medicamento ${widget.medication == null ? 'adicionado' : 'atualizado'} com sucesso!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medication == null ? 'Novo Medicamento' : 'Editar Medicamento',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Basic Info
              Text(
                'Informações Básicas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (text) => _commonMeds.where(
                  (e) => e.toLowerCase().contains(text.text.toLowerCase()),
                ),
                onSelected: (val) => _nameController.text = val,
                fieldViewBuilder: (context, controller, node, onSubmitted) {
                  if (_nameController.text.isNotEmpty &&
                      controller.text.isEmpty)
                    controller.text = _nameController.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: node,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Medicamento *',
                    ),
                    validator: (v) => (v == null || v.length < 3)
                        ? 'Mínimo 3 caracteres'
                        : null,
                    onChanged: (v) => _nameController.text = v,
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: _types
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                      decoration: const InputDecoration(labelText: 'Tipo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosagem (ex: 500mg) *',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalQtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qtd Total'),
                      validator: (v) =>
                          (int.tryParse(v ?? '') ?? 0) <= 0 ? '> 0' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyPerDoseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Qtd / Dose',
                      ),
                      validator: (v) =>
                          (int.tryParse(v ?? '') ?? 0) <= 0 ? '> 0' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Prescription
              Text(
                'Prescrição (Opcional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (_imageFile != null)
                SizedBox(
                  height: 150,
                  child: kIsWeb
                      ? Image.network(_imageFile!.path)
                      : Image.file(_imageFile!),
                ),
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Adicionar Foto Receita/Med'),
                onPressed: _pickImage,
              ),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Médico Prescritor',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo / Indicação',
                ),
              ),
              const SizedBox(height: 16),

              // 3. Treatment Duration
              Text(
                'Duração Tratamento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Início'),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_startDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _isContinuous
                        ? const InputDecorator(
                            decoration: InputDecoration(labelText: 'Fim'),
                            child: Text('Contínuo'),
                          )
                        : InkWell(
                            onTap: () => _selectDate(false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fim',
                              ),
                              child: Text(
                                _endDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                    : 'Selecione',
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Uso Contínuo'),
                value: _isContinuous,
                onChanged: (v) => setState(() => _isContinuous = v),
              ),
              const SizedBox(height: 16),

              // 4. Schedule
              Text(
                'Horários & Frequência',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'fixed', label: Text('Horários Fixos')),
                  ButtonSegment(
                    value: 'interval',
                    label: Text('Intervalo (Horas)'),
                  ),
                ],
                selected: {_scheduleMode},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _scheduleMode = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (_scheduleMode == 'fixed') ...[
                Wrap(
                  spacing: 8,
                  children: _fixedTimes
                      .map(
                        (t) => Chip(
                          label: Text(t.format(context)),
                          onDeleted: () =>
                              setState(() => _fixedTimes.remove(t)),
                        ),
                      )
                      .toList(),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Adicionar Horário'),
                  onPressed: _addFixedTime,
                ),
              ] else ...[
                Text('A cada ${_intervalHours.round()} horas'),
                Slider(
                  value: _intervalHours,
                  min: 1,
                  max: 24,
                  divisions: 23,
                  label: '${_intervalHours.round()}h',
                  onChanged: (v) => setState(() => _intervalHours = v),
                ),
              ],
              const SizedBox(height: 12),
              const Text('Dias da Semana'),
              Wrap(
                spacing: 5,
                children: List.generate(7, (index) {
                  final days = [
                    'S',
                    'T',
                    'Q',
                    'Q',
                    'S',
                    'S',
                    'D',
                  ]; // Mon starts index 0? Logic: 1=Mon
                  // Using standard Mon-Sun sequence for checkbox row.
                  return FilterChip(
                    label: Text(days[index]),
                    selected: _daysSelected[index],
                    showCheckmark: false,
                    onSelected: (v) => setState(() => _daysSelected[index] = v),
                  );
                }),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SALVAR RECEITA'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
