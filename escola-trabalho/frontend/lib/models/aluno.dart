// frontend/lib/models/aluno.dart

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'idade': idade,
      'matricula': matricula,
      'turma_id': turmaId,
    };
  }
}
