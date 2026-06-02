import 'package:flutter/material.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../clients/data/client.dart';
import '../clients/widgets/status_chip.dart';

class SalesFunnelScreen extends StatelessWidget {
  const SalesFunnelScreen({
    super.key,
    required this.clients,
    required this.isLoading,
  });

  final List<Client> clients;
  final bool isLoading;
 
  @override
  Widget build(BuildContext context) {
    final total = clients.length;
    final closed = clients.where((client) => client.status == 'Fechado').length;
    final conversion = total == 0 ? 0 : (closed / total * 100).round();

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
                      'Funil de vendas',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Acompanhe seus clientes por etapa',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                    const SizedBox(height: 22),
                    AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: _BigMetric(
                              label: 'Pipeline',
                              value: '$total',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 54,
                            color: AppColors.border,
                          ),
                          Expanded(
                            child: _BigMetric(
                              label: 'Conversão',
                              value: '$conversion%',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StageCounter(
                            label: 'Novo Lead',
                            count: _countByStatus('Novo Lead'),
                            color: AppColors.purple,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StageCounter(
                            label: 'Negociação',
                            count: _countByStatus('Negociação'),
                            color: AppColors.amber,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StageCounter(
                            label: 'Fechado',
                            count: closed,
                            color: AppColors.green,
                          ),
                        ),
                      ],
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
            else if (clients.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.filter_alt_off_rounded,
                  title: 'Funil vazio',
                  message: 'Cadastre clientes para acompanhar o pipeline.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StageSection(
                      title: 'Novo Lead',
                      clients: _clientsByStatus('Novo Lead'),
                    ),
                    const SizedBox(height: 18),
                    _StageSection(
                      title: 'Negociação',
                      clients: _clientsByStatus('Negociação'),
                    ),
                    const SizedBox(height: 18),
                    _StageSection(
                      title: 'Fechado',
                      clients: _clientsByStatus('Fechado'),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _countByStatus(String status) {
    return clients.where((client) => client.status == status).length;
  }

  List<Client> _clientsByStatus(String status) {
    return clients.where((client) => client.status == status).toList();
  }
}

class _BigMetric extends StatelessWidget {
  const _BigMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StageCounter extends StatelessWidget {
  const _StageCounter({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageSection extends StatelessWidget {
  const _StageSection({required this.title, required this.clients});

  final String title;
  final List<Client> clients;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(status: title),
              const Spacer(),
              Text(
                '${clients.length}',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (clients.isEmpty)
            const Text(
              'Nenhum cliente nesta etapa.',
              style: TextStyle(color: AppColors.muted),
            )
          else
            ...clients.map(
              (client) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppColors.purple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${client.name} · ${client.company.isEmpty ? 'Sem empresa' : client.company}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
