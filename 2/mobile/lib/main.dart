import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'theme/app_theme.dart';


class Produto {
  final int? id; 
  final int? serverId; 
  final String nome;
  final double preco;
  final String descricao;

  Produto({
    this.id,
    this.serverId,
    required this.nome,
    required this.preco,
    required this.descricao,
  });

  Produto copyWith({
    int? id,
    int? serverId,
    String? nome,
    double? preco,
    String? descricao,
  }) {
    return Produto(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      descricao: descricao ?? this.descricao,
    );
  }

  factory Produto.fromServerJson(Map<String, dynamic> json) {
    return Produto(
      serverId: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      nome: '${json['nome'] ?? ''}',
      preco: (json['preco'] is num) ? (json['preco'] as num).toDouble() : double.tryParse('${json['preco']}') ?? 0.0,
      descricao: '${json['descricao'] ?? ''}',
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'server_id': serverId,
      'nome': nome,
      'preco': preco,
      'descricao': descricao,
    };
  }

  factory Produto.fromLocalMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'] as int?,
      serverId: map['server_id'] as int?,
      nome: map['nome'] as String? ?? '',
      preco: (map['preco'] is num) ? (map['preco'] as num).toDouble() : double.tryParse('${map['preco']}') ?? 0.0,
      descricao: map['descricao'] as String? ?? '',
    );
  }
}


class RemoteService {
  static const String baseUrl = 'http://10.0.2.2:3001';

  Future<List<Produto>> fetchProdutos() async {
    final uri = Uri.parse('$baseUrl/produtos');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data.map((e) => Produto.fromServerJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Falha ao carregar produtos do servidor (${res.statusCode})');
    }
  }
  
  Future<Produto> addProduto(Produto produto) async {
    final uri = Uri.parse('$baseUrl/produtos');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': produto.nome,
        'preco': produto.preco,
        'descricao': produto.descricao,
      }),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return Produto.fromServerJson(data);
    } else {
      throw Exception('Falha ao adicionar produto no servidor (${res.statusCode})');
    }
  }
  
  Future<Produto> updateProduto(Produto produto) async {
    if (produto.serverId == null) {
      throw Exception('Não é possível atualizar um produto sem ID no servidor');
    }
    
    final uri = Uri.parse('$baseUrl/produtos/${produto.serverId}');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': produto.nome,
        'preco': produto.preco,
        'descricao': produto.descricao,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Produto.fromServerJson(data);
    } else {
      throw Exception('Falha ao atualizar produto no servidor (${res.statusCode})');
    }
  }
  
  Future<bool> deleteProduto(int serverId) async {
    final uri = Uri.parse('$baseUrl/produtos/$serverId');
    final res = await http.delete(uri);

    return res.statusCode == 200;
  }
}

