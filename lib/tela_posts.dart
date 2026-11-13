import 'package:flutter/material.dart';

import 'dados.dart';
import 'tela_comentarios.dart';

class TelaPosts extends StatefulWidget {
  const TelaPosts({super.key});

  @override
  State<TelaPosts> createState() => _TelaPostsState();
}

class _TelaPostsState extends State<TelaPosts> {
  late Future<List<Map<String, dynamic>>> _posts;
  Map<String, dynamic>? _usuario;
  bool _saindo = false;

  @override
  void initState() {
    super.initState();
    _posts = _carregarPosts();
  }

  Future<List<Map<String, dynamic>>> _carregarPosts() async {
    final usuario = await lerUsuario();
    if (!mounted) return [];

    if (usuario == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      return [];
    }

    setState(() => _usuario = usuario);
    return consultarApi('/posts', {'userId': usuario['id'].toString()});
  }

  Future<void> _sair() async {
    setState(() => _saindo = true);
    try {
      await apagarUsuario();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saindo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sair. Tente novamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          usuario == null ? 'Meus posts' : 'Posts de ${usuario['username']}',
        ),
        actions: [
          if (usuario != null)
            IconButton(
              onPressed: _saindo ? null : _sair,
              tooltip: 'Sair',
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _posts,
        builder: (context, snapshot) {
          if (_saindo || snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(() => _posts = _carregarPosts()),
                child: const Text(
                  'Erro ao carregar os posts. Tentar novamente',
                ),
              ),
            );
          }
          if (usuario == null) return const SizedBox.shrink();

          final posts = snapshot.data!;
          if (posts.isEmpty) {
            return const Center(child: Text('Nenhum post encontrado.'));
          }

          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final post = posts[index];
              final titulo = post['title'] as String;
              return ListTile(
                title: Text(titulo),
                subtitle: Text(
                  post['body'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => TelaComentarios(
                      postId: post['id'] as int,
                      titulo: titulo,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
