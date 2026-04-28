import 'package:flutter_test/flutter_test.dart';
import 'package:marli_agenda/models/servico.dart';
import 'package:marli_agenda/providers/servico_provider.dart';
import 'package:marli_agenda/repositories/i_servico_repository.dart';

class _FakeServicoRepo implements IServicoRepository {
  final Map<int, Servico> _store = {};
  int _nextId = 1;

  @override
  Future<List<Servico>> listarTodos() async => _store.values.toList();

  @override
  Future<Servico?> buscarPorId(int id) async => _store[id];

  @override
  Future<int> salvar(Servico servico) async {
    if (servico.id == null) {
      final id = _nextId++;
      _store[id] = servico.copyWith(id: id);
      return id;
    }
    _store[servico.id!] = servico;
    return servico.id!;
  }

  @override
  Future<void> excluir(int id) async => _store.remove(id);
}

void main() {
  late ServicoProvider provider;

  setUp(() {
    provider = ServicoProvider(_FakeServicoRepo());
  });

  group('ServicoProvider', () {
    test('estado inicial tem lista vazia', () {
      expect(provider.servicos, isEmpty);
    });

    test('salvar adiciona serviço e notifica', () async {
      bool notificado = false;
      provider.addListener(() => notificado = true);

      await provider.salvar(
        const Servico(nome: 'Lavagem Simples', preco: 35.0, duracaoMinutos: 60),
      );

      expect(provider.servicos.length, 1);
      expect(notificado, isTrue);
    });

    test('salvar com id atualiza serviço existente', () async {
      await provider.salvar(
        const Servico(nome: 'Lavagem Simples', preco: 35.0, duracaoMinutos: 60),
      );
      final id = provider.servicos.first.id!;

      await provider.salvar(
        Servico(id: id, nome: 'Lavagem Simples', preco: 40.0, duracaoMinutos: 60),
      );

      expect(provider.servicos.length, 1);
      expect(provider.servicos.first.preco, 40.0);
    });

    test('excluir remove serviço e notifica', () async {
      await provider.salvar(
        const Servico(nome: 'Lavagem a Seco', preco: 80.0, duracaoMinutos: 90),
      );
      final id = provider.servicos.first.id!;

      bool notificado = false;
      provider.addListener(() => notificado = true);

      await provider.excluir(id);

      expect(provider.servicos, isEmpty);
      expect(notificado, isTrue);
    });
  });
}
