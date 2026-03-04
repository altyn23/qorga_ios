import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _Article {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final DateTime? publishedAt;

  const _Article({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
  });
}

class _NewsScreenState extends State<NewsScreen> {
  bool _loading = true;
  String? _errorText;
  final TextEditingController _queryController =
      TextEditingController(text: 'психология подростков буллинг стресс');
  List<_Article> _articles = const [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final uri = Uri.parse('$apiBaseUrl/content/articles').replace(
        queryParameters: {
          'q': _queryController.text.trim().isEmpty
              ? 'психология подростков буллинг стресс'
              : _queryController.text.trim(),
          'lang': 'ru',
          'max': '20',
        },
      );

      final res = await http.get(uri);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || body['ok'] != true) {
        throw Exception(body['error']?.toString() ?? 'Failed to load articles');
      }

      final rawItems = (body['items'] as List?) ?? [];
      final parsed = rawItems
          .map((raw) {
            final m = raw as Map<String, dynamic>;
            final url = (m['url'] ?? '').toString();
            if (url.isEmpty) return null;
            return _Article(
              title: (m['title'] ?? 'Untitled').toString(),
              description: (m['description'] ?? '').toString(),
              url: url,
              imageUrl: (m['imageUrl'] ?? '').toString(),
              source: (m['source'] ?? 'Source').toString(),
              publishedAt: m['publishedAt'] == null
                  ? null
                  : DateTime.tryParse(m['publishedAt'].toString()),
            );
          })
          .whereType<_Article>()
          .toList();

      if (!mounted) return;
      setState(() {
        _articles = parsed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.toString();
      });
    }
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мақалалар'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      hintText: 'Тақырып бойынша іздеу...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _loadArticles(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _loadArticles,
                  child: const Text('Іздеу'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorText != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _errorText!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadArticles,
                        child: _articles.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 120),
                                  Center(child: Text('Мақалалар табылмады.')),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: _articles.length,
                                itemBuilder: (context, index) {
                                  final a = _articles[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => _openArticle(a.url),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              a.title,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (a.description.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                a.description,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.public,
                                                  size: 16,
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    a.source,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if (a.publishedAt != null)
                                                  Text(
                                                    _formatDate(a.publishedAt!),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
