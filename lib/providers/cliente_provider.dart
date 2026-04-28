import 'package:flutter/foundation.dart';
import '../models/cliente.dart';
import '../repositories/i_cliente_repository.dart';

class ClienteProvider extends ChangeNotifier {
  final IClienteRepository _repo;

  ClienteProvider(this._repo);

  List<Cliente> _clientes = [];
  List<Cliente> get clientes => List.unmodifiable(_clientes);

  Future<void> carregar() async {
    _clientes = await _repo.listarTodos();
    notifyListeners();
  }

  Future<void> salvar(Cliente cliente) async {
    final id = await _repo.salvar(cliente);
    if (cliente.id == null) {
      _clientes.add(cliente.copyWith(id: id));
    } else {
      final idx = _clientes.indexWhere((c) => c.id == id);
      if (idx != -1) _clientes[idx] = cliente;
    }
    notifyListeners();
  }

  Future<void> excluir(int id) async {
    await _repo.excluir(id);
    _clientes.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Cliente? buscarPorId(int id) {
    try {
      return _clientes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
