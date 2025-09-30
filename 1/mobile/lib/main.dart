import 'package:flutter/material.dart';
import 'package:ex1/models/tarefa.dart';
import 'package:ex1/services/tarefa_service.dart';
import 'package:ex1/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TarefasScreen(),
    );
  }
}

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final TarefaService _tarefaService = TarefaService();
  List<Tarefa> _tarefas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTarefas();
  }

  Future<void> _loadTarefas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tarefas = await _tarefaService.getTarefas();
      setState(() {
        _tarefas = tarefas;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar tarefas: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addTarefa() async {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nova Tarefa',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título da tarefa',
                prefixIcon: Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Digite uma descrição (opcional)',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (tituloController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('O título é obrigatório'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              try {
                await _tarefaService.createTarefa(
                  tituloController.text.trim(),
                  descricaoController.text.trim(),
                );
                await _loadTarefas();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarefa adicionada com sucesso!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao adicionar tarefa: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTarefaConcluida(Tarefa tarefa) async {
    try {
      final atualizada = tarefa.copyWith(concluida: !tarefa.concluida);
      await _tarefaService.updateTarefa(atualizada);
      await _loadTarefas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar tarefa: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteTarefa(Tarefa tarefa) async {
    try {
      await _tarefaService.deleteTarefa(tarefa.id);
      await _loadTarefas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa removida com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover tarefa: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gerenciador de Tarefas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _tarefas.isEmpty
                  ? _buildEmptyState()
                  : _buildTarefasList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTarefa,
        tooltip: 'Adicionar Tarefa',
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        child: const Icon(Icons.add),
      ),
    );
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
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Verifique se o servidor da API está em execução e tente novamente.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _loadTarefas,
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
              Icons.task_alt,
              size: 120,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhuma tarefa encontrada',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Adicione uma nova tarefa para começar!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _addTarefa,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar primeira tarefa'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarefasList() {
    return RefreshIndicator(
      onRefresh: _loadTarefas,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: _tarefas.length,
        itemBuilder: (context, index) {
          final tarefa = _tarefas[index];
          return _buildTarefaCard(tarefa);
        },
      ),
    );
  }

  Widget _buildTarefaCard(Tarefa tarefa) {
    return Dismissible(
      key: Key(tarefa.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDecoration.radiusMedium),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(tarefa),
      onDismissed: (_) => _deleteTarefa(tarefa),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          leading: Checkbox(
            value: tarefa.concluida,
            onChanged: (_) => _toggleTarefaConcluida(tarefa),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            tarefa.titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
              color: tarefa.concluida ? AppColors.onSurfaceVariant : AppColors.onSurface,
            ),
          ),
          subtitle: tarefa.descricao.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    tarefa.descricao,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tarefa.concluida ? AppColors.onSurfaceVariant : AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(tarefa).then((confirmed) {
              if (confirmed == true) _deleteTarefa(tarefa);
            }),
            color: AppColors.iconSecondary,
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(Tarefa tarefa) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Remover tarefa',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Tem certeza que deseja remover "${tarefa.titulo}"?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

extension TarefaCopy on Tarefa {
  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    bool? concluida,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      dataCriacao: dataCriacao,
    );
  }
}
