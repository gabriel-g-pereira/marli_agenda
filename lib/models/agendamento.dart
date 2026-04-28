class Agendamento {
  final int? id;
  final int clienteId;
  final int servicoId;
  final DateTime dataHora;
  final String status;
  final String? observacao;
  final DateTime criadoEm;

  const Agendamento({
    this.id,
    required this.clienteId,
    required this.servicoId,
    required this.dataHora,
    required this.status,
    this.observacao,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cliente_id': clienteId,
      'servico_id': servicoId,
      'data_hora': dataHora.toIso8601String(),
      'status': status,
      'observacao': observacao,
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int,
      servicoId: map['servico_id'] as int,
      dataHora: DateTime.parse(map['data_hora'] as String),
      status: map['status'] as String,
      observacao: map['observacao'] as String?,
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  Agendamento copyWith({
    int? id,
    int? clienteId,
    int? servicoId,
    DateTime? dataHora,
    String? status,
    String? observacao,
    DateTime? criadoEm,
  }) {
    return Agendamento(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      servicoId: servicoId ?? this.servicoId,
      dataHora: dataHora ?? this.dataHora,
      status: status ?? this.status,
      observacao: observacao ?? this.observacao,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
