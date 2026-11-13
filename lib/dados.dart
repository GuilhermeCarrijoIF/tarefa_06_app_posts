import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _chaveUsuario = 'usuario_logado';

Future<List<Map<String, dynamic>>> consultarApi(
  String caminho,
  Map<String, String> parametros,
) async {
  final url = Uri.https('jsonplaceholder.typicode.com', caminho, parametros);
  final resposta = await http.get(url).timeout(const Duration(seconds: 15));

  if (resposta.statusCode != 200) {
    throw Exception('Erro HTTP ${resposta.statusCode}');
  }

  final dados = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
  return dados.cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>?> lerUsuario() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_chaveUsuario);
  if (json == null) return null;

  return jsonDecode(json) as Map<String, dynamic>;
}

Future<void> salvarUsuario(Map<String, dynamic> usuario) async {
  final prefs = await SharedPreferences.getInstance();
  if (!await prefs.setString(_chaveUsuario, jsonEncode(usuario))) {
    throw Exception('Erro ao salvar a sessão');
  }
}

Future<void> apagarUsuario() async {
  final prefs = await SharedPreferences.getInstance();
  if (!await prefs.remove(_chaveUsuario)) {
    throw Exception('Erro ao apagar a sessão');
  }
}
