// frontend/lib/screens/detalhe_page.dart

import 'package:flutter/material.dart';
import '../models/aluno.dart';
import '../services/aluno_service.dart';
import 'formulario_page.dart';

class DetalhePage extends StatefulWidget {
  final Aluno aluno;

  const DetalhePage({super.key, required this.aluno});

  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  final AlunoService _service = AlunoService();
  late Aluno _aluno;
  bool _excluindo = false;

  @override
  void initState() {
    super.initState();
    _aluno = widget.aluno;
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir aluno'),
        content: Text('Tem certeza que deseja excluir "${_aluno.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _excluindo = true);

    try {
      await _service.excluir(_aluno.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aluno excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // retorna true → lista deve atualizar
    } catch (e) {
      setState(() => _excluindo = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _abrirEdicao() async {
    final atualizado = await Navigator.push<Aluno>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioPage(aluno: _aluno),
      ),
    );

    if (atualizado != null) {
      setState(() => _aluno = atualizado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.person, size: 22),
            SizedBox(width: 8),
            Text('Detalhe do Aluno'),
          ],
        ),
      ),
      body: _excluindo
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Excluindo aluno...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar e nome
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFF1565C0),
                          child: Text(
                            _aluno.nome[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _aluno.nome,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Informações
                  _infoCard([
                    _infoItem(Icons.badge, 'Matrícula', _aluno.matricula),
                    _infoItem(Icons.cake, 'Idade', '${_aluno.idade} anos'),
                    _infoItem(Icons.class_, 'Turma', 'Turma ${_aluno.turmaId}'),
                    _infoItem(Icons.numbers, 'ID', '#${_aluno.id}'),
                  ]),

                  const SizedBox(height: 32),

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _abrirEdicao,
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF1565C0)),
                            foregroundColor: const Color(0xFF1565C0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _confirmarExclusao,
                          icon: const Icon(Icons.delete),
                          label: const Text('Excluir'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 22),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
