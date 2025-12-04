import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE todos (
      id $idType,
      title $textType,
      description $textTypeNullable,
      deadline $textType,
      priority $textType,
      category $textType,
      status $textType,
      is_completed $intType,
      created_at $textType,
      updated_at $textType
    )
    ''');
  }

  // Create
  Future<TodoModel> create(TodoModel todo) async {
    final db = await instance.database;
    final id = await db.insert('todos', todo.toMap());
    return todo.copyWith(id: id);
  }

  // Read single todo
  Future<TodoModel?> readTodo(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TodoModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Read all todos
  Future<List<TodoModel>> readAllTodos() async {
    final db = await instance.database;
    const orderBy = 'deadline ASC';
    final result = await db.query('todos', orderBy: orderBy);
    return result.map((json) => TodoModel.fromMap(json)).toList();
  }

  // Read todos by status
  Future<List<TodoModel>> readTodosByStatus(String status) async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'deadline ASC',
    );
    return result.map((json) => TodoModel.fromMap(json)).toList();
  }

  // Read completed todos
  Future<List<TodoModel>> readCompletedTodos() async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'updated_at DESC',
    );
    return result.map((json) => TodoModel.fromMap(json)).toList();
  }

  // Read pending todos
  Future<List<TodoModel>> readPendingTodos() async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'is_completed = ?',
      whereArgs: [0],
      orderBy: 'deadline ASC',
    );
    return result.map((json) => TodoModel.fromMap(json)).toList();
  }

  // Read todos by category
  Future<List<TodoModel>> readTodosByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'deadline ASC',
    );
    return result.map((json) => TodoModel.fromMap(json)).toList();
  }

  // Read today's todos
  Future<List<TodoModel>> readTodayTodos() async {
    final db = await instance.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final result = await db.query(
      'todos',
      where: 'deadline >= ? AND deadline <= ? AND is_completed = ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
        0,
      ],
      orderBy: 'deadline ASC',
    );
    return result.map((json) => TodoModel.fromMap(json)).toList();
  }

  // Search todos
  Future<List<TodoModel>> searchTodos(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'deadline ASC',
    );
    return result.map((json) => TodoModel.fromMap(json)).toList();
  }

  // Update
  Future<int> update(TodoModel todo) async {
    final db = await instance.database;
    return db.update(
      'todos',
      todo.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get statistics
  Future<Map<String, int>> getStatistics() async {
    final db = await instance.database;
    
    final total = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM todos'),
    ) ?? 0;
    
    final completed = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM todos WHERE is_completed = 1'),
    ) ?? 0;
    
    final pending = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM todos WHERE is_completed = 0'),
    ) ?? 0;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
    };
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}