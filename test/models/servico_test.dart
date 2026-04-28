import 'package:flutter_test/flutter_test.dart';
import 'package:marli_agenda/models/servico.dart';

void main() {
  group('Servico', () {
    final servico = Servico(
      id: 1,
      nome: 'Lavagem Simples',
      preco: 35.00,
      duracaoMinutos: 60,
    );

    test('toMap serializa corretamente', () {
      final map = servico.toMap();

      expect(map['id'], 1);
      expect(map['nome'], 'Lavagem Simples');
      expect(map['preco'], 35.00);
      expect(map['duracao_minutos'], 60);
    });

    test('fromMap desserializa corretamente', () {
      final map = {
        'id': 1,
        'nome': 'Lavagem Simples',
        'preco': 35.00,
        'duracao_minutos': 60,
      };

      final s = Servico.fromMap(map);

      expect(s.id, 1);
      expect(s.nome, 'Lavagem Simples');
      expect(s.preco, 35.00);
      expect(s.duracaoMinutos, 60);
    });

    test('toMap sem id (novo serviço)', () {
      final novo = Servico(
        nome: 'Lavagem a Seco',
        preco: 80.00,
        duracaoMinutos: 90,
      );

      final map = novo.toMap();

      expect(map.containsKey('id'), isFalse);
    });

    test('copyWith atualiza preço', () {
      final atualizado = servico.copyWith(preco: 40.00);

      expect(atualizado.preco, 40.00);
      expect(atualizado.nome, servico.nome);
    });
  });
}
