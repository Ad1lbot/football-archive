import 'package:dio/dio.dart';

import '../database/app_database.dart';
import '../datasources/the_sports_db_datasource.dart';
import '../datasources/wikidata_datasource.dart';
import '../models/player.dart';
import '../models/wikidata_player_facts.dart';

class PlayerRepository {
  final TheSportsDbDataSource _sportsDb;
  final WikidataDataSource _wikidata;
  final AppDatabase _database;

  PlayerRepository({
    TheSportsDbDataSource? sportsDb,
    WikidataDataSource? wikidata,
    AppDatabase? database,
  })  : _sportsDb = sportsDb ?? TheSportsDbDataSource(),
        _wikidata = wikidata ?? WikidataDataSource(),
        _database = database ?? AppDatabase.instance;

  Future<List<Player>> searchPlayers(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) return [];

    try {
      final remotePlayers =
          await _sportsDb.searchPlayers(trimmedQuery);

      for (final player in remotePlayers) {
        await _database.insertPlayer(player);
      }

      return remotePlayers;
    } on DioException {
      return _database.searchPlayers(trimmedQuery);
    }
  }

  Future<Player?> getPlayerDetails(String playerId) async {
    try {
      final remotePlayer =
          await _sportsDb.getPlayerById(playerId);

      if (remotePlayer != null) {
        await _database.insertPlayer(remotePlayer);
        return remotePlayer;
      }
    } on DioException {
      // Fall back to locally cached information.
    }

    return _database.getPlayerById(playerId);
  }

  Future<WikidataPlayerFacts?> getHistoricalFacts(
    String wikidataId,
  ) async {
    try {
      return await _wikidata.getPlayerFacts(wikidataId);
    } on DioException {
      return null;
    }
  }

  Future<int> addPlayer(Player player) async {
    return _database.insertPlayer(player);
  }

  Future<int> updatePlayer(Player player) async {
    return _database.updatePlayer(player);
  }

  Future<int> deletePlayer(String playerId) async {
    return _database.deletePlayer(playerId);
  }

  Future<List<Player>> getSavedPlayers({
    int limit = 20,
    int offset = 0,
  }) async {
    return _database.getAllPlayers(
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Player>> searchSavedPlayers(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    return _database.searchPlayers(
      query,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> getPlayerCount() async {
    return _database.getPlayerCount();
  }

  Future<void> addFavorite(String playerId) async {
    await _database.addFavorite(playerId);
  }

  Future<void> removeFavorite(String playerId) async {
    await _database.removeFavorite(playerId);
  }

  Future<List<Player>> getFavoritePlayers() async {
    return _database.getFavoritePlayers();
  }

  Future<bool> isFavorite(String playerId) async {
    return _database.isFavorite(playerId);
  }
}
