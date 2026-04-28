class Servico {
  final int? id;
  final String nome;
  final double preco;
  final int duracaoMinutos;

  const Servico({
    this.id,
    required this.nome,
    required this.preco,
    required this.duracaoMinutos,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'preco': preco,
      'duracao_minutos': duracaoMinutos,
    };
  }

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      preco: (map['preco'] as num).toDouble(),
      duracaoMinutos: map['duracao_minutos'] as int,
    );
  }

  Servico copyWith({
    int? id,
    String? nome,
    double? preco,
    int? duracaoMinutos,
  }) {
    return Servico(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      duracaoMinutos: duracaoMinutos ?? this.duracaoMinutos,
    );
  }
}
