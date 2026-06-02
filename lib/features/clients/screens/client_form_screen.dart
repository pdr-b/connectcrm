import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../data/client.dart';
import '../data/clients_repository.dart';

class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({super.key, required this.repository, this.client});

  final ClientsRepository repository;
  final Client? client;

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}
  
class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = clientStatuses.first;
  DateTime? _nextFollowUp;
  bool _isSaving = false;

  bool get _isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    if (client == null) return;
    _nameController.text = client.name;
    _companyController.text = client.company;
    _phoneController.text = client.phone;
    _emailController.text = client.email;
    _notesController.text = client.notes;
    _status = client.status;
    _nextFollowUp = client.nextFollowUp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextFollowUp ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) setState(() => _nextFollowUp = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final client = Client(
      id: widget.client?.id ?? '',
      name: _nameController.text.trim(),
      company: _companyController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      status: _status,
      nextFollowUp: _nextFollowUp,
      notes: _notesController.text.trim(),
      createdAt: widget.client?.createdAt,
      updatedAt: widget.client?.updatedAt,
    );

    try {
      if (_isEditing) {
        await widget.repository.updateClient(client);
      } else {
        await widget.repository.addClient(client);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel salvar o cliente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar cliente' : 'Novo cliente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionCard(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if ((value?.trim() ?? '').length < 2) {
                          return 'Informe o nome do cliente.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _companyController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Empresa',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status no funil',
                        prefixIcon: Icon(Icons.filter_alt_outlined),
                      ),
                      items: clientStatuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event_available_rounded),
                      label: Text(
                        _nextFollowUp == null
                            ? 'Selecionar proximo follow-up'
                            : 'Follow-up: ${_formatDate(_nextFollowUp!)}',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.purple,
                        minimumSize: const Size.fromHeight(54),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    if (_nextFollowUp != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() => _nextFollowUp = null),
                        child: const Text('Remover data de follow-up'),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notesController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Salvar cliente',
                  icon: Icons.save_rounded,
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172033).withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
