import 'package:sqflite/sqflite.dart';
import '../models/agendamento.dart';
import 'i_agendamento_repository.dart';

class AgendamentoRepository implements IAgendamentoRepository {
  final Database _db;

  AgendamentoRepository(this._db);

  static const _tabela = 'agendamentos';

  @override
  Future<List<Agendamento>> listarTodos() async {
    final rows = await _db.query(_tabela, orderBy: 'data_hora ASC');
    return rows.map(Agendamento.fromMap).toList();
  }

  @override
  Future<Agendamento?> buscarPorId(int id) async {
    final rows = await _db.query(_tabela, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Agendamento.fromMap(rows.first);
  }

  @override
  Future<int> salvar(Agendamento agendamento) async {
    if (agendamento.id == null) {
      return _db.insert(_tabela, agendamento.toMap());
    }
    await _db.update(
      _tabela,
      agendamento.toMap(),
      where: 'id = ?',
      whereArgs: [agendamento.id],
    );
    return agendamento.id!;
  }

  @override
  Future<void> atualizarStatus(int id, String status) async {
    await _db.update(
      _tabela,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> excluir(int id) async {
    await _db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }
}
