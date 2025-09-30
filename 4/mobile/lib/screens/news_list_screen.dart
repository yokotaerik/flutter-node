import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<Article> articles = [];
  Set<int> favoriteIds = {};
  bool isLoading = true;
  String? errorMessage;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedArticles = await ApiService.fetchNoticias();
      final favoritos = await _databaseService.getFavoritos();
      final favoriteIdsSet = favoritos.map((article) => article.id).toSet();
      if (!mounted) return;
      setState(() {
        articles = fetchedArticles;
        favoriteIds = favoriteIdsSet;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Article article) async {
    try {
      if (favoriteIds.contains(article.id)) {
        await _databaseService.removeFavorito(article.id);
        setState(() {
          favoriteIds.remove(article.id);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removido dos favoritos'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await _databaseService.addFavorito(article);
        setState(() {
          favoriteIds.add(article.id);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicionado aos favoritos'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar favoritos: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notícias'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notícias'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: Center(child: Text('Erro: ${errorMessage!}')),
      );
    }
    if (articles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notícias'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: const Center(child: Text('Nenhuma notícia encontrada.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notícias'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          final isFavorite = favoriteIds.contains(article.id);
          return ListTile(
            title: Text(article.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Por: ${article.autor}\n${article.conteudo}'),
            isThreeLine: true,
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(article),
            ),
          );
        },
      ),
    );
  }
}