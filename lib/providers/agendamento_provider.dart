import 'package:flutter/foundation.dart';
import '../models/agendamento.dart';
import '../repositories/i_agendamento_repository.dart';

class AgendamentoProvider extends ChangeNotifier {
  final IAgendamentoRepository _repo;

  AgendamentoProvider(this._repo);

  List<Agendamento> _agendamentos = [];
  List<Agendamento> get agendamentos => List.unmodifiable(_agendamentos);

  Future<void> carregar() async {
    _agendamentos = await _repo.listarTodos();
    notifyListeners();
  }

  Future<void> salvar(Agendamento agendamento) async {
    final id = await _repo.salvar(agendamento);
    if (agendamento.id == null) {
      _agendamentos.add(agendamento.copyWith(id: id));
    } else {
      final idx = _agendamentos.indexWhere((a) => a.id == id);
      if (idx != -1) _agendamentos[idx] = agendamento;
    }
    notifyListeners();
  }

  Future<void> atualizarStatus(int id, String status) async {
    await _repo.atualizarStatus(id, status);
    final idx = _agendamentos.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _agendamentos[idx] = _agendamentos[idx].copyWith(status: status);
    }
    notifyListeners();
  }

  Future<void> excluir(int id) async {
    await _repo.excluir(id);
    _agendamentos.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Agendamento? buscarPorId(int id) {
    try {
      return _agendamentos.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
