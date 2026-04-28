class Cliente {
  final int? id;
  final String nome;
  final String telefone;
  final String? email;
  final String? observacao;
  final DateTime criadoEm;

  const Cliente({
    this.id,
    required this.nome,
    required this.telefone,
    this.email,
    this.observacao,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'observacao': observacao,
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String?,
      observacao: map['observacao'] as String?,
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  Cliente copyWith({
    int? id,
    String? nome,
    String? telefone,
    String? email,
    String? observacao,
    DateTime? criadoEm,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      observacao: observacao ?? this.observacao,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
