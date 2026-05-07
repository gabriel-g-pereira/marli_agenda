import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/agendamento/novo_agendamento_screen.dart';
import '../screens/agendamento/detalhe_agendamento_screen.dart';
import '../screens/clientes/lista_clientes_screen.dart';
import '../screens/clientes/novo_cliente_screen.dart';
import '../screens/clientes/detalhe_cliente_screen.dart';
import '../screens/servicos/lista_servicos_screen.dart';
import '../screens/assistente/assistente_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/novo-agendamento',
      builder: (_, __) => const NovoAgendamentoScreen(),
    ),
    GoRoute(
      path: '/agendamento/:id',
      builder: (_, state) => DetalheAgendamentoScreen(
        id: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/clientes',
      builder: (_, __) => const ListaClientesScreen(),
    ),
    GoRoute(
      path: '/novo-cliente',
      builder: (_, __) => const NovoClienteScreen(),
    ),
    GoRoute(
      path: '/detalhe-cliente/:id',
      builder: (_, state) => DetalheClienteScreen(
        id: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/servicos',
      builder: (_, __) => const ListaServicosScreen(),
    ),
    GoRoute(
      path: '/assistente',
      builder: (_, __) => const AssistenteScreen(),
    ),
  ],
);
