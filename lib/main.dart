import 'package:flutter/material.dart';
import 'package:medi_time/core/theme.dart';
import 'package:medi_time/screens/login_screen.dart';
import 'package:medi_time/screens/meds_list_screen.dart';
import 'package:medi_time/screens/calendar_screen.dart';
import 'package:medi_time/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medi_time/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.initialize();

  runApp(const ProviderScope(child: MediTimeApp()));
}

class MediTimeApp extends StatelessWidget {
  const MediTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTime',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/meds': (context) => const MedsListScreen(),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MediTime Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HomeButton(
              icon: Icons.medication,
              label: 'Meus Remédios',
              onTap: () => Navigator.pushNamed(context, '/meds'),
            ),
            const SizedBox(height: 16),
            _HomeButton(
              icon: Icons.calendar_month,
              label: 'Calendário',
              onTap: () => Navigator.pushNamed(context, '/calendar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
