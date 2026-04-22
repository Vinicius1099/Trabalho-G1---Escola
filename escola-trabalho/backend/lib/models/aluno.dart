class Aluno {
  final int? id;
  final String nome;
  final int idade;
  final String matricula;
  final int turmaId;

  Aluno({
    this.id,
    required this.nome,
    required this.idade,
    required this.matricula,
    required this.turmaId,
  });

  factory Aluno.fromMap(Map<String, dynamic> map) {
    return Aluno(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      idade: map['idade'] as int,
      matricula: map['matricula'] as String,
      turmaId: map['turma_id'] as int,
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
