import 'package:flutter/foundation.dart';
import '../models/servico.dart';
import '../repositories/i_servico_repository.dart';

class ServicoProvider extends ChangeNotifier {
  final IServicoRepository _repo;

  ServicoProvider(this._repo);

  List<Servico> _servicos = [];
  List<Servico> get servicos => List.unmodifiable(_servicos);

  Future<void> carregar() async {
    _servicos = await _repo.listarTodos();
    notifyListeners();
  }

  Future<void> salvar(Servico servico) async {
    final id = await _repo.salvar(servico);
    if (servico.id == null) {
      _servicos.add(servico.copyWith(id: id));
    } else {
      final idx = _servicos.indexWhere((s) => s.id == id);
      if (idx != -1) _servicos[idx] = servico;
    }
    notifyListeners();
  }

  Future<void> excluir(int id) async {
    await _repo.excluir(id);
    _servicos.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Servico? buscarPorId(int id) {
    try {
      return _servicos.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
