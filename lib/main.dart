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
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Mock de lista de medicamentos, será dinâmica no futuro
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
              // Saudação e data
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
              // Card de alerta de medicação
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
              // Lista de medicamentos do dia
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
              // Botões de ações rápidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Novo Medicamento"),
                    onPressed: () {},
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
