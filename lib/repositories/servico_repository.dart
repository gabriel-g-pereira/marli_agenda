import 'package:sqflite/sqflite.dart';
import '../models/servico.dart';
import 'i_servico_repository.dart';

class ServicoRepository implements IServicoRepository {
  final Database _db;

  ServicoRepository(this._db);

  static const _tabela = 'servicos';

  @override
  Future<List<Servico>> listarTodos() async {
    final rows = await _db.query(_tabela, orderBy: 'nome ASC');
    return rows.map(Servico.fromMap).toList();
  }

  @override
  Future<Servico?> buscarPorId(int id) async {
    final rows = await _db.query(_tabela, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Servico.fromMap(rows.first);
  }

  @override
  Future<int> salvar(Servico servico) async {
    if (servico.id == null) {
      return _db.insert(_tabela, servico.toMap());
    }
    await _db.update(
      _tabela,
      servico.toMap(),
      where: 'id = ?',
      whereArgs: [servico.id],
    );
    return servico.id!;
  }

  @override
  Future<void> excluir(int id) async {
    await _db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }
}
