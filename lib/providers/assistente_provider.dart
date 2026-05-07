import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/database.dart';
import '../models/cliente.dart';
import '../models/mensagem_chat.dart';
import '../models/servico.dart';
import '../repositories/agendamento_repository.dart';
import '../repositories/cliente_repository.dart';
import '../repositories/servico_repository.dart';

class AssistenteProvider extends ChangeNotifier {
  final List<MensagemChat> _mensagens = [];
  bool _isLoading = false;

  List<MensagemChat> get mensagens => List.unmodifiable(_mensagens);
  bool get isLoading => _isLoading;

  static const _sistemaPrompt =
      'Você é um assistente de gestão chamado "Mari", '
      'especialista na lavanderia da Marli Pereira em Ceilândia Sul, Brasília/DF. '
      'Responda sempre em português brasileiro, de forma clara, direta e amigável. '
      'Use os dados fornecidos no contexto para responder com precisão. '
      'Quando listar agendamentos, use formato de lista com horário e nome do cliente. '
      'Nunca invente dados que não estejam no contexto fornecido.\n\n';

  static const _modelos = ['gemini-2.5-flash', 'gemini-2.0-flash'];

  Future<String> _chamarGemini(String prompt) async {
    for (final modelo in _modelos) {
      for (var tentativa = 0; tentativa < 2; tentativa++) {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelo:generateContent?key=$geminiApiKey',
        );

        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.3,
              'maxOutputTokens': 2048,
            },
          }),
        );

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = json['candidates'] as List<dynamic>;
          final parts = candidates[0]['content']['parts'] as List<dynamic>;
          return parts[0]['text'] as String;
        }

        if (response.statusCode == 503) {
          // Servidor sobrecarregado — aguarda e tenta de novo
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        // Outro erro: tenta próximo modelo
        break;
      }
    }

    throw Exception(
        'Assistente temporariamente indisponível. Tente novamente em alguns instantes.');
  }

  Future<String> _buildContexto() async {
    final db = await AppDatabase.instance;
    final agendamentos = await AgendamentoRepository(db).listarTodos();
    final clientes = await ClienteRepository(db).listarTodos();
    final servicos = await ServicoRepository(db).listarTodos();
    final hoje = DateTime.now();

    final agendHoje = agendamentos
        .where((a) => DateUtils.isSameDay(a.dataHora, hoje))
        .toList()
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    final agendMes = agendamentos
        .where((a) => a.dataHora.year == hoje.year && a.dataHora.month == hoje.month)
        .toList()
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    final agendPendentes = agendamentos
        .where((a) => a.status == 'agendado' && a.dataHora.isAfter(hoje))
        .toList();

    String _nomeCliente(int id) => clientes
        .firstWhere((c) => c.id == id,
            orElse: () => Cliente(nome: 'Desconhecido', telefone: '', criadoEm: hoje))
        .nome;

    String _nomeServico(int id) => servicos
        .firstWhere((s) => s.id == id,
            orElse: () => Servico(nome: 'Desconhecido', preco: 0, duracaoMinutos: 0))
        .nome;

    double _precoServico(int id) => servicos
        .firstWhere((s) => s.id == id,
            orElse: () => Servico(nome: 'Desconhecido', preco: 0, duracaoMinutos: 0))
        .preco;

    final sb = StringBuffer();
    sb.writeln('=== DADOS DA LAVANDERIA MARLI PEREIRA ===');
    sb.writeln('Data/hora atual: $hoje');
    sb.writeln('');
    sb.writeln('--- AGENDAMENTOS DE HOJE (${agendHoje.length}) ---');
    for (final a in agendHoje) {
      final preco = _precoServico(a.servicoId);
      sb.writeln(
          '${a.dataHora.hour.toString().padLeft(2, '0')}:${a.dataHora.minute.toString().padLeft(2, '0')} | ${_nomeCliente(a.clienteId)} | ${_nomeServico(a.servicoId)} | R\$ ${preco.toStringAsFixed(2)} | Status: ${a.status}');
    }
    sb.writeln('');
    // Resumo histórico de meses anteriores
    final mesesAnteriores = agendamentos
        .where((a) =>
            a.dataHora.year < hoje.year ||
            (a.dataHora.year == hoje.year && a.dataHora.month < hoje.month))
        .fold<Map<String, List<dynamic>>>({}, (map, a) {
          final chave =
              '${a.dataHora.year.toString().padLeft(4, '0')}-${a.dataHora.month.toString().padLeft(2, '0')}';
          (map[chave] ??= []).add(a);
          return map;
        });

    if (mesesAnteriores.isNotEmpty) {
      sb.writeln('--- HISTÓRICO DE MESES ANTERIORES ---');
      final chaves = mesesAnteriores.keys.toList()..sort();
      for (final chave in chaves) {
        final lista = mesesAnteriores[chave]!;
        final totalFat =
            lista.fold<double>(0, (s, a) => s + _precoServico(a.servicoId));
        final contagemServicos = <int, int>{};
        for (final a in lista) {
          contagemServicos[a.servicoId] =
              (contagemServicos[a.servicoId] ?? 0) + 1;
        }
        final servicoMaisFreqId = contagemServicos.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;
        final partes = chave.split('-');
        sb.writeln(
            'Mês ${partes[1]}/${partes[0]} | ${lista.length} agendamento(s) | Faturamento: R\$ ${totalFat.toStringAsFixed(2)} | Serviço mais agendado: ${_nomeServico(servicoMaisFreqId)}');
      }
      sb.writeln('');
    }

    sb.writeln('--- TODOS OS AGENDAMENTOS DO MÊS ${hoje.month}/${hoje.year} (${agendMes.length}) ---');
    for (final a in agendMes) {
      final preco = _precoServico(a.servicoId);
      sb.writeln(
          '${a.dataHora.day.toString().padLeft(2, '0')}/${a.dataHora.month} ${a.dataHora.hour.toString().padLeft(2, '0')}:${a.dataHora.minute.toString().padLeft(2, '0')} | ${_nomeCliente(a.clienteId)} | ${_nomeServico(a.servicoId)} | R\$ ${preco.toStringAsFixed(2)} | Status: ${a.status}');
    }
    final totalMes = agendMes.fold<double>(0, (sum, a) => sum + _precoServico(a.servicoId));
    sb.writeln('Total faturamento do mês: R\$ ${totalMes.toStringAsFixed(2)}');
    sb.writeln('');
    sb.writeln('--- PRÓXIMOS AGENDAMENTOS PENDENTES (${agendPendentes.length}) ---');
    for (final a in agendPendentes.take(10)) {
      sb.writeln(
          '${a.dataHora.day}/${a.dataHora.month} ${a.dataHora.hour.toString().padLeft(2, '0')}:${a.dataHora.minute.toString().padLeft(2, '0')} | ${_nomeCliente(a.clienteId)} | ${_nomeServico(a.servicoId)}');
    }
    sb.writeln('');
    sb.writeln('--- CLIENTES CADASTRADOS (${clientes.length}) ---');
    for (final c in clientes) {
      sb.writeln('${c.nome} | Tel: ${c.telefone}');
    }
    sb.writeln('');
    sb.writeln('--- SERVIÇOS OFERECIDOS ---');
    for (final s in servicos) {
      sb.writeln('${s.nome} | R\$ ${s.preco.toStringAsFixed(2)}');
    }
    return sb.toString();
  }

  Future<void> enviarMensagem(String texto) async {
    if (texto.trim().isEmpty || _isLoading) return;

    _mensagens
        .add(MensagemChat(texto: texto, remetente: RemetenteMensagem.usuario));
    _isLoading = true;
    notifyListeners();

    try {
      final contexto = await _buildContexto();
      final prompt =
          '$_sistemaPrompt$contexto\n\n=== PERGUNTA DA MARLI ===\n$texto';
      final resposta = await _chamarGemini(prompt);
      _mensagens
          .add(MensagemChat(texto: resposta, remetente: RemetenteMensagem.ia));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _mensagens.add(MensagemChat(
        texto: msg,
        remetente: RemetenteMensagem.ia,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limparConversa() {
    _mensagens.clear();
    notifyListeners();
  }
}
