import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/agendamento_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/servico_provider.dart';
import '../home/home_widgets.dart';

class DetalheAgendamentoScreen extends StatelessWidget {
  final int id;

  const DetalheAgendamentoScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final agendamento =
        context.watch<AgendamentoProvider>().buscarPorId(id);

    if (agendamento == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Agendamento')),
        body: const Center(child: Text('Agendamento não encontrado.')),
      );
    }

    final cliente =
        context.read<ClienteProvider>().buscarPorId(agendamento.clienteId);
    final servico =
        context.read<ServicoProvider>().buscarPorId(agendamento.servicoId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Agendamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir agendamento',
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _CabecalhoCard(agendamento: agendamento),
            if (cliente != null) _ClienteCard(cliente: cliente),
            if (servico != null) _ServicoCard(servico: servico),
            if (agendamento.observacao != null &&
                agendamento.observacao!.isNotEmpty)
              _infoCard(
                titulo: 'OBSERVAÇÃO',
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(agendamento.observacao!,
                      style: TextStyle(color: Colors.grey[700])),
                ),
              ),
            if (agendamento.status == 'agendado')
              _BotoesStatus(
                onConcluir: () =>
                    _alterarStatus(context, 'concluido'),
                onCancelar: () =>
                    _alterarStatus(context, 'cancelado'),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _alterarStatus(
      BuildContext context, String novoStatus) async {
    await context
        .read<AgendamentoProvider>()
        .atualizarStatus(id, novoStatus);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(novoStatus == 'concluido'
            ? 'Serviço marcado como concluído!'
            : 'Agendamento cancelado.'),
        backgroundColor:
            novoStatus == 'concluido' ? accentColor : warningColor,
      ),
    );
    context.go('/');
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir agendamento?'),
        content:
            const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context
                  .read<AgendamentoProvider>()
                  .excluir(id);
              if (!context.mounted) return;
              context.go('/');
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

Widget _infoCard({required String titulo, required Widget child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding:
            const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          titulo,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 1,
          ),
        ),
      ),
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      ),
    ],
  );
}

class _CabecalhoCard extends StatelessWidget {
  final agendamento;

  const _CabecalhoCard({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusChip(status: agendamento.status),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.calendar_today,
                color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              DateFormat("EEEE, dd/MM/yyyy", 'pt_BR')
                  .format(agendamento.dataHora),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time,
                color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              DateFormat('HH:mm').format(agendamento.dataHora),
              style: const TextStyle(
                  color: Colors.white, fontSize: 16),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final cliente;

  const _ClienteCard({required this.cliente});

  @override
  Widget build(BuildContext context) {
    return _infoCard(
      titulo: 'CLIENTE',
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: secondaryColor,
          child: Text(cliente.nome[0],
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(cliente.nome,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(children: [
          const Icon(Icons.phone, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(cliente.telefone),
        ]),
      ),
    );
  }
}

class _ServicoCard extends StatelessWidget {
  final servico;

  const _ServicoCard({required this.servico});

  @override
  Widget build(BuildContext context) {
    return _infoCard(
      titulo: 'SERVIÇO',
      child: ListTile(
        leading: const Icon(Icons.local_laundry_service,
            color: primaryColor, size: 32),
        title: Text(servico.nome,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'R\$ ${servico.preco.toStringAsFixed(2)}',
          style: const TextStyle(
              color: accentColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _BotoesStatus extends StatelessWidget {
  final VoidCallback onConcluir;
  final VoidCallback onCancelar;

  const _BotoesStatus(
      {required this.onConcluir, required this.onCancelar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALTERAR STATUS',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.white),
                label: const Text('CONCLUÍDO',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onConcluir,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined,
                    color: warningColor),
                label: const Text('CANCELAR',
                    style: TextStyle(color: warningColor)),
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: warningColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onCancelar,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
