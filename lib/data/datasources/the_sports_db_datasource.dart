import 'package:dio/dio.dart';

import '../models/player.dart';

class TheSportsDbDataSource {
  static const String _baseUrl =
      'https://www.thesportsdb.com/api/v1/json/123';

  final Dio _dio;

  TheSportsDbDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 15),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
  }

  Future<List<Player>> searchPlayers(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return [];
    }

    final response = await _dio.get(
      '/searchplayers.php',
      queryParameters: {
        'p': trimmedQuery,
      },
    );

    final data = response.data;

    if (data is! Map) {
      return [];
    }

    final rawPlayers = data['player'];

    if (rawPlayers is! List) {
      return [];
    }

    final players = rawPlayers
        .whereType<Map>()
        .map(
          (json) => Player.fromTheSportsDbJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .where((player) => player.id.isNotEmpty)
        .where(
          (player) =>
              _normalize(player.name) ==
              _normalize(trimmedQuery),
        )
        .toList();

    return players;
  }

  Future<Player?> getPlayerById(String playerId) async {
    if (playerId.trim().isEmpty) {
      return null;
    }

    final response = await _dio.get(
      '/lookupplayer.php',
      queryParameters: {
        'id': playerId,
      },
    );

    final data = response.data;

    if (data is! Map) {
      return null;
    }

    final rawPlayers = data['players'] ?? data['player'];

    if (rawPlayers is! List || rawPlayers.isEmpty) {
      return null;
    }

    for (final item in rawPlayers) {
      if (item is! Map) {
        continue;
      }

      final player = Player.fromTheSportsDbJson(
        Map<String, dynamic>.from(item),
      );

      if (player.id == playerId) {
        return player;
      }
    }

    return null;
  }
}
