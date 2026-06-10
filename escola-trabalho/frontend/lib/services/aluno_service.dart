// frontend/lib/services/aluno_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aluno.dart';

/// Serviço responsável por toda a comunicação HTTP com a API
/// referente à entidade Aluno.
class AlunoService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  static const Duration _timeout = Duration(seconds: 10);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

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

  /// POST /alunos — Cria um novo aluno
  Future<Aluno> criar(Map<String, dynamic> dados) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/alunos'),
          headers: _headers,
          body: jsonEncode(dados),
        )
        .timeout(_timeout);

    if (response.statusCode == 201) {
      return Aluno.fromJson(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao criar aluno');
    }
  }

  /// PUT /alunos/:id — Atualiza um aluno existente
  Future<Aluno> atualizar(int id, Map<String, dynamic> dados) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/alunos/$id'),
          headers: _headers,
          body: jsonEncode(dados),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return Aluno.fromJson(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao atualizar aluno');
    }
  }

  /// DELETE /alunos/:id — Remove um aluno
  Future<void> excluir(int id) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl/alunos/$id'))
        .timeout(_timeout);

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir aluno: ${response.statusCode}');
    }
  }
}
