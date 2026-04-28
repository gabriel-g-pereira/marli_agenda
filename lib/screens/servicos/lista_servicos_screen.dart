import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/servico.dart';
import '../../providers/servico_provider.dart';

class ListaServicosScreen extends StatelessWidget {
  const ListaServicosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Serviços'),
      ),
      body: Consumer<ServicoProvider>(
        builder: (context, provider, _) {
          if (provider.servicos.isEmpty) {
            return _buildEstadoVazio();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.servicos.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = provider.servicos[i];
              return _ServicoCard(
                servico: s,
                onEditar: () =>
                    _abrirFormulario(context, servico: s),
                onExcluir: () =>
                    _confirmarExclusao(context, s),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.design_services_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text('Nenhum serviço cadastrado',
              style:
                  TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Toque no + para adicionar',
              style: TextStyle(
                  color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }

  void _abrirFormulario(BuildContext context, {Servico? servico}) {
    final nomeCtrl = TextEditingController(text: servico?.nome);
    final precoCtrl = TextEditingController(
        text: servico != null ? servico.preco.toStringAsFixed(2) : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servico == null ? 'Novo Serviço' : 'Editar Serviço',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nomeCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Nome do serviço *',
                      hintText: 'Ex: Lavagem Simples',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: precoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$) *',
                      prefixText: 'R\$ ',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório';
                      if (double.tryParse(v.replaceAll(',', '.')) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final novo = Servico(
                            id: servico?.id,
                            nome: nomeCtrl.text.trim(),
                            preco: double.parse(
                                precoCtrl.text.replaceAll(',', '.')),
                            duracaoMinutos: 60,
                          );
                          await context.read<ServicoProvider>().salvar(novo);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                        child: Text(
                          servico == null ? 'CADASTRAR' : 'SALVAR',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, Servico s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir serviço?'),
        content: Text(
            'O serviço "${s.nome}" será removido permanentemente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context
                  .read<ServicoProvider>()
                  .excluir(s.id!);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ServicoCard extends StatelessWidget {
  final Servico servico;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _ServicoCard({
    required this.servico,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        child: Row(children: [
          const Icon(Icons.local_laundry_service,
              color: primaryColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servico.nome,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  'R\$ ${servico.preco.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                color: secondaryColor, size: 20),
            onPressed: onEditar,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Colors.red[300], size: 20),
            onPressed: onExcluir,
            tooltip: 'Excluir',
          ),
        ]),
      ),
    );
  }
}
