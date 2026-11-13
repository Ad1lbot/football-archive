import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/player.dart';

class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final directory = await getDatabasesPath();
    final path = p.join(directory, 'football_archive.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        nationality TEXT,
        position TEXT,
        team TEXT,
        date_of_birth TEXT,
        date_of_death TEXT,
        jersey_number TEXT,
        height TEXT,
        weight TEXT,
        description TEXT,
        thumbnail_url TEXT,
        cutout_url TEXT,
        poster_url TEXT,
        sports_db_id TEXT,
        wikidata_id TEXT,
        api_football_id TEXT,
        generation TEXT DEFAULT 'current',
        data_source TEXT DEFAULT 'local'
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        player_id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        FOREIGN KEY (player_id)
        REFERENCES players(id)
        ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_players_name ON players(name)',
    );

    await db.execute(
      'CREATE INDEX idx_players_team ON players(team)',
    );
  }

  Future<int> insertPlayer(Player player) async {
    final db = await database;

    return db.transaction((txn) async {
      final updated = await txn.update(
        'players',
        player.toDatabaseMap(),
        where: 'id = ?',
        whereArgs: [player.id],
      );

      if (updated > 0) return updated;

      return txn.insert(
        'players',
        player.toDatabaseMap(),
      );
    });
  }

  Future<int> updatePlayer(Player player) async {
    final db = await database;

    return db.update(
      'players',
      player.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(String playerId) async {
    final db = await database;

    return db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [playerId],
    );
  }

  Future<Player?> getPlayerById(String playerId) async {
    final db = await database;

    final results = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [playerId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    return Player.fromDatabaseMap(results.first);
  }

  Future<List<Player>> getAllPlayers({
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;

    final results = await db.query(
      'players',
      orderBy: 'name COLLATE NOCASE ASC',
      limit: limit,
      offset: offset,
    );

    return results.map(Player.fromDatabaseMap).toList();
  }

  Future<List<Player>> searchPlayers(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;

    final results = await db.query(
      'players',
      where: '''
        name LIKE ?
        OR team LIKE ?
        OR nationality LIKE ?
        OR position LIKE ?
      ''',
      whereArgs: List.filled(4, '%$query%'),
      orderBy: 'name COLLATE NOCASE ASC',
      limit: limit,
      offset: offset,
    );

    return results.map(Player.fromDatabaseMap).toList();
  }

  Future<int> getPlayerCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM players',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> addFavorite(String playerId) async {
    final db = await database;

    await db.insert(
      'favorites',
      {
        'player_id': playerId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(String playerId) async {
    final db = await database;

    await db.delete(
      'favorites',
      where: 'player_id = ?',
      whereArgs: [playerId],
    );
  }

  Future<List<Player>> getFavoritePlayers() async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT players.*
      FROM players
      INNER JOIN favorites
      ON players.id = favorites.player_id
      ORDER BY favorites.created_at DESC
    ''');

    return results.map(Player.fromDatabaseMap).toList();
  }

  Future<bool> isFavorite(String playerId) async {
    final db = await database;

    final results = await db.query(
      'favorites',
      where: 'player_id = ?',
      whereArgs: [playerId],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  Future<void> close() async {
    final db = await database;

    await db.close();
    _database = null;
  }
}
