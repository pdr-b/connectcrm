import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/home/main_shell.dart';
import '../shared/widgets/auth_card.dart';

class ConnectCrmApp extends StatelessWidget {
  const ConnectCrmApp({super.key, this.firebaseError});

  final Object? firebaseError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectCRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D5DF7),
          primary: const Color(0xFF6D5DF7),
          secondary: const Color(0xFF2F80ED),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF6D5DF7), width: 1.6),
          ),
        ),
      ),
      home: firebaseError == null
          ? const AuthGate()
          : FirebaseConfigurationScreen(error: firebaseError!),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return MainShell(user: snapshot.data!);
        }

        return const LoginScreen();
      },
    );
  }
}

class FirebaseConfigurationScreen extends StatelessWidget {
  const FirebaseConfigurationScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AuthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D5DF7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Color(0xFF6D5DF7),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Firebase ainda nao configurado',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF20233A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'O app ja esta pronto para usar Firebase Auth. Agora falta conectar este projeto Flutter a um projeto Firebase usando o FlutterFire CLI.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
