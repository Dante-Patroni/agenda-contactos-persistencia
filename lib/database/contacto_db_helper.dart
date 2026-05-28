import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:agenda_contactos/models/contacto.dart';

/// Helper de acceso a datos para `Contacto` usando SQLite.
///
/// Responsabilidades:
/// - Administrar la conexión a la base (lifecycle).
/// - Crear y versionar el esquema.
/// - Exponer operaciones CRUD tipadas a `Contacto`.
///
/// Patrón: Singleton para compartir la misma instancia/DB en toda la app.
class ContactoDBHelper {
  // --- Patrón Singleton ---
  ContactoDBHelper._internal();
  static final ContactoDBHelper instance = ContactoDBHelper._internal();

  static Database? _db;//conexión guardada en memoria
  static const String _dbName = 'contactos.db';//nombre del archivo SQLite
  static const int _dbVersion = 2;
  static const String _tableName = 'contactos';/*/ nombre de la tabla principal */

  // --- Obtener la base de datos ---
  /// Retorna la instancia de base de datos, inicializándola si es necesario.
  Future<Database> get database async {//la llama automáticamente
    if (_db != null) return _db!;//Si está creada uso esta
    _db = await _initDB();//Sino la creo
    return _db!;
  }

  // --- Inicializar la base ---
  /// Abre/crea la base en el path por defecto de la app.
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);//obtengo el path completo
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createSchema,//Si no existe la creo
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migración a versión 2: añadir columna is_sync
          await db.execute('ALTER TABLE $_tableName ADD COLUMN is_sync INTEGER DEFAULT 1;');
        }
      },
    );
  }

  // --- Crear las tablas ---
  /// Crea el esquema inicial de la tabla e índices auxiliares.
  /// Los campos coinciden con las propiedades del modelo `Contacto`.
  Future<void> _createSchema(Database db, int _) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        telefono TEXT NOT NULL,
        email TEXT NOT NULL,
        direccion TEXT NOT NULL,
        genero TEXT NOT NULL,
        is_sync INTEGER DEFAULT 1
      );
    ''');

    // Índice para acelerar búsquedas
    await db.execute('CREATE INDEX idx_nombre ON $_tableName (nombre);');
  }

  // --- CRUD ---

  // INSERT
  /// Inserta un contacto y retorna el id autogenerado.
  Future<int> insertContacto(Contacto contacto) async {
    final db = await database;//Obtengo la base de datos
    return await db.insert(//Queda gardado en forma
      _tableName,
      contacto.toMap,//Convierto a Map
      conflictAlgorithm: ConflictAlgorithm.abort,//No sobrescribir en conflicto
    );
  }

  // SELECT con filtro opcional
  /// Obtiene contactos, con filtro opcional por nombre/apellido y orden configurable.
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

  // PENDIENTES DE SINCRONIZACIÓN
  /// Retorna los contactos que fueron creados offline y no han sido sincronizados
  Future<List<Contacto>> getContactosPendientes() async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'is_sync = 0',
    );
    return rows.map((m) => Contacto.fromMap(m)).toList(growable: false);
  }

  // GET BY ID
  /// Retorna un `Contacto` por id o `null` si no existe.
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
  /// Actualiza un contacto existente (por `id`). Retorna filas afectadas.
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
  /// Elimina un contacto por `id`. Retorna filas afectadas.
  Future<int> deleteContacto(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE ALL
  /// Elimina todos los contactos. Útil para escenarios de pruebas/demo.
  Future<void> deleteAllContactos() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
