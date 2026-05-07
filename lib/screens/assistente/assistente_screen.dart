import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/mensagem_chat.dart';
import '../../providers/assistente_provider.dart';

class AssistenteScreen extends StatefulWidget {
  const AssistenteScreen({super.key});

  @override
  State<AssistenteScreen> createState() => _AssistenteScreenState();
}

class _AssistenteScreenState extends State<AssistenteScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final _sugestoes = [
    'Quem tem agendamento hoje?',
    'Agendamentos pendentes desta semana',
    'Qual serviço é mais agendado?',
    'Quantos clientes tenho cadastrados?',
    'Qual o valor total dos agendamentos de hoje?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviar(String texto) {
    if (texto.trim().isEmpty) return;
    _controller.clear();
    context.read<AssistenteProvider>().enviarMensagem(texto);
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assistente IA',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text('✨ Powered by Gemini',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Limpar conversa',
            onPressed: () =>
                context.read<AssistenteProvider>().limparConversa(),
          ),
        ],
      ),
      body: Consumer<AssistenteProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              if (provider.mensagens.isEmpty) _buildSugestoes(),
              Expanded(
                child: provider.mensagens.isEmpty
                    ? _buildEstadoVazio()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.mensagens.length +
                            (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == provider.mensagens.length) {
                            return _buildLoading();
                          }
                          return _buildBalao(provider.mensagens[i]);
                        },
                      ),
              ),
              _buildInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSugestoes() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber[700]),
            const SizedBox(width: 6),
            Text(
              'Perguntas sugeridas:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700]),
            ),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _sugestoes
                .map((s) => ActionChip(
                      label: Text(s,
                          style: const TextStyle(
                              fontSize: 12, color: primaryColor)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: primaryColor.withOpacity(0.4)),
                      onPressed: () => _enviar(s),
                    ))
                .toList(),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Olá! Sou a Mari, sua assistente IA.',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Pergunte sobre seus agendamentos,\nclientes ou serviços.',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBalao(MensagemChat msg) {
    final isIA = msg.remetente == RemetenteMensagem.ia;
    return Align(
      alignment: isIA ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: isIA ? 0 : 48,
          right: isIA ? 48 : 0,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isIA ? Colors.white : primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isIA ? 4 : 16),
            bottomRight: Radius.circular(isIA ? 16 : 4),
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isIA)
              Row(children: [
                Icon(Icons.auto_awesome, size: 14, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text('Mari',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber[700],
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
              ]),
            Text(
              msg.texto,
              style: TextStyle(
                color: isIA ? Colors.grey[800] : Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4)
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: primaryColor),
            ),
            const SizedBox(width: 10),
            const Text('Mari está pensando...',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _enviar,
              decoration: InputDecoration(
                hintText: 'Pergunte sobre seus agendamentos...',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: primaryColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: primaryColor,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _enviar(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}
