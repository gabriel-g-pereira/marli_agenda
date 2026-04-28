import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/agendamento.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'concluido' => ('CONCLUÍDO ✓', accentColor),
      'cancelado' => ('CANCELADO', warningColor),
      _ => ('AGENDADO', secondaryColor),
    };

    return Chip(
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 11)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class AgendamentoCard extends StatelessWidget {
  final Agendamento agendamento;
  final String nomeCliente;
  final String nomeServico;

  const AgendamentoCard({
    super.key,
    required this.agendamento,
    required this.nomeCliente,
    required this.nomeServico,
  });

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('HH:mm').format(agendamento.dataHora);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: Text(hora,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
        title: Text(nomeCliente,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(nomeServico),
        trailing: StatusChip(status: agendamento.status),
        onTap: () => context.push('/agendamento/${agendamento.id}'),
      ),
    );
  }
}
