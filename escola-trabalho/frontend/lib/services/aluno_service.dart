// frontend/lib/services/aluno_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aluno.dart';

/// Serviço responsável por toda a comunicação HTTP com a API
/// referente à entidade Aluno.
class AlunoService {
  static const String _baseUrl = 'http://localhost:8080';
  static const Duration _timeout = Duration(seconds: 10);

  /// GET /alunos — Lista todos os alunos
  Future<List<Aluno>> listar() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/alunos'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Aluno.fromJson(e)).toList();
    } else {
      throw Exception('Erro do servidor: ${response.statusCode}');
    }
  }

  /// GET /alunos/:id — Busca um aluno por ID
  Future<Aluno> buscarPorId(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/alunos/$id'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return Aluno.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar aluno: ${response.statusCode}');
    }
  }
}
