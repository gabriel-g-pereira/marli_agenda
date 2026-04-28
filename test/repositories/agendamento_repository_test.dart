import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:marli_agenda/models/agendamento.dart';
import 'package:marli_agenda/repositories/agendamento_repository.dart';

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
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          telefone TEXT NOT NULL,
          email TEXT,
          observacao TEXT,
          criado_em TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE servicos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          preco REAL NOT NULL,
          duracao_minutos INTEGER NOT NULL DEFAULT 60
        )
      ''');
      await db.execute('''
        CREATE TABLE agendamentos (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          cliente_id  INTEGER NOT NULL,
          servico_id  INTEGER NOT NULL,
          data_hora   TEXT NOT NULL,
          status      TEXT NOT NULL DEFAULT 'agendado',
          observacao  TEXT,
          criado_em   TEXT NOT NULL,
          FOREIGN KEY (cliente_id) REFERENCES clientes(id),
          FOREIGN KEY (servico_id) REFERENCES servicos(id)
        )
      ''');
      // Seeds mínimos para FK
      await db.insert('clientes', {
        'nome': 'Ana', 'telefone': '61999', 'criado_em': DateTime(2026).toIso8601String()
      });
      await db.insert('servicos', {
        'nome': 'Lavagem', 'preco': 35.0, 'duracao_minutos': 60
      });
    },
  );
}

Agendamento _novoAgendamento({String status = 'agendado'}) => Agendamento(
      clienteId: 1,
      servicoId: 1,
      dataHora: DateTime(2026, 4, 28, 9, 0),
      status: status,
      criadoEm: DateTime(2026, 4, 27),
    );

void main() {
  late AgendamentoRepository repo;

  setUp(() async {
    _db = await _abrirBanco();
    repo = AgendamentoRepository(_db!);
  });

  tearDown(() async {
    await _db?.close();
  });

  group('AgendamentoRepository', () {
    test('salvar insere novo agendamento e retorna id', () async {
      final id = await repo.salvar(_novoAgendamento());
      expect(id, greaterThan(0));
    });

    test('listarTodos retorna agendamentos inseridos', () async {
      await repo.salvar(_novoAgendamento());
      await repo.salvar(_novoAgendamento());

      final lista = await repo.listarTodos();

      expect(lista.length, 2);
    });

    test('buscarPorId retorna agendamento correto', () async {
      final id = await repo.salvar(_novoAgendamento());

      final a = await repo.buscarPorId(id);

      expect(a, isNotNull);
      expect(a!.clienteId, 1);
      expect(a.status, 'agendado');
    });

    test('buscarPorId retorna null quando não existe', () async {
      final a = await repo.buscarPorId(999);
      expect(a, isNull);
    });

    test('atualizarStatus muda o status corretamente', () async {
      final id = await repo.salvar(_novoAgendamento());

      await repo.atualizarStatus(id, 'concluido');

      final a = await repo.buscarPorId(id);
      expect(a!.status, 'concluido');
    });

    test('excluir remove agendamento', () async {
      final id = await repo.salvar(_novoAgendamento());

      await repo.excluir(id);

      final a = await repo.buscarPorId(id);
      expect(a, isNull);
    });
  });
}
