import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/database.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'providers/agendamento_provider.dart';
import 'providers/assistente_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/servico_provider.dart';
import 'repositories/agendamento_repository.dart';
import 'repositories/cliente_repository.dart';
import 'repositories/servico_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização necessária para desktop (Windows/Linux/macOS)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting('pt_BR');
  final db = await AppDatabase.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ClienteProvider(ClienteRepository(db))..carregar(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ServicoProvider(ServicoRepository(db))..carregar(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AgendamentoProvider(AgendamentoRepository(db))..carregar(),
        ),
        ChangeNotifierProvider(create: (_) => AssistenteProvider()),
      ],
      child: const MarliAgendaApp(),
    ),
  );
}

class MarliAgendaApp extends StatelessWidget {
  const MarliAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MarliAgenda',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
    );
  }
}
