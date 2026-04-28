import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';

class _TelefoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (digits.length == 11 && i == 7) buffer.write('-');
      if (digits.length <= 10 && i == 6) buffer.write('-');
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class NovoClienteScreen extends StatefulWidget {
  const NovoClienteScreen({super.key});

  @override
  State<NovoClienteScreen> createState() => _NovoClienteScreenState();
}

class _NovoClienteScreenState extends State<NovoClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/clientes'),
        ),
        title: const Text('Novo Cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              textCapitalization: TextCapitalization.words,
              decoration:
                  const InputDecoration(labelText: 'Nome completo *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [_TelefoneFormatter()],
              decoration: const InputDecoration(
                labelText: 'Telefone *',
                hintText: '(XX) XXXXX-XXXX',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                final digits = v.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 10) return 'Telefone inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _obsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Observação'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _salvar,
                child: const Text('SALVAR CLIENTE',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final obs = _obsCtrl.text.trim();

    final novo = Cliente(
      nome: _nomeCtrl.text.trim(),
      telefone: _telefoneCtrl.text.trim(),
      email: email.isEmpty ? null : email,
      observacao: obs.isEmpty ? null : obs,
      criadoEm: DateTime.now(),
    );

    await context.read<ClienteProvider>().salvar(novo);
    if (!mounted) return;
    context.pop();
  }
}
