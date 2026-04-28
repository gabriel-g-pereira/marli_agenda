import 'package:flutter_test/flutter_test.dart';
import 'package:marli_agenda/models/cliente.dart';

void main() {
  group('Cliente', () {
    final criadoEm = DateTime(2026, 4, 28, 10, 0);

    final cliente = Cliente(
      id: 1,
      nome: 'Ana Paula Silva',
      telefone: '61999991234',
      email: 'ana@email.com',
      observacao: 'Cliente VIP',
      criadoEm: criadoEm,
    );

    test('toMap serializa corretamente', () {
      final map = cliente.toMap();

      expect(map['id'], 1);
      expect(map['nome'], 'Ana Paula Silva');
      expect(map['telefone'], '61999991234');
      expect(map['email'], 'ana@email.com');
      expect(map['observacao'], 'Cliente VIP');
      expect(map['criado_em'], criadoEm.toIso8601String());
    });

    test('fromMap desserializa corretamente', () {
      final map = {
        'id': 1,
        'nome': 'Ana Paula Silva',
        'telefone': '61999991234',
        'email': 'ana@email.com',
        'observacao': 'Cliente VIP',
        'criado_em': criadoEm.toIso8601String(),
      };

      final c = Cliente.fromMap(map);

      expect(c.id, 1);
      expect(c.nome, 'Ana Paula Silva');
      expect(c.telefone, '61999991234');
      expect(c.email, 'ana@email.com');
      expect(c.observacao, 'Cliente VIP');
      expect(c.criadoEm, criadoEm);
    });

    test('fromMap com campos opcionais nulos', () {
      final map = {
        'id': 2,
        'nome': 'Carlos',
        'telefone': '61988887777',
        'email': null,
        'observacao': null,
        'criado_em': criadoEm.toIso8601String(),
      };

      final c = Cliente.fromMap(map);

      expect(c.email, isNull);
      expect(c.observacao, isNull);
    });

    test('toMap sem id (novo cliente)', () {
      final novo = Cliente(
        nome: 'Carlos',
        telefone: '61988887777',
        criadoEm: criadoEm,
      );

      final map = novo.toMap();

      expect(map.containsKey('id'), isFalse);
    });

    test('copyWith atualiza campos seletivamente', () {
      final atualizado = cliente.copyWith(nome: 'Ana Paula S.');

      expect(atualizado.nome, 'Ana Paula S.');
      expect(atualizado.telefone, cliente.telefone);
      expect(atualizado.id, cliente.id);
    });
  });
}
