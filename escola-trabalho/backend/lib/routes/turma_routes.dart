import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';
import '../models/turma.dart';

Router turmaRoutes() {
  final router = Router();
  final db = Database().db;

  // GET /turmas - Listar todas as turmas
  router.get('/turmas', (Request req) {
    final rows = db.select('SELECT * FROM turmas');
    final turmas = rows.map((row) => Turma.fromMap(row).toJson()).toList();
    return Response.ok(
      jsonEncode(turmas),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // GET /turmas/:id - Buscar turma por ID
  router.get('/turmas/<id>', (Request req, String id) {
    final rows = db.select('SELECT * FROM turmas WHERE id = ?', [int.tryParse(id)]);
    if (rows.isEmpty) {
      return Response.notFound(
        jsonEncode({'erro': 'Turma não encontrada'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    return Response.ok(
      jsonEncode(Turma.fromMap(rows.first).toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // POST /turmas - Criar nova turma
  router.post('/turmas', (Request req) async {
    final body = await req.readAsString();
    Map<String, dynamic> data;
    try {
      data = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return Response(400,
          body: jsonEncode({'erro': 'JSON inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    if (data['nome'] == null || data['serie'] == null || data['turno'] == null) {
      return Response(400,
          body: jsonEncode({'erro': 'Campos obrigatórios: nome, serie, turno'}),
          headers: {'Content-Type': 'application/json'});
    }

    db.execute(
      'INSERT INTO turmas (nome, serie, turno) VALUES (?, ?, ?)',
      [data['nome'], data['serie'], data['turno']],
    );

    final id = db.lastInsertRowId;
    final rows = db.select('SELECT * FROM turmas WHERE id = ?', [id]);
    return Response(201,
        body: jsonEncode(Turma.fromMap(rows.first).toJson()),
        headers: {'Content-Type': 'application/json'});
  });

  // PUT /turmas/:id - Atualizar turma
  router.put('/turmas/<id>', (Request req, String id) async {
    final rows = db.select('SELECT * FROM turmas WHERE id = ?', [int.tryParse(id)]);
    if (rows.isEmpty) {
      return Response.notFound(
        jsonEncode({'erro': 'Turma não encontrada'}),
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

    final atual = Turma.fromMap(rows.first);
    final nome = data['nome'] ?? atual.nome;
    final serie = data['serie'] ?? atual.serie;
    final turno = data['turno'] ?? atual.turno;

    db.execute(
      'UPDATE turmas SET nome = ?, serie = ?, turno = ? WHERE id = ?',
      [nome, serie, turno, int.tryParse(id)],
    );

    final updated = db.select('SELECT * FROM turmas WHERE id = ?', [int.tryParse(id)]);
    return Response.ok(
      jsonEncode(Turma.fromMap(updated.first).toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // DELETE /turmas/:id - Remover turma
  router.delete('/turmas/<id>', (Request req, String id) {
    final rows = db.select('SELECT * FROM turmas WHERE id = ?', [int.tryParse(id)]);
    if (rows.isEmpty) {
      return Response.notFound(
        jsonEncode({'erro': 'Turma não encontrada'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    db.execute('DELETE FROM alunos WHERE turma_id = ?', [int.tryParse(id)]);
    db.execute('DELETE FROM turmas WHERE id = ?', [int.tryParse(id)]);
    return Response(204, headers: {'Content-Type': 'application/json'});
  });

  // GET /turmas/:id/alunos - Listar alunos de uma turma
  router.get('/turmas/<id>/alunos', (Request req, String id) {
    final turma = db.select('SELECT * FROM turmas WHERE id = ?', [int.tryParse(id)]);
    if (turma.isEmpty) {
      return Response.notFound(
        jsonEncode({'erro': 'Turma não encontrada'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    final rows = db.select('SELECT * FROM alunos WHERE turma_id = ?', [int.tryParse(id)]);
    final alunos = rows.map((row) {
      return {
        'id': row['id'],
        'nome': row['nome'],
        'idade': row['idade'],
        'matricula': row['matricula'],
        'turma_id': row['turma_id'],
      };
    }).toList();
    return Response.ok(
      jsonEncode(alunos),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}
