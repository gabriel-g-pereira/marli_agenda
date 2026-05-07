enum RemetenteMensagem { usuario, ia }

class MensagemChat {
  final String texto;
  final RemetenteMensagem remetente;
  final DateTime criadoEm;

  MensagemChat({
    required this.texto,
    required this.remetente,
    DateTime? criadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();
}
