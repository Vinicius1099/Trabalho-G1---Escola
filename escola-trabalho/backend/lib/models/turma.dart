class Turma {
  final int? id;
  final String nome;
  final String serie;
  final String turno;

  Turma({
    this.id,
    required this.nome,
    required this.serie,
    required this.turno,
  });

  factory Turma.fromMap(Map<String, dynamic> map) {
    return Turma(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      serie: map['serie'] as String,
      turno: map['turno'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'serie': serie,
      'turno': turno,
    };
  }
}
