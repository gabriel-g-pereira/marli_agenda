import 'package:sqflite/sqflite.dart';
import '../models/cliente.dart';
import 'i_cliente_repository.dart';

class ClienteRepository implements IClienteRepository {
  final Database _db;

  ClienteRepository(this._db);

  static const _tabela = 'clientes';

  @override
  Future<List<Cliente>> listarTodos() async {
    final rows = await _db.query(_tabela, orderBy: 'nome ASC');
    return rows.map(Cliente.fromMap).toList();
  }

  @override
  Future<Cliente?> buscarPorId(int id) async {
    final rows = await _db.query(_tabela, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Cliente.fromMap(rows.first);
  }

  @override
  Future<int> salvar(Cliente cliente) async {
    if (cliente.id == null) {
      return _db.insert(_tabela, cliente.toMap());
    }
    await _db.update(
      _tabela,
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
    return cliente.id!;
  }

  @override
  Future<void> excluir(int id) async {
    await _db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }
}
