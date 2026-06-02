import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
 
import '../clients/data/client.dart';
import '../clients/data/clients_repository.dart';
import '../dashboard/dashboard_screen.dart';
import '../funnel/sales_funnel_screen.dart';
import '../reminders/reminders_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user});

  final User user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final repository = ClientsRepository(userId: widget.user.uid);

    return StreamBuilder<List<Client>>(
      stream: repository.watchClients(),
      builder: (context, snapshot) {
        final clients = snapshot.data ?? const <Client>[];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final screens = [
          DashboardScreen(
            user: widget.user,
            repository: repository,
            clients: clients,
            isLoading: isLoading,
            hasError: hasError,
          ),
          SalesFunnelScreen(clients: clients, isLoading: isLoading),
          RemindersScreen(
            clients: clients,
            repository: repository,
            isLoading: isLoading,
          ),
        ];

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.filter_alt_outlined),
                selectedIcon: Icon(Icons.filter_alt_rounded),
                label: 'Funil',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_rounded),
                selectedIcon: Icon(Icons.notifications_rounded),
                label: 'Lembretes',
              ),
            ],
          ),
        );
      },
    );
  }
}
