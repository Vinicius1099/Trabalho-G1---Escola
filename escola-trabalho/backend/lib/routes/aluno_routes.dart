import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';
import '../models/aluno.dart';

Router alunoRoutes() {
  final router = Router();
  final db = Database().db;

  // GET /alunos - Listar todos os alunos
  router.get('/alunos', (Request req) {
    final rows = db.select('SELECT * FROM alunos');
    final alunos = rows.map((row) => Aluno.fromMap(row).toJson()).toList();
    return Response.ok(
      jsonEncode(alunos),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // GET /alunos/:id - Buscar aluno por ID
  router.get('/alunos/<id>', (Request req, String id) {
    final rows = db.select('SELECT * FROM alunos WHERE id = ?', [int.tryParse(id)]);
    if (rows.isEmpty) {
      return Response.notFound(
        jsonEncode({'erro': 'Aluno não encontrado'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    return Response.ok(
      jsonEncode(Aluno.fromMap(rows.first).toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // POST /alunos - Criar novo aluno
  router.post('/alunos', (Request req) async {
    final body = await req.readAsString();
    Map<String, dynamic> data;
    try {
      data = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return Response(400,
          body: jsonEncode({'erro': 'JSON inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    if (data['nome'] == null ||
        data['idade'] == null ||
        data['matricula'] == null ||
        data['turma_id'] == null) {
      return Response(400,
          body: jsonEncode({'erro': 'Campos obrigatórios: nome, idade, matricula, turma_id'}),
          headers: {'Content-Type': 'application/json'});
    }

    final turma = db.select('SELECT * FROM turmas WHERE id = ?', [data['turma_id']]);
    if (turma.isEmpty) {
      return Response(400,
          body: jsonEncode({'erro': 'turma_id não existe'}),
          headers: {'Content-Type': 'application/json'});
    }

    try {
      db.execute(
        'INSERT INTO alunos (nome, idade, matricula, turma_id) VALUES (?, ?, ?, ?)',
        [data['nome'], data['idade'], data['matricula'], data['turma_id']],
      );
    } catch (_) {
      return Response(400,
          body: jsonEncode({'erro': 'Matrícula já cadastrada'}),
          headers: {'Content-Type': 'application/json'});
    }

    final id = db.lastInsertRowId;
    final rows = db.select('SELECT * FROM alunos WHERE id = ?', [id]);
    return Response(201,
        body: jsonEncode(Aluno.fromMap(rows.first).toJson()),
        headers: {'Content-Type': 'application/json'});
  });

  // PUT /alunos/:id - Atualizar aluno
  router.put('/alunos/<id>', (Request req, String id) async {
    final rows = db.select('SELECT * FROM alunos WHERE id = ?', [int.tryParse(id)]);
    if (rows.isEmpty) {
      return Response.notFound(
        jsonEncode({'erro': 'Aluno não encontrado'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final body = await req.readAsString();
    Map<String, dynamic> data;
    try {
      data = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return Response(400,
          body: jsonEncode({'erro': 'JSON inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    final atual = Aluno.fromMap(rows.first);
    final nome = data['nome'] ?? atual.nome;
    final idade = data['idade'] ?? atual.idade;
    final matricula = data['matricula'] ?? atual.matricula;
    final turmaId = data['turma_id'] ?? atual.turmaId;

    if (data['turma_id'] != null) {
      final turma = db.select('SELECT * FROM turmas WHERE id = ?', [turmaId]);
      if (turma.isEmpty) {
        return Response(400,
            body: jsonEncode({'erro': 'turma_id não existe'}),
            headers: {'Content-Type': 'application/json'});
      }
    }

    db.execute(
      'UPDATE alunos SET nome = ?, idade = ?, matricula = ?, turma_id = ? WHERE id = ?',
      [nome, idade, matricula, turmaId, int.tryParse(id)],
    );

    final updated = db.select('SELECT * FROM alunos WHERE id = ?', [int.tryParse(id)]);
    return Response.ok(
      jsonEncode(Aluno.fromMap(updated.first).toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // DELETE /alunos/:id - Remover aluno
  router.delete('/alunos/<id>', (Request req, String id) {
    final rows = db.select('SELECT * FROM alunos WHERE id = ?', [int.tryParse(id)]);
    if (rows.isEmpty) {
      return Response.notFound(
        jsonEncode({'erro': 'Aluno não encontrado'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    db.execute('DELETE FROM alunos WHERE id = ?', [int.tryParse(id)]);
    return Response(204, headers: {'Content-Type': 'application/json'});
  });

  return router;
}
