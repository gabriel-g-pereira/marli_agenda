import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    _db ??= await _inicializar();
    return _db!;
  }

  static Future<Database> _inicializar() async {
    final caminho = join(await getDatabasesPath(), 'marli_agenda.db');
    return openDatabase(
      caminho,
      version: 1,
      onCreate: _criarTabelas,
    );
  }

  static Future<void> _criarTabelas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        nome      TEXT NOT NULL,
        telefone  TEXT NOT NULL,
        email     TEXT,
        observacao TEXT,
        criado_em TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE servicos (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        nome             TEXT NOT NULL,
        preco            REAL NOT NULL,
        duracao_minutos  INTEGER NOT NULL DEFAULT 60
      )
    ''');

    await db.execute('''
      CREATE TABLE agendamentos (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id  INTEGER NOT NULL,
        servico_id  INTEGER NOT NULL,
        data_hora   TEXT NOT NULL,
        status      TEXT NOT NULL DEFAULT 'agendado',
        observacao  TEXT,
        criado_em   TEXT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id),
        FOREIGN KEY (servico_id) REFERENCES servicos(id)
      )
    ''');

    await _seedServicos(db);
  }

  static Future<void> _seedServicos(Database db) async {
    final servicos = [
      {'nome': 'Lavagem Simples', 'preco': 35.00, 'duracao_minutos': 60},
      {'nome': 'Lavagem a Seco', 'preco': 80.00, 'duracao_minutos': 90},
      {'nome': 'Lavagem + Passagem', 'preco': 55.00, 'duracao_minutos': 90},
      {'nome': 'Lavagem de Edredom', 'preco': 90.00, 'duracao_minutos': 120},
      {'nome': 'Lavagem de Tapete', 'preco': 70.00, 'duracao_minutos': 120},
      {'nome': 'Higienização de Tênis', 'preco': 45.00, 'duracao_minutos': 60},
    ];
    for (final s in servicos) {
      await db.insert('servicos', s);
    }
  }
}