class LocalDb {
  static final LocalDb _instance = LocalDb._internal();
  factory LocalDb() => _instance;
  LocalDb._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'catalogo_local.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            server_id INTEGER,
            nome TEXT NOT NULL,
            preco REAL NOT NULL,
            descricao TEXT
          )
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_produtos_server_id ON produtos(server_id)');
      },
    );
    return _db!;
  }

  Future<List<Produto>> getAll() async {
    final db = await database;
    final result = await db.query('produtos', orderBy: 'id DESC');
    return result.map((e) => Produto.fromLocalMap(e)).toList();
  }

  Future<int> insert(Produto p) async {
    final db = await database;
    return db.insert('produtos', p.toLocalMap()..remove('id'));
  }

  Future<int> update(Produto p) async {
    if (p.id == null) return 0;
    final db = await database;
    return db.update('produtos', p.toLocalMap()..remove('id'), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsertByServerId(List<Produto> serverProdutos) async {
    final db = await database;
    final batch = db.batch();

    for (final sp in serverProdutos) {
      if (sp.serverId == null) {
        batch.insert('produtos', sp.toLocalMap()..remove('id'));
        continue;
      }
      batch.update(
        'produtos',
        sp.toLocalMap()..remove('id'),
        where: 'server_id = ?',
        whereArgs: [sp.serverId],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      batch.insert(
        'produtos',
        sp.toLocalMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> syncBidirecional() async {
    final localProdutos = await getAll();
    
    try {
      final remoteService = RemoteService();
      final remoteProdutos = await remoteService.fetchProdutos();
      
      for (final localProduto in localProdutos) {
        if (localProduto.serverId != null) {
          bool existsOnServer = remoteProdutos.any((p) => p.serverId == localProduto.serverId);
          
          if (existsOnServer) {
            try {
              await remoteService.updateProduto(localProduto);
            } catch (e) {
              print('Erro ao atualizar produto no servidor: $e');
            }
          } else {
            try {
              final novoProdutoRemoto = await remoteService.addProduto(localProduto);
              await update(localProduto.copyWith(serverId: novoProdutoRemoto.serverId));
            } catch (e) {
              print('Erro ao adicionar produto no servidor: $e');
            }
          }
        } else {
          try {
            final novoProdutoRemoto = await remoteService.addProduto(localProduto);
            await update(localProduto.copyWith(serverId: novoProdutoRemoto.serverId));
          } catch (e) {
            print('Erro ao adicionar produto no servidor: $e');
          }
        }
      }
      
      for (final remotoProduto in remoteProdutos) {
        bool existsLocally = localProdutos.any((p) => p.serverId == remotoProduto.serverId);
        
        if (!existsLocally) {
          await insert(remotoProduto);
        }
      }
    } catch (e) {
      print('Erro na sincronização bidirecional: $e');
      rethrow;
    }
  }

  Future<void> updateFromServer(List<Produto> serverProdutos) async {
    await upsertByServerId(serverProdutos);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CatalogApp());
}

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Produtos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ProdutosScreen(),
    );
  }
}

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final _local = LocalDb();

  List<Produto> _produtos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final locais = await _local.getAll();
      setState(() => _produtos = locais);

      await _local.syncBidirecional();

      final atualizados = await _local.getAll();
      setState(() => _produtos = atualizados);
    } catch (e) {
      setState(() => _error = 'Falha ao sincronizar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sync() async {
    try {
      await _local.syncBidirecional();
      
      final atualizados = await _local.getAll();
      setState(() => _produtos = atualizados);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronizado com o servidor!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sincronizar: $e')),
        );
      }
    }
  }

  Future<void> _addOrEdit({Produto? editing}) async {
    final nomeCtrl = TextEditingController(text: editing?.nome ?? '');
    final precoCtrl = TextEditingController(
      text: editing != null ? editing.preco.toStringAsFixed(2) : '',
    );
    final descCtrl = TextEditingController(text: editing?.descricao ?? '');

    final isEdit = editing != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEdit ? 'Editar Produto' : 'Novo Produto',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Digite o nome do produto',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                textInputAction: TextInputAction.next,
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: precoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  hintText: 'Digite o preço (ex: 29.90)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descCtrl,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (nomeCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('O nome do produto é obrigatório!'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }

              Navigator.pop(ctx, true);
            },
            icon: const Icon(Icons.save),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final nome = nomeCtrl.text.trim();
    final preco = double.tryParse(precoCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final desc = descCtrl.text.trim();

    if (nome.isEmpty) return;

    try {
      if (isEdit) {
        final updated = editing.copyWith(nome: nome, preco: preco, descricao: desc);
        await _local.update(updated);
      } else {
        await _local.insert(Produto(nome: nome, preco: preco, descricao: desc));
      }

      final recarregados = await _local.getAll();
      setState(() => _produtos = recarregados);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Produto atualizado com sucesso!' : 'Produto adicionado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      
      try {
        await _sync();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produto salvo localmente, mas houve erro na sincronização: $e'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar produto: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _delete(Produto p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Remover produto',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Tem certeza que deseja remover "${p.nome}"?',
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
    if (confirm != true) return;

    try {
      if (p.id != null) {
        await _local.delete(p.id!);
        
        if (p.serverId != null) {
          try {
            final remote = RemoteService();
            await remote.deleteProduto(p.serverId!);
          } catch (e) {
            print('Erro ao excluir no servidor: $e');
          }
        }
        
        final recarregados = await _local.getAll();
        setState(() => _produtos = recarregados);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto removido com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover produto: ${e.toString()}'),
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
          'Catálogo de Produtos',
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
            tooltip: 'Sincronizar com servidor',
            onPressed: _sync,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _produtos.isEmpty
                  ? _buildEmptyState()
                  : _buildProdutosList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrEdit,
        tooltip: 'Adicionar Produto',
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
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _initLoad,
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
              Icons.inventory_2_outlined,
              size: 120,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhum produto encontrado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Adicione um novo produto para começar!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _addOrEdit,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar primeiro produto'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProdutosList() {
    return RefreshIndicator(
      onRefresh: _initLoad,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: _produtos.length,
        itemBuilder: (context, index) {
          final produto = _produtos[index];
          return _buildProdutoCard(produto);
        },
      ),
    );
  }

  Widget _buildProdutoCard(Produto produto) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppDecoration.radiusSmall),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          produto.nome,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              'R\$ ${produto.preco.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (produto.descricao.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                produto.descricao,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (produto.serverId != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.sync,
                    size: 12,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Sincronizado',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _addOrEdit(editing: produto),
              color: AppColors.iconSecondary,
              tooltip: 'Editar produto',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(produto),
              color: AppColors.iconSecondary,
              tooltip: 'Excluir produto',
            ),
          ],
        ),
      ),
    );
  }
}
