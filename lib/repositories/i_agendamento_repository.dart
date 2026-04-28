import '../models/agendamento.dart';

abstract interface class IAgendamentoRepository {
  Future<List<Agendamento>> listarTodos();
  Future<Agendamento?> buscarPorId(int id);
  Future<int> salvar(Agendamento agendamento);
  Future<void> atualizarStatus(int id, String status);
  Future<void> excluir(int id);
}
