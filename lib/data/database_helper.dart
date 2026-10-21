import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/credit.dart';
import '../models/expense.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  static const _expensesTable = '''
    CREATE TABLE expenses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      category TEXT NOT NULL,
      type TEXT NOT NULL,
      date TEXT NOT NULL,
      description TEXT
    )
  ''';

  static const _creditsTable = '''
    CREATE TABLE credits(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      credit_type TEXT NOT NULL,
      name TEXT NOT NULL,
      amount REAL NOT NULL,
      due_date TEXT NOT NULL,
      plan_type TEXT NOT NULL
    )
  ''';

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'expenses.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(_expensesTable);
        await db.execute(_creditsTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(_creditsTable);
        }
      },
    );
  }

  // ---------------- Expenses ----------------

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('expenses');
    await db.delete('credits');
  }

  Future<int> insert(Expense e) async {
    final db = await database;
    return db.insert('expenses', e.toMap()..remove('id'));
  }

  Future<List<Expense>> getAll() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'date DESC, id DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<int> update(Expense e) async {
    final db = await database;
    return db.update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Credits ----------------

  Future<int> insertCredit(Credit c) async {
    final db = await database;
    return db.insert('credits', c.toMap()..remove('id'));
  }

  Future<List<Credit>> getAllCredits() async {
    final db = await database;
    final rows = await db.query('credits', orderBy: 'due_date ASC');
    return rows.map(Credit.fromMap).toList();
  }

  Future<int> deleteCredit(int id) async {
    final db = await database;
    return db.delete('credits', where: 'id = ?', whereArgs: [id]);
  }
}
