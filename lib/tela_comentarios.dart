import 'package:flutter/material.dart';

import 'dados.dart';

class TelaComentarios extends StatefulWidget {
  const TelaComentarios({
    super.key,
    required this.postId,
    required this.titulo,
  });

  final int postId;
  final String titulo;

  @override
  State<TelaComentarios> createState() => _TelaComentariosState();
}

class _TelaComentariosState extends State<TelaComentarios> {
  late Future<List<Map<String, dynamic>>?> _comentarios;

  @override
  void initState() {
    super.initState();
    _comentarios = _carregarComentarios();
  }

  Future<List<Map<String, dynamic>>?> _carregarComentarios() async {
    final usuario = await lerUsuario();
    if (!mounted) return null;

    if (usuario == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      return null;
    }

    return consultarApi('/comments', {'postId': widget.postId.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentários')),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: _comentarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () =>
                    setState(() => _comentarios = _carregarComentarios()),
                child: const Text(
                  'Erro ao carregar os comentários. Tentar novamente',
                ),
              ),
            );
          }

          final comentarios = snapshot.data;
          if (comentarios == null) return const SizedBox.shrink();
          if (comentarios.isEmpty) {
            return const Center(child: Text('Nenhum comentário encontrado.'));
          }

          return ListView.separated(
            itemCount: comentarios.length + 1,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: Text(
                    widget.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }

              final comentario = comentarios[index - 1];
              return ListTile(
                title: Text(comentario['name'] as String),
                subtitle: Text(
                  '${comentario['email']}\n\n${comentario['body']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
