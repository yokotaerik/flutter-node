import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import 'contact_form_screen.dart';
import '../theme/app_theme.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactService _contactService = ContactService();
  List<Contact> _contacts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contacts = await _contactService.getAllContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _syncContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _contactService.syncWithApi();
      final contacts = await _contactService.getAllContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contatos sincronizados com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na sincronização: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remover contato',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Tem certeza que deseja remover "${contact.nome}"?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _contactService.deleteContact(contact.id);
        await _loadContacts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contato removido com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao remover contato: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _editContact(Contact contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactFormScreen(contact: contact),
      ),
    ).then((_) => _loadContacts());
  }

  void _addContact() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ContactFormScreen(),
      ),
    ).then((_) => _loadContacts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gerenciador de Contatos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _isLoading ? null : _syncContacts,
            tooltip: 'Sincronizar com servidor',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        tooltip: 'Adicionar Contato',
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_contacts.isEmpty) {
      return _buildEmptyState();
    }

    return _buildContactsList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Ops! Algo deu errado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _loadContacts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 120,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhum contato encontrado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Adicione um novo contato para começar!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _addContact,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar primeiro contato'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return RefreshIndicator(
      onRefresh: _loadContacts,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return _buildContactCard(contact);
        },
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            contact.nome.isNotEmpty ? contact.nome[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.nome,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColors.iconSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  contact.telefone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            if (contact.email.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16,
                    color: AppColors.iconSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      contact.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editContact(contact);
            } else if (value == 'delete') {
              _deleteContact(contact);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Editar'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Excluir'),
                dense: true,
              ),
            ),
          ],
        ),
        onTap: () => _editContact(contact),
      ),
    );
  }
}