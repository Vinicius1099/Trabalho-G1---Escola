import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EscolaApp());
}

// ─── Modelo ───────────────────────────────────────────────────────────────────

class Aluno {
  final int id;
  final String nome;
  final int idade;
  final String matricula;
  final int turmaId;

  Aluno({
    required this.id,
    required this.nome,
    required this.idade,
    required this.matricula,
    required this.turmaId,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'] as int,
      nome: json['nome'] as String,
      idade: json['idade'] as int,
      matricula: json['matricula'] as String,
      turmaId: json['turma_id'] as int,
    );
  }
}

// ─── App ──────────────────────────────────────────────────────────────────────

class EscolaApp extends StatelessWidget {
  const EscolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escola App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const AlunosListPage(),
    );
  }
}

// ─── Tela de Listagem de Alunos ───────────────────────────────────────────────

class AlunosListPage extends StatefulWidget {
  const AlunosListPage({super.key});

  @override
  State<AlunosListPage> createState() => _AlunosListPageState();
}

class _AlunosListPageState extends State<AlunosListPage> {
  List<Aluno> _alunos = [];
  bool _carregando = true;
  String? _erro;

  static const String _baseUrl = 'http://localhost:8080';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/alunos'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        setState(() {
          _alunos = json.map((e) => Aluno.fromJson(e)).toList();
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = 'Erro do servidor: ${response.statusCode}';
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor.\nVerifique se o backend está rodando.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, size: 22),
            SizedBox(width: 8),
            Text('Lista de Alunos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando alunos...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _carregarDados,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_alunos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum aluno cadastrado.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFFE3F2FD),
          child: Text(
            '${_alunos.length} aluno(s) encontrado(s)',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _alunos.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final aluno = _alunos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1565C0),
                    child: Text(
                      aluno.nome[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    aluno.nome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Matrícula: ${aluno.matricula}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${aluno.idade} anos',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        'Turma ${aluno.turmaId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
