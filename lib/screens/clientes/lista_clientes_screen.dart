import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/cliente_provider.dart';

class ListaClientesScreen extends StatefulWidget {
  const ListaClientesScreen({super.key});

  @override
  State<ListaClientesScreen> createState() => _ListaClientesScreenState();
}

class _ListaClientesScreenState extends State<ListaClientesScreen> {
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
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
        title: const Text('Clientes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon:
                    const Icon(Icons.search, color: primaryColor),
                suffixIcon: _busca.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          setState(() => _busca = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 12),
              ),
              onChanged: (v) => setState(() => _busca = v),
            ),
          ),
          Expanded(child: _buildLista()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/novo-cliente'),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildLista() {
    return Consumer<ClienteProvider>(
      builder: (context, provider, _) {
        final filtrados = provider.clientes
            .where((c) =>
                c.nome.toLowerCase().contains(_busca.toLowerCase()))
            .toList()
          ..sort((a, b) => a.nome.compareTo(b.nome));

        if (filtrados.isEmpty) return _buildEstadoVazio();

        return ListView.separated(
          itemCount: filtrados.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 72),
          itemBuilder: (context, i) {
            final c = filtrados[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor,
                child: Text(
                  c.nome[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(c.nome,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600)),
              subtitle: Row(children: [
                const Icon(Icons.phone,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(c.telefone,
                    style: const TextStyle(fontSize: 13)),
              ]),
              trailing: const Icon(Icons.chevron_right,
                  color: Colors.grey),
              onTap: () =>
                  context.push('/detalhe-cliente/${c.id}'),
            );
          },
        );
      },
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            _busca.isEmpty
                ? 'Nenhum cliente cadastrado'
                : 'Nenhum resultado para "$_busca"',
            style:
                const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (_busca.isEmpty) ...[
            const SizedBox(height: 8),
            Text('Toque no + para cadastrar',
                style: TextStyle(color: Colors.grey[400])),
          ],
        ],
      ),
    );
  }
}
