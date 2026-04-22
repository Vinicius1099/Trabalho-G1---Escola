import 'package:sqlite3/sqlite3.dart';

class Database {
  static Database? _instance;
  late final db;

  Database._internal() {
    db = sqlite3.open('escola.db');
    _init();
  }

  factory Database() {
    _instance ??= Database._internal();
    return _instance!;
  }

  void _init() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS turmas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        serie TEXT NOT NULL,
        turno TEXT NOT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS alunos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        idade INTEGER NOT NULL,
        matricula TEXT NOT NULL UNIQUE,
        turma_id INTEGER NOT NULL,
        FOREIGN KEY (turma_id) REFERENCES turmas(id)
      )
    ''');
  }
}
