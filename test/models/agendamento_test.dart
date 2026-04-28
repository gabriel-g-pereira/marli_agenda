import 'package:flutter_test/flutter_test.dart';
import 'package:marli_agenda/models/agendamento.dart';

void main() {
  group('Agendamento', () {
    final dataHora = DateTime(2026, 4, 28, 9, 0);
    final criadoEm = DateTime(2026, 4, 27, 18, 0);

    final agendamento = Agendamento(
      id: 1,
      clienteId: 10,
      servicoId: 2,
      dataHora: dataHora,
      status: 'agendado',
      observacao: 'Entrega em domicílio',
      criadoEm: criadoEm,
    );

    test('toMap serializa corretamente', () {
      final map = agendamento.toMap();

      expect(map['id'], 1);
      expect(map['cliente_id'], 10);
      expect(map['servico_id'], 2);
      expect(map['data_hora'], dataHora.toIso8601String());
      expect(map['status'], 'agendado');
      expect(map['observacao'], 'Entrega em domicílio');
      expect(map['criado_em'], criadoEm.toIso8601String());
    });

    test('fromMap desserializa corretamente', () {
      final map = {
        'id': 1,
        'cliente_id': 10,
        'servico_id': 2,
        'data_hora': dataHora.toIso8601String(),
        'status': 'agendado',
        'observacao': 'Entrega em domicílio',
        'criado_em': criadoEm.toIso8601String(),
      };

      final a = Agendamento.fromMap(map);

      expect(a.id, 1);
      expect(a.clienteId, 10);
      expect(a.servicoId, 2);
      expect(a.dataHora, dataHora);
      expect(a.status, 'agendado');
      expect(a.observacao, 'Entrega em domicílio');
    });

    test('fromMap com observacao nula', () {
      final map = {
        'id': 2,
        'cliente_id': 10,
        'servico_id': 2,
        'data_hora': dataHora.toIso8601String(),
        'status': 'agendado',
        'observacao': null,
        'criado_em': criadoEm.toIso8601String(),
      };

      final a = Agendamento.fromMap(map);

      expect(a.observacao, isNull);
    });

    test('toMap sem id (novo agendamento)', () {
      final novo = Agendamento(
        clienteId: 10,
        servicoId: 2,
        dataHora: dataHora,
        status: 'agendado',
        criadoEm: criadoEm,
      );

      final map = novo.toMap();

      expect(map.containsKey('id'), isFalse);
    });

    test('copyWith atualiza status', () {
      final concluido = agendamento.copyWith(status: 'concluido');

      expect(concluido.status, 'concluido');
      expect(concluido.clienteId, agendamento.clienteId);
    });
  });
}
