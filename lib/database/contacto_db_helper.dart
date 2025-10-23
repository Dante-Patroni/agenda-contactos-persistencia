import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:agenda_contactos/models/contacto.dart';

class ContactoDBHelper {
  // --- Patrón Singleton ---
  ContactoDBHelper._internal();
  static final ContactoDBHelper instance = ContactoDBHelper._internal();

  static Database? _db;
  static const String _dbName = 'contactos.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'contactos';

  // --- Obtener la base de datos ---
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // --- Inicializar la base ---
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createSchema,
      onUpgrade: (db, oldVersion, newVersion) async {
        // futuro: migraciones o cambios de esquema
      },
    );
  }

  // --- Crear las tablas ---
  Future<void> _createSchema(Database db, int _) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        telefono TEXT NOT NULL,
        email TEXT NOT NULL,
        direccion TEXT NOT NULL,
        genero TEXT NOT NULL
      );
    ''');

    // Índice para acelerar búsquedas
    await db.execute('CREATE INDEX idx_nombre ON $_tableName (nombre);');
  }

  // --- CRUD ---

  // INSERT
  Future<int> insertContacto(Contacto contacto) async {
    final db = await database;
    return await db.insert(
      _tableName,
      contacto.toMap,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // SELECT con filtro opcional
  Future<List<Contacto>> getContactos({String? search, String orderBy = 'apellido ASC'}) async {
  final db = await database;
  
  final hasSearch = search != null && search.trim().isNotEmpty;
  final where = hasSearch ? '(nombre LIKE ? OR apellido LIKE ?)' : null;
  final whereArgs = hasSearch 
      ? ['%${search!.trim()}%', '%${search.trim()}%'] 
      : null;

  final rows = await db.query(
    _tableName,
    where: where,
    whereArgs: whereArgs,
    orderBy: orderBy,
  );

  return rows.map((m) => Contacto.fromMap(m)).toList(growable: false);
}

  // GET BY ID
  Future<Contacto?> getContactoById(int id) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Contacto.fromMap(rows.first);
  }

  // UPDATE
  Future<int> updateContacto(Contacto contacto) async {
    final db = await database;
    return await db.update(
      _tableName,
      contacto.toMap,
      where: 'id = ?',
      whereArgs: [contacto.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // DELETE
  Future<int> deleteContacto(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE ALL
  Future<void> deleteAllContactos() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
