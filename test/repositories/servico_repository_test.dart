import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:marli_agenda/models/servico.dart';
import 'package:marli_agenda/repositories/servico_repository.dart';

Database? _db;

Future<Database> _abrirBanco() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE servicos (
          id               INTEGER PRIMARY KEY AUTOINCREMENT,
          nome             TEXT NOT NULL,
          preco            REAL NOT NULL,
          duracao_minutos  INTEGER NOT NULL DEFAULT 60
        )
      ''');
    },
  );
}

void main() {
  late ServicoRepository repo;

  setUp(() async {
    _db = await _abrirBanco();
    repo = ServicoRepository(_db!);
  });

  tearDown(() async {
    await _db?.close();
  });

  group('ServicoRepository', () {
    test('salvar insere novo serviço e retorna id', () async {
      final id = await repo.salvar(
        const Servico(nome: 'Lavagem Simples', preco: 35.0, duracaoMinutos: 60),
      );

      expect(id, greaterThan(0));
    });

    test('listarTodos retorna serviços inseridos', () async {
      await repo.salvar(
          const Servico(nome: 'Lavagem Simples', preco: 35.0, duracaoMinutos: 60));
      await repo.salvar(
          const Servico(nome: 'Lavagem a Seco', preco: 80.0, duracaoMinutos: 90));

      final lista = await repo.listarTodos();

      expect(lista.length, 2);
    });

    test('buscarPorId retorna serviço correto', () async {
      final id = await repo.salvar(
        const Servico(nome: 'Higienização de Tênis', preco: 45.0, duracaoMinutos: 60),
      );

      final servico = await repo.buscarPorId(id);

      expect(servico, isNotNull);
      expect(servico!.nome, 'Higienização de Tênis');
      expect(servico.preco, 45.0);
    });

    test('buscarPorId retorna null quando não existe', () async {
      final servico = await repo.buscarPorId(999);
      expect(servico, isNull);
    });

    test('salvar com id atualiza serviço existente', () async {
      final id = await repo.salvar(
        const Servico(nome: 'Lavagem Simples', preco: 35.0, duracaoMinutos: 60),
      );

      await repo.salvar(
        Servico(id: id, nome: 'Lavagem Simples', preco: 40.0, duracaoMinutos: 60),
      );

      final atualizado = await repo.buscarPorId(id);
      expect(atualizado!.preco, 40.0);
    });

    test('excluir remove serviço', () async {
      final id = await repo.salvar(
        const Servico(nome: 'Lavagem de Tapete', preco: 70.0, duracaoMinutos: 120),
      );

      await repo.excluir(id);

      final servico = await repo.buscarPorId(id);
      expect(servico, isNull);
    });
  });
}
