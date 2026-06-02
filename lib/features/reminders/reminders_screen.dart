import 'package:flutter/material.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../clients/data/client.dart';
import '../clients/data/clients_repository.dart';
import '../clients/screens/client_detail_screen.dart';
import '../clients/widgets/status_chip.dart';
 
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({
    super.key,
    required this.clients,
    required this.repository,
    required this.isLoading,
  });

  final List<Client> clients;
  final ClientsRepository repository;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final reminders =
        clients.where((client) => client.nextFollowUp != null).toList()
          ..sort((a, b) => a.nextFollowUp!.compareTo(b.nextFollowUp!));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lembretes',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Próximos follow-ups cadastrados',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                    const SizedBox(height: 22),
                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.event_available_rounded,
                              color: AppColors.purple,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${reminders.length} follow-ups',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Organizados por data',
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (reminders.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.notifications_off_rounded,
                  title: 'Sem lembretes',
                  message:
                      'Adicione uma data de follow-up no cadastro do cliente.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList.separated(
                  itemCount: reminders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final client = reminders[index];
                    return AppCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClientDetailScreen(
                              client: client,
                              repository: repository,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: _isOverdue(client.nextFollowUp!)
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : AppColors.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.event_note_rounded,
                              color: _isOverdue(client.nextFollowUp!)
                                  ? Colors.red
                                  : AppColors.blue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        client.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    StatusChip(status: client.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(client.nextFollowUp!),
                                  style: TextStyle(
                                    color: _isOverdue(client.nextFollowUp!)
                                        ? Colors.red
                                        : AppColors.blue,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  client.notes.isEmpty
                                      ? 'Sem observações.'
                                      : client.notes,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isOverdue(DateTime date) {
    final today = DateTime.now();
    final currentDay = DateTime(today.year, today.month, today.day);
    final followUpDay = DateTime(date.year, date.month, date.day);
    return followUpDay.isBefore(currentDay);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
