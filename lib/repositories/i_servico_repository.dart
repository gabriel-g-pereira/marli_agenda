import '../models/servico.dart';

abstract interface class IServicoRepository {
  Future<List<Servico>> listarTodos();
  Future<Servico?> buscarPorId(int id);
  Future<int> salvar(Servico servico);
  Future<void> excluir(int id);
}
