import 'package:flutter/material.dart';

import 'dados.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formulario = GlobalKey<FormState>();
  final _username = TextEditingController();
  late Future<Map<String, dynamic>?> _sessao;
  bool _entrando = false;
  String? _mensagem;

  @override
  void initState() {
    super.initState();
    _sessao = _verificarSessao();
  }

  Future<Map<String, dynamic>?> _verificarSessao() async {
    final usuario = await lerUsuario();
    if (mounted && usuario != null) {
      Navigator.of(context).pushReplacementNamed('/posts');
    }
    return usuario;
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _entrando = true;
      _mensagem = null;
    });

    try {
      // A API de exemplo procura o usuário pelo username.
      final usuarios = await consultarApi('/users', {
        'username': _username.text.trim(),
      });
      if (!mounted) return;

      if (usuarios.isEmpty) {
        setState(() => _mensagem = 'Usuário não encontrado.');
        return;
      }

      await salvarUsuario(usuarios.first);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/posts');
    } catch (_) {
      if (mounted) {
        setState(() => _mensagem = 'Não foi possível entrar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Posts')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _sessao,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(() => _sessao = _verificarSessao()),
                child: const Text('Erro ao ler a sessão. Tentar novamente'),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _username,
                        enabled: !_entrando,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Usuário',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) => (valor ?? '').trim().isEmpty
                            ? 'Digite o usuário.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        enabled: !_entrando,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) => (valor ?? '').trim().isEmpty
                            ? 'Digite uma senha.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _entrando ? null : _entrar,
                        child: Text(_entrando ? 'Entrando...' : 'Entrar'),
                      ),
                      if (_mensagem != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(_mensagem!, textAlign: TextAlign.center),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
