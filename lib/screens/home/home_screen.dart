import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/agendamento_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/servico_provider.dart';
import 'home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _diaSelecionado = DateTime.now();

  Future<void> _selecionarDia() async {
    final selecionado = await showDatePicker(
      context: context,
      initialDate: _diaSelecionado,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );
    if (selecionado != null) {
      setState(() => _diaSelecionado = selecionado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final agendamentoProvider = context.watch<AgendamentoProvider>();
    final clienteProvider = context.watch<ClienteProvider>();
    final servicoProvider = context.watch<ServicoProvider>();

    final lista = agendamentoProvider.agendamentos
        .where((a) => DateUtils.isSameDay(a.dataHora, _diaSelecionado))
        .toList()
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResumoCard(
            dia: _diaSelecionado,
            total: lista.length,
            onTap: _selecionarDia,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'AGENDAMENTOS DO DIA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? _buildEstadoVazio()
                : _buildLista(lista, clienteProvider, servicoProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/novo-agendamento'),
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Row(children: [
        Icon(Icons.local_laundry_service, color: Colors.white),
        SizedBox(width: 8),
        Text('MarliAgenda'),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.people),
          tooltip: 'Clientes',
          onPressed: () => context.push('/clientes'),
        ),
        IconButton(
          icon: const Icon(Icons.design_services),
          tooltip: 'Serviços',
          onPressed: () => context.push('/servicos'),
        ),
      ],
    );
  }

  Widget _buildLista(List agendamentos, ClienteProvider clienteProvider,
      ServicoProvider servicoProvider) {
    return ListView.builder(
      itemCount: agendamentos.length,
      itemBuilder: (context, i) {
        final a = agendamentos[i];
        final cliente = clienteProvider.buscarPorId(a.clienteId);
        final servico = servicoProvider.buscarPorId(a.servicoId);
        return AgendamentoCard(
          agendamento: a,
          nomeCliente: cliente?.nome ?? '—',
          nomeServico: servico?.nome ?? '—',
        );
      },
    );
  }

  Widget _buildEstadoVazio() {
    final eHoje = DateUtils.isSameDay(_diaSelecionado, DateTime.now());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            eHoje
                ? 'Nenhum agendamento para hoje'
                : 'Nenhum agendamento neste dia',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text('Toque no + para adicionar',
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final DateTime dia;
  final int total;
  final VoidCallback onTap;

  const _ResumoCard({
    required this.dia,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final eHoje = DateUtils.isSameDay(dia, DateTime.now());
    final prefixo = eHoje ? 'Hoje' : DateFormat("EEEE", 'pt_BR').format(dia);
    final dataFormatada = DateFormat("d 'de' MMMM", 'pt_BR').format(dia);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📅 $prefixo, $dataFormatada',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total agendamento(s)',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_outlined,
                color: Colors.white54, size: 22),
          ],
        ),
      ),
    ),
    );
  }
}
