import 'dart:async';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/sofware.dart';

class DatabaseProvider {
  static const String tableName = 'software';
  static const String columnId = 'id';
  static const String columnNombre = 'nombre';
  static const String columnVersion = 'version';
  static const String columnSistemaOperativo = 'sistemaOperativo';

  DatabaseProvider._();

  static final DatabaseProvider instance = DatabaseProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'paises.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnNombre TEXT,
        $columnVersion TEXT,
        $columnSistemaOperativo TEXT
      )
    ''');
  }

  Future<int> insertPais(Sofware sofware) async {
    final db = await database;
    final values = {
      DatabaseProvider.columnNombre: sofware.nombre,
      DatabaseProvider.columnVersion: sofware.version,
      DatabaseProvider.columnSistemaOperativo: sofware.sistemaOperativo,
    };
    return await db.insert(DatabaseProvider.tableName, values);
  }

  Future<int> updatePais(Sofware sofware) async {
    final db = await database;
    final values = {
      DatabaseProvider.columnId: sofware.id,
      DatabaseProvider.columnNombre: sofware.nombre,
      DatabaseProvider.columnVersion: sofware.version,
      DatabaseProvider.columnSistemaOperativo: sofware.sistemaOperativo,
    };
    return await db.update(DatabaseProvider.tableName, values,
        where: '${DatabaseProvider.columnId} = ?', whereArgs: [sofware.id]);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> queryRowById(int id) async {
    Database db = await instance.database;
    return await db.query(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }
}
