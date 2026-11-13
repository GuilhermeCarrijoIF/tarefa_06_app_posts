import 'package:flutter/material.dart';

import 'tela_login.dart';
import 'tela_posts.dart';

void main() {
  runApp(const AppPosts());
}

class AppPosts extends StatelessWidget {
  const AppPosts({super.key});

  @override
  Widget build(BuildContext context) {
    final rotas = <String, WidgetBuilder>{
      '/': (context) => const TelaLogin(),
      '/posts': (context) => const TelaPosts(),
    };

    return MaterialApp(
      title: 'Meus Posts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      routes: rotas,
      onGenerateInitialRoutes: (nome) {
        // Ao recarregar no navegador, abre apenas a rota atual.
        final rota = rotas.containsKey(nome) ? nome : '/';
        return [
          MaterialPageRoute<void>(
            settings: RouteSettings(name: rota),
            builder: rotas[rota]!,
          ),
        ];
      },
    );
  }
}
