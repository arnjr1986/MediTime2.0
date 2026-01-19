import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../data/models/medication_model.dart';
import '../providers/medication_provider.dart';

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
  final _qtyPerDoseController = TextEditingController(); // Start with 1
  final _doctorController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  // Color
  late int _assignedColor;

  // State variables
  String? _selectedType = 'Comprimido';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isContinuous = false;
  String? _imagePath;
  String _scheduleMode = 'fixed'; // fixed, interval
  double _intervalHours = 8;
  List<TimeOfDay> _fixedTimes = [
    const TimeOfDay(hour: 8, minute: 0),
  ]; // Default 8am
  final List<bool> _daysSelected = List.filled(7, true); // Mon-Sun

  final List<String> _commonMeds = [
    'Paracetamol',
    'Dipirona',
    'Ibuprofeno',
    'Omeprazol',
    'Simeticona',
    'Amoxicilina',
    'Losartana',
    'Metformina',
    'Novalgina',
    'Dorflex',
  ];
  final List<String> _types = [
    'Comprimido',
    'Cápsula',
    'Líquido (ml)',
    'Gotas',
    'Spray',
    'Injeção',
    'Pomada',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      // Load existing data
      final m = widget.medication!;
      _nameController.text = m.name;
      _dosageController.text = m.dosage;
      _selectedType = m.type;
      _totalQtyController.text = m.totalQuantity.toString();
      _qtyPerDoseController.text = m.quantityPerDose.toString();
      _doctorController.text = m.doctorName ?? '';
      _reasonController.text = m.reason ?? '';
      _notesController.text = m.notes ?? '';
      _startDate = m.startDate;
      _endDate = m.endDate;
      _isContinuous = m.endDate == null;
      _imagePath = m.imagePath;

      _scheduleMode = m.scheduleMode;
      _intervalHours = m.intervalHours?.toDouble() ?? 8;
      _assignedColor = m.color;

      if (m.timeList.isNotEmpty) {
        _fixedTimes = m.timeList.map((t) {
          final parts = t.split(':');
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }).toList();
      } else {
        _fixedTimes = [const TimeOfDay(hour: 8, minute: 0)]; // Default if empty
      }

      // Restore days selected
      _daysSelected.fillRange(0, 7, false);
      for (final day in m.daysOfWeek) {
        if (day >= 1 && day <= 7) _daysSelected[day - 1] = true;
      }
    } else {
      _qtyPerDoseController.text = '1';
      // Assign random pastel color
      final random = Random();
      final pastels = [
        0xFFEF9A9A,
        0xFF90CAF9,
        0xFFA5D6A7,
        0xFFFFF59D,
        0xFFCE93D8,
        0xFFFFCC80,
        0xFF80CBC4,
        0xFFB39DDB,
      ];
      _assignedColor = pastels[random.nextInt(pastels.length)];
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
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
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Check days selected
    if (!_daysSelected.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um dia da semana')),
      );
      return;
    }

    if (_fixedTimes.isEmpty && _scheduleMode == 'fixed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um horário')),
      );
      return;
    }

    List<String> timeList = _scheduleMode == 'fixed'
        ? _fixedTimes
              .map(
                (t) =>
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
              )
              .toList()
        : [];

    // Convert boolean list to days logic (1-7)
    final daysOfWeek = <int>[];
    for (int i = 0; i < 7; i++) {
      if (_daysSelected[i]) daysOfWeek.add(i + 1);
    }

    final newMed = Medication(
      id: widget.medication?.id,
      name: _nameController.text,
      dosage: _dosageController.text,
      type: _selectedType ?? 'Comprimido',
      totalQuantity: int.tryParse(_totalQtyController.text) ?? 0,
      quantityPerDose: int.tryParse(_qtyPerDoseController.text) ?? 1,
      remainingQuantity: widget.medication?.remainingQuantity,
      color: _assignedColor,
      doctorName: _doctorController.text,
      reason: _reasonController.text,
      startDate: _startDate,
      endDate: _isContinuous ? null : _endDate,
      notes: _notesController.text,
      imagePath: _imagePath,
      scheduleMode: _scheduleMode,
      intervalHours: _scheduleMode == 'interval'
          ? _intervalHours.toInt()
          : null,
      timeList: timeList,
      daysOfWeek: daysOfWeek,
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

  String _getStockPreview() {
    int total = int.tryParse(_totalQtyController.text) ?? 0;
    int perDose = int.tryParse(_qtyPerDoseController.text) ?? 1;
    if (total <= 0 || perDose <= 0) return '';

    // doses available
    int dosesAvailable = total ~/ perDose;

    // Estimate daily usage
    int dosesPerDay = 1;
    if (_scheduleMode == 'fixed') {
      dosesPerDay = _fixedTimes.length;
    } else {
      dosesPerDay = (24 / _intervalHours).floor();
    }
    if (dosesPerDay < 1) dosesPerDay = 1;

    int daysDuration = dosesAvailable ~/ dosesPerDay;
    return 'Estimativa: Dá para aprox. $daysDuration dias';
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

              // Stock Preview Real-time
              ValueListenableBuilder(
                valueListenable: _totalQtyController,
                builder: (ctx, val, _) {
                  final txt = _getStockPreview();
                  if (txt.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: Text(
                      txt,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              Autocomplete<String>(
                optionsBuilder: (text) => _commonMeds.where(
                  (e) => e.toLowerCase().contains(text.text.toLowerCase()),
                ),
                onSelected: (val) => _nameController.text = val,
                fieldViewBuilder: (context, controller, node, onSubmitted) {
                  if (_nameController.text.isNotEmpty &&
                      controller.text.isEmpty) {
                    controller.text = _nameController.text;
                  }
                  return TextFormField(
                    controller: controller,
                    focusNode: node,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Medicamento *',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ), // Larger
                    ),
                    style: const TextStyle(fontSize: 18), // Larger
                    validator: (v) => (v == null || v.length < 3)
                        ? 'Mínimo 3 caracteres'
                        : null,
                    onChanged: (v) => _nameController.text = v,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      items: _types
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosagem (ex: 500mg) *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalQtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Qtd Total (Estoque)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (int.tryParse(v ?? '') ?? 0) <= 0 ? '> 0' : null,
                      onChanged: (_) =>
                          setState(() {}), // trigger rebuild for preview
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyPerDoseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Qtd / Dose',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (int.tryParse(v ?? '') ?? 0) <= 0 ? '> 0' : null,
                      onChanged: (_) =>
                          setState(() {}), // trigger rebuild for preview
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Prescription
              Text(
                'Prescrição (Opcional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (_imagePath != null)
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: kIsWeb
                      ? Image.network(_imagePath!, fit: BoxFit.cover)
                      : Image.file(File(_imagePath!), fit: BoxFit.cover),
                ),
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Adicionar Foto Receita/Med'),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Médico Prescritor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo / Indicação',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

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
                        decoration: const InputDecoration(
                          labelText: 'Início',
                          border: OutlineInputBorder(),
                        ),
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
                            decoration: InputDecoration(
                              labelText: 'Fim',
                              border: OutlineInputBorder(),
                            ),
                            child: Text('Contínuo'),
                          )
                        : InkWell(
                            onTap: () => _selectDate(false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fim',
                                border: OutlineInputBorder(),
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
                  final days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                  return FilterChip(
                    label: Text(days[index]),
                    selected: _daysSelected[index],
                    showCheckmark: false,
                    onSelected: (v) => setState(() => _daysSelected[index] = v),
                    selectedColor: Color(_assignedColor).withValues(alpha: 0.5),
                  );
                }),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55, // Larger button
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                      _assignedColor,
                    ), // Use assigned color
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
