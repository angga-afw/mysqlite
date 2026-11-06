import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class Catatan {
  final int? id;
  final String judul;
  final String isi;

  Catatan({this.id, required this.judul, required this.isi});

  Map<String, Object?> toMap() => {'id': id, 'judul': judul, 'isi': isi};

  factory Catatan.fromMap(Map<String, Object?> m) => Catatan(
        id: m['id'] as int?,
        judul: m['judul'] as String,
        isi: m['isi'] as String,
      );
}

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      '$dir/catatan.db',
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE catatan(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          judul TEXT NOT NULL,
          isi TEXT NOT NULL
        )
      '''),
    );
    debugPrint('Database created at $dir/catatan.db');
    return _db!;
  }

  // CREATE
  Future<int> insert(Catatan c) async {
    final db = await database;
    debugPrint('Inserted: ${c.toMap()}');
    return db.insert('catatan', c.toMap()..remove('id'));
  }

  // READ
  Future<List<Catatan>> getAll() async {
    final db = await database;
    final rows = await db.query('catatan', orderBy: 'id DESC');
    return rows.map(Catatan.fromMap).toList();
  }

  // UPDATE
  Future<int> update(Catatan c) async {
    final db = await database;
    return db.update('catatan', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }
}
