import 'package:flutter_test/flutter_test.dart';
import 'package:marli_agenda/models/cliente.dart';
import 'package:marli_agenda/providers/cliente_provider.dart';
import 'package:marli_agenda/repositories/i_cliente_repository.dart';

class _FakeClienteRepo implements IClienteRepository {
  final Map<int, Cliente> _store = {};
  int _nextId = 1;

  @override
  Future<List<Cliente>> listarTodos() async => _store.values.toList();

  @override
  Future<Cliente?> buscarPorId(int id) async => _store[id];

  @override
  Future<int> salvar(Cliente cliente) async {
    if (cliente.id == null) {
      final id = _nextId++;
      _store[id] = cliente.copyWith(id: id);
      return id;
    }
    _store[cliente.id!] = cliente;
    return cliente.id!;
  }

  @override
  Future<void> excluir(int id) async => _store.remove(id);
}

void main() {
  late ClienteProvider provider;

  setUp(() {
    provider = ClienteProvider(_FakeClienteRepo());
  });

  group('ClienteProvider', () {
    test('estado inicial tem lista vazia', () {
      expect(provider.clientes, isEmpty);
    });

    test('carregar popula a lista', () async {
      final repo = _FakeClienteRepo();
      await repo.salvar(Cliente(nome: 'Ana', telefone: '61999', criadoEm: DateTime(2026)));
      final p = ClienteProvider(repo);

      await p.carregar();

      expect(p.clientes.length, 1);
    });

    test('salvar adiciona cliente e notifica', () async {
      bool notificado = false;
      provider.addListener(() => notificado = true);

      await provider.salvar(
        Cliente(nome: 'Carlos', telefone: '61988', criadoEm: DateTime(2026)),
      );

      expect(provider.clientes.length, 1);
      expect(notificado, isTrue);
    });

    test('excluir remove cliente e notifica', () async {
      await provider.salvar(
        Cliente(nome: 'Maria', telefone: '61977', criadoEm: DateTime(2026)),
      );
      final id = provider.clientes.first.id!;

      bool notificado = false;
      provider.addListener(() => notificado = true);

      await provider.excluir(id);

      expect(provider.clientes, isEmpty);
      expect(notificado, isTrue);
    });
  });
}
