import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
 
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../clients/data/client.dart';
import '../clients/data/clients_repository.dart';
import '../clients/screens/client_detail_screen.dart';
import '../clients/screens/client_form_screen.dart';
import '../clients/widgets/client_list_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.repository,
    required this.clients,
    required this.isLoading,
    required this.hasError,
  });

  final User user;
  final ClientsRepository repository;
  final List<Client> clients;
  final bool isLoading;
  final bool hasError;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Client> get _filteredClients {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.clients;
    return widget.clients.where((client) {
      return client.name.toLowerCase().contains(query) ||
          client.company.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _logout() {
    return FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user.displayName?.trim();
    final greetingName = name?.isNotEmpty == true ? name! : 'usuário';
    final filteredClients = _filteredClients;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ClientFormScreen(repository: widget.repository),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.purple, AppColors.blue],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded),
                          tooltip: 'Sair',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Olá, $greetingName',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gerencie seus clientes com facilidade',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nome ou empresa',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Clientes',
                            value: '${widget.clients.length}',
                            icon: Icons.groups_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Fechados',
                            value:
                                '${widget.clients.where((c) => c.status == 'Fechado').length}',
                            icon: Icons.check_circle_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          'Clientes cadastrados',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ClientFormScreen(
                                  repository: widget.repository,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Adicionar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (widget.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (widget.hasError)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Não foi possível carregar',
                  message: 'Confira sua conexão e as regras do Firestore.',
                ),
              )
            else if (filteredClients.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: _query.isEmpty
                      ? Icons.person_add_alt_rounded
                      : Icons.search_off_rounded,
                  title: _query.isEmpty
                      ? 'Nenhum cliente ainda'
                      : 'Nenhum resultado',
                  message: _query.isEmpty
                      ? 'Cadastre o primeiro cliente para começar seu CRM.'
                      : 'Tente buscar por outro nome ou empresa.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                sliver: SliverList.separated(
                  itemCount: filteredClients.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    return ClientListTile(
                      client: client,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClientDetailScreen(
                              client: client,
                              repository: widget.repository,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.purple),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
