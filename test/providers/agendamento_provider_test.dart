import 'package:flutter_test/flutter_test.dart';
import 'package:marli_agenda/models/agendamento.dart';
import 'package:marli_agenda/providers/agendamento_provider.dart';
import 'package:marli_agenda/repositories/i_agendamento_repository.dart';

class _FakeAgendamentoRepo implements IAgendamentoRepository {
  final Map<int, Agendamento> _store = {};
  int _nextId = 1;

  @override
  Future<List<Agendamento>> listarTodos() async => _store.values.toList();

  @override
  Future<Agendamento?> buscarPorId(int id) async => _store[id];

  @override
  Future<int> salvar(Agendamento agendamento) async {
    if (agendamento.id == null) {
      final id = _nextId++;
      _store[id] = agendamento.copyWith(id: id);
      return id;
    }
    _store[agendamento.id!] = agendamento;
    return agendamento.id!;
  }

  @override
  Future<void> atualizarStatus(int id, String status) async {
    final a = _store[id];
    if (a != null) _store[id] = a.copyWith(status: status);
  }

  @override
  Future<void> excluir(int id) async => _store.remove(id);
}

Agendamento _novo({String status = 'agendado'}) => Agendamento(
      clienteId: 1,
      servicoId: 1,
      dataHora: DateTime(2026, 4, 28, 9, 0),
      status: status,
      criadoEm: DateTime(2026, 4, 27),
    );

void main() {
  late AgendamentoProvider provider;

  setUp(() {
    provider = AgendamentoProvider(_FakeAgendamentoRepo());
  });

  group('AgendamentoProvider', () {
    test('estado inicial tem lista vazia', () {
      expect(provider.agendamentos, isEmpty);
    });

    test('salvar adiciona agendamento e notifica', () async {
      bool notificado = false;
      provider.addListener(() => notificado = true);

      await provider.salvar(_novo());

      expect(provider.agendamentos.length, 1);
      expect(notificado, isTrue);
    });

    test('atualizarStatus muda status e notifica', () async {
      await provider.salvar(_novo());
      final id = provider.agendamentos.first.id!;

      bool notificado = false;
      provider.addListener(() => notificado = true);

      await provider.atualizarStatus(id, 'concluido');

      expect(provider.agendamentos.first.status, 'concluido');
      expect(notificado, isTrue);
    });

    test('excluir remove agendamento e notifica', () async {
      await provider.salvar(_novo());
      final id = provider.agendamentos.first.id!;

      bool notificado = false;
      provider.addListener(() => notificado = true);

      await provider.excluir(id);

      expect(provider.agendamentos, isEmpty);
      expect(notificado, isTrue);
    });

    test('buscarPorId retorna agendamento correto', () async {
      await provider.salvar(_novo());
      final id = provider.agendamentos.first.id!;

      final a = provider.buscarPorId(id);

      expect(a, isNotNull);
      expect(a!.clienteId, 1);
    });
  });
}
