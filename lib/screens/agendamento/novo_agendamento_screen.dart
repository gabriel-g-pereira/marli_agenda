import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/agendamento.dart';
import '../../providers/agendamento_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/servico_provider.dart';

class NovoAgendamentoScreen extends StatefulWidget {
  const NovoAgendamentoScreen({super.key});

  @override
  State<NovoAgendamentoScreen> createState() => _NovoAgendamentoScreenState();
}

class _NovoAgendamentoScreenState extends State<NovoAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _obsController = TextEditingController();

  int? _clienteId;
  int? _servicoId;
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  // Erros manuais dos DropdownMenu (não têm validator nativo)
  String? _erroCliente;
  String? _erroServico;

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Novo Agendamento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _dropdownCliente(),
            if (_erroCliente != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(_erroCliente!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 4),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16, color: secondaryColor),
              label: const Text('Cadastrar novo cliente',
                  style: TextStyle(color: secondaryColor, fontSize: 13)),
              onPressed: () async {
                await context.push('/novo-cliente');
              },
            ),
            const SizedBox(height: 12),
            _dropdownServico(),
            if (_erroServico != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(_erroServico!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            _seletorData(),
            const SizedBox(height: 16),
            _seletorHora(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _obsController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                hintText: 'Ex: entrega em domicílio, peça delicada...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _salvar,
                child: const Text('CONFIRMAR AGENDAMENTO',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownCliente() {
    final clientes = context.watch<ClienteProvider>().clientes;
    return DropdownMenu<int>(
      expandedInsets: EdgeInsets.zero,
      label: const Text('Cliente'),
      leadingIcon: const Icon(Icons.person, color: primaryColor),
      errorText: _erroCliente,
      menuHeight: 300,
      dropdownMenuEntries: clientes
          .map((c) => DropdownMenuEntry<int>(value: c.id!, label: c.nome))
          .toList(),
      onSelected: (v) => setState(() {
        _clienteId = v;
        _erroCliente = null;
      }),
    );
  }

  Widget _dropdownServico() {
    final servicos = context.watch<ServicoProvider>().servicos;
    return DropdownMenu<int>(
      expandedInsets: EdgeInsets.zero,
      label: const Text('Serviço'),
      leadingIcon:
          const Icon(Icons.local_laundry_service, color: primaryColor),
      errorText: _erroServico,
      menuHeight: 300,
      dropdownMenuEntries: servicos
          .map((s) => DropdownMenuEntry<int>(
                value: s.id!,
                label: '${s.nome} — R\$ ${s.preco.toStringAsFixed(2)}',
              ))
          .toList(),
      onSelected: (v) => setState(() {
        _servicoId = v;
        _erroServico = null;
      }),
    );
  }

  Widget _seletorData() {
    return InkWell(
      onTap: () async {
        final data = await showDatePicker(
          context: context,
          initialDate: _dataSelecionada,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme:
                  const ColorScheme.light(primary: primaryColor),
            ),
            child: child!,
          ),
        );
        if (data != null) setState(() => _dataSelecionada = data);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data',
          prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
          suffixIcon: Icon(Icons.chevron_right),
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
      ),
    );
  }

  Widget _seletorHora() {
    return InkWell(
      onTap: () async {
        final hora = await showTimePicker(
          context: context,
          initialTime: _horaSelecionada,
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme:
                  const ColorScheme.light(primary: primaryColor),
            ),
            child: child!,
          ),
        );
        if (hora != null) setState(() => _horaSelecionada = hora);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Horário',
          prefixIcon: Icon(Icons.access_time, color: primaryColor),
          suffixIcon: Icon(Icons.chevron_right),
        ),
        child: Text(_horaSelecionada.format(context)),
      ),
    );
  }

  Future<void> _salvar() async {
    // Valida os dropdowns manualmente
    setState(() {
      _erroCliente = _clienteId == null ? 'Selecione um cliente' : null;
      _erroServico = _servicoId == null ? 'Selecione um serviço' : null;
    });

    if (!_formKey.currentState!.validate()) return;
    if (_clienteId == null || _servicoId == null) return;

    final dataHora = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaSelecionada.hour,
      _horaSelecionada.minute,
    );

    final obs = _obsController.text.trim();
    final novo = Agendamento(
      clienteId: _clienteId!,
      servicoId: _servicoId!,
      dataHora: dataHora,
      status: 'agendado',
      observacao: obs.isEmpty ? null : obs,
      criadoEm: DateTime.now(),
    );

    await context.read<AgendamentoProvider>().salvar(novo);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Agendamento confirmado!'),
        backgroundColor: accentColor,
      ),
    );
    context.go('/');
  }
}
