import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../data/client.dart';
import '../data/client_interaction.dart';
import '../data/clients_repository.dart';
import '../widgets/status_chip.dart';
import 'client_form_screen.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({
    super.key,
    required this.client,
    required this.repository,
  });

  final Client client;
  final ClientsRepository repository;

  Future<void> _addInteraction(BuildContext context) async {
    final interaction = await showDialog<ClientInteraction>(
      context: context,
      builder: (context) => const _InteractionDialog(),
    );

    if (interaction == null) return;

    try {
      await repository.addInteraction(client.id, interaction);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel registrar a interação.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _delete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir cliente?'),
        content: Text('Esta ação remove ${client.name} do CRM.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await repository.deleteClient(client.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel excluir o cliente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe do cliente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ClientFormScreen(repository: repository, client: client),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar',
          ),
          IconButton(
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Excluir',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(status: client.status),
                    const SizedBox(height: 18),
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      client.company.isEmpty ? 'Sem empresa' : client.company,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Telefone',
                      value: client.phone,
                    ),
                    _DetailRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'E-mail',
                      value: client.email,
                    ),
                    _DetailRow(
                      icon: Icons.event_available_rounded,
                      label: 'Próximo follow-up',
                      value: client.nextFollowUp == null
                          ? ''
                          : _formatDate(client.nextFollowUp!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Observações',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      client.notes.isEmpty
                          ? 'Nenhuma observação cadastrada.'
                          : client.notes,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _addInteraction(context),
                icon: const Icon(Icons.add_comment_rounded),
                label: const Text('Registrar interação'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _InteractionHistory(clientId: client.id, repository: repository),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Editar cliente',
                icon: Icons.edit_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ClientFormScreen(
                        repository: repository,
                        client: client,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _InteractionHistory extends StatelessWidget {
  const _InteractionHistory({required this.clientId, required this.repository});

  final String clientId;
  final ClientsRepository repository;

  Future<void> _delete(
    BuildContext context,
    ClientInteraction interaction,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir interação?'),
        content: const Text('Esta ação remove o registro do histórico.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await repository.deleteInteraction(clientId, interaction.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel excluir a interação.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: StreamBuilder<List<ClientInteraction>>(
        stream: repository.watchInteractions(clientId),
        builder: (context, snapshot) {
          final interactions = snapshot.data ?? const <ClientInteraction>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Histórico de interações',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                const Text(
                  'Não foi possível carregar o histórico.',
                  style: TextStyle(color: AppColors.muted),
                )
              else if (interactions.isEmpty)
                const Text(
                  'Nenhuma interação registrada.',
                  style: TextStyle(color: AppColors.muted),
                )
              else
                ...interactions.map(
                  (interaction) => _InteractionTile(
                    interaction: interaction,
                    onDelete: () => _delete(context, interaction),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InteractionTile extends StatelessWidget {
  const _InteractionTile({required this.interaction, required this.onDelete});

  final ClientInteraction interaction;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.history_rounded, color: AppColors.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interaction.type,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  interaction.notes,
                  style: const TextStyle(color: AppColors.muted, height: 1.35),
                ),
                if (interaction.createdAt != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    _formatDateTime(interaction.createdAt!),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.muted,
            tooltip: 'Excluir interação',
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} às $hour:$minute';
  }
}

class _InteractionDialog extends StatefulWidget {
  const _InteractionDialog();

  @override
  State<_InteractionDialog> createState() => _InteractionDialogState();
}

class _InteractionDialogState extends State<_InteractionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  String _type = interactionTypes.first;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ClientInteraction(
        id: '',
        type: _type,
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar interação'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: interactionTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return 'Descreva a interação.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? 'Não informado' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
