import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/agendamento_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/servico_provider.dart';
import '../home/home_widgets.dart';

class DetalheClienteScreen extends StatelessWidget {
  final int id;

  const DetalheClienteScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final cliente =
        context.watch<ClienteProvider>().buscarPorId(id);

    if (cliente == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cliente')),
        body:
            const Center(child: Text('Cliente não encontrado.')),
      );
    }

    final agendamentos = context
        .watch<AgendamentoProvider>()
        .agendamentos
        .where((a) => a.clienteId == id)
        .toList()
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));

    final servicoProvider = context.read<ServicoProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/clientes'),
        ),
        title: const Text('Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir cliente',
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _CabecalhoCliente(cliente: cliente),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HISTÓRICO',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Novo agendamento'),
                    onPressed: () =>
                        context.push('/novo-agendamento'),
                  ),
                ],
              ),
            ),
            if (agendamentos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhum agendamento registrado.',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ...agendamentos.take(5).map((a) {
                final servico =
                    servicoProvider.buscarPorId(a.servicoId);
                return AgendamentoCard(
                  agendamento: a,
                  nomeCliente: cliente.nome,
                  nomeServico: servico?.nome ?? '—',
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir cliente?'),
        content:
            const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context
                  .read<ClienteProvider>()
                  .excluir(id);
              if (!context.mounted) return;
              context.go('/clientes');
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CabecalhoCliente extends StatelessWidget {
  final cliente;

  const _CabecalhoCliente({required this.cliente});

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
          CircleAvatar(
            radius: 28,
            backgroundColor: secondaryColor,
            child: Text(
              cliente.nome[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(cliente.nome,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.phone,
                color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(cliente.telefone,
                style: const TextStyle(
                    color: Colors.white70)),
          ]),
          if (cliente.email != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.email,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(cliente.email!,
                  style: const TextStyle(
                      color: Colors.white70)),
            ]),
          ],
          if (cliente.observacao != null) ...[
            const SizedBox(height: 8),
            Text(cliente.observacao!,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
