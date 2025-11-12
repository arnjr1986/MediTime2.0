import 'package:flutter/material.dart';

void main() {
  runApp(const MediTimeApp());
}

class MediTimeApp extends StatelessWidget {
  const MediTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTime',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
      routes: {
        '/cadastro': (context) => const CadastroMedicamentoScreen(),
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Map<String, String>> medicamentos = const [
    {
      "nome": "Atenolol",
      "hora": "14:00",
      "dose": "1 comprimido",
    },
    {
      "nome": "Amoxicilina",
      "hora": "19:00",
      "dose": "2 cápsulas",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - MediTime'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Olá, Usuário 👋",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                "Hoje: 12/11/2025",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.red[50],
                child: ListTile(
                  leading: Icon(Icons.medication, color: Colors.redAccent),
                  title: Text("Lembrete: Tome Atenolol às 14:00"),
                  subtitle: Text("Dose: 1 comprimido"),
                  trailing: Icon(Icons.notifications_active, color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Medicamentos de Hoje:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...medicamentos.map((med) => Card(
                    elevation: 0,
                    color: Colors.indigo[50],
                    child: ListTile(
                      leading: Icon(Icons.medication_outlined, color: Colors.indigo),
                      title: Text(med['nome'] ?? ''),
                      subtitle: Text("Hora: ${med['hora']} | Dose: ${med['dose']}"),
                      trailing: Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Novo Medicamento"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text("Histórico"),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Mais alertas e resumo serão exibidos aqui...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CadastroMedicamentoScreen extends StatefulWidget {
  const CadastroMedicamentoScreen({super.key});

  @override
  _CadastroMedicamentoScreenState createState() => _CadastroMedicamentoScreenState();
}

class _CadastroMedicamentoScreenState extends State<CadastroMedicamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _horaController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Aqui você pode processar os dados do formulário (exibir, salvar, etc)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Medicamento'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Medicamento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora (ex: 14:00)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe a hora' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'Dose',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe a dose' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
