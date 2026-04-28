import '../models/cliente.dart';

abstract interface class IClienteRepository {
  Future<List<Cliente>> listarTodos();
  Future<Cliente?> buscarPorId(int id);
  Future<int> salvar(Cliente cliente);
  Future<void> excluir(int id);
}
