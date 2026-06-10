// frontend/lib/screens/formulario_page.dart

import 'package:flutter/material.dart';
import '../models/aluno.dart';
import '../services/aluno_service.dart';

class FormularioPage extends StatefulWidget {
  /// Se [aluno] for null → modo criação. Se não → modo edição.
  final Aluno? aluno;

  const FormularioPage({super.key, this.aluno});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();
  final AlunoService _service = AlunoService();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _idadeCtrl;
  late final TextEditingController _matriculaCtrl;
  late final TextEditingController _turmaCtrl;

  bool _salvando = false;
  String? _erro;

  bool get _modoEdicao => widget.aluno != null;

  @override
  void initState() {
    super.initState();
    final a = widget.aluno;
    _nomeCtrl = TextEditingController(text: a?.nome ?? '');
    _idadeCtrl = TextEditingController(text: a != null ? '${a.idade}' : '');
    _matriculaCtrl = TextEditingController(text: a?.matricula ?? '');
    _turmaCtrl = TextEditingController(text: a != null ? '${a.turmaId}' : '');
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    _matriculaCtrl.dispose();
    _turmaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final dados = {
      'nome': _nomeCtrl.text.trim(),
      'idade': int.parse(_idadeCtrl.text.trim()),
      'matricula': _matriculaCtrl.text.trim(),
      'turma_id': int.parse(_turmaCtrl.text.trim()),
    };

    try {
      Aluno resultado;
      if (_modoEdicao) {
        resultado = await _service.atualizar(widget.aluno!.id, dados);
      } else {
        resultado = await _service.criar(dados);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modoEdicao
                ? 'Aluno atualizado com sucesso!'
                : 'Aluno criado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, resultado);
    } catch (e) {
      setState(() {
        _salvando = false;
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _cancelar() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_modoEdicao ? Icons.edit : Icons.person_add, size: 22),
            const SizedBox(width: 8),
            Text(_modoEdicao ? 'Editar Aluno' : 'Novo Aluno'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Erro
              if (_erro != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _erro!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Campo: Nome
              TextFormField(
                controller: _nomeCtrl,
                decoration: _inputDecoration('Nome completo', Icons.person),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nome é obrigatório';
                  if (v.trim().length < 2) return 'Nome muito curto';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Idade
              TextFormField(
                controller: _idadeCtrl,
                decoration: _inputDecoration('Idade', Icons.cake),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Idade é obrigatória';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1 || n > 120) return 'Informe uma idade válida';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Matrícula
              TextFormField(
                controller: _matriculaCtrl,
                decoration: _inputDecoration('Matrícula', Icons.badge),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Matrícula é obrigatória';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Turma
              TextFormField(
                controller: _turmaCtrl,
                decoration: _inputDecoration('ID da Turma', Icons.class_),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Turma é obrigatória';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1) return 'Informe um ID de turma válido';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botões
              if (_salvando)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Salvando...'),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cancelar,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _salvar,
                        icon: Icon(_modoEdicao ? Icons.save : Icons.add),
                        label: Text(_modoEdicao ? 'Salvar' : 'Criar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
