import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:marli_agenda/models/cliente.dart';
import 'package:marli_agenda/repositories/cliente_repository.dart';

Database? _db;

Future<Database> _abrirBanco() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE clientes (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          nome      TEXT NOT NULL,
          telefone  TEXT NOT NULL,
          email     TEXT,
          observacao TEXT,
          criado_em TEXT NOT NULL
        )
      ''');
    },
  );
}

void main() {
  late ClienteRepository repo;

  setUp(() async {
    _db = await _abrirBanco();
    repo = ClienteRepository(_db!);
  });

  tearDown(() async {
    await _db?.close();
  });

  group('ClienteRepository', () {
    test('salvar insere novo cliente e retorna id', () async {
      final cliente = Cliente(
        nome: 'Ana Paula',
        telefone: '61999991234',
        criadoEm: DateTime(2026, 4, 28),
      );

      final id = await repo.salvar(cliente);

      expect(id, greaterThan(0));
    });

    test('listarTodos retorna clientes inseridos', () async {
      await repo.salvar(Cliente(
        nome: 'Ana Paula',
        telefone: '61999991234',
        criadoEm: DateTime(2026, 4, 28),
      ));
      await repo.salvar(Cliente(
        nome: 'Carlos',
        telefone: '61988887777',
        criadoEm: DateTime(2026, 4, 28),
      ));

      final lista = await repo.listarTodos();

      expect(lista.length, 2);
      expect(lista.map((c) => c.nome), containsAll(['Ana Paula', 'Carlos']));
    });

    test('buscarPorId retorna cliente correto', () async {
      final id = await repo.salvar(Cliente(
        nome: 'Maria',
        telefone: '61977776666',
        criadoEm: DateTime(2026, 4, 28),
      ));

      final cliente = await repo.buscarPorId(id);

      expect(cliente, isNotNull);
      expect(cliente!.nome, 'Maria');
    });

    test('buscarPorId retorna null quando não existe', () async {
      final cliente = await repo.buscarPorId(999);
      expect(cliente, isNull);
    });

    test('salvar com id atualiza cliente existente', () async {
      final id = await repo.salvar(Cliente(
        nome: 'Carlos',
        telefone: '61988887777',
        criadoEm: DateTime(2026, 4, 28),
      ));

      await repo.salvar(Cliente(
        id: id,
        nome: 'Carlos M.',
        telefone: '61988887777',
        criadoEm: DateTime(2026, 4, 28),
      ));

      final atualizado = await repo.buscarPorId(id);
      expect(atualizado!.nome, 'Carlos M.');
    });

    test('excluir remove cliente', () async {
      final id = await repo.salvar(Cliente(
        nome: 'José',
        telefone: '61966665555',
        criadoEm: DateTime(2026, 4, 28),
      ));

      await repo.excluir(id);

      final cliente = await repo.buscarPorId(id);
      expect(cliente, isNull);
    });
  });
}
