import 'package:dio/dio.dart';

import '../models/wikidata_player_facts.dart';

class WikidataDataSource {
  static const String _baseUrl =
      'https://www.wikidata.org/w/api.php';

  final Dio _dio;

  WikidataDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Accept': 'application/json',
                  'User-Agent':
                      'FootballArchive/1.0 (Flutter Student Project)',
                },
              ),
            );

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<String?> searchFootballer(String name) async {
    if (name.trim().isEmpty) return null;

    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'action': 'wbsearchentities',
        'search': name,
        'language': 'en',
        'format': 'json',
        'limit': 10,
      },
    );

    final results = response.data['search'];

    if (results is! List) return null;

    for (final result in results) {
      if (result is! Map) continue;

      final label = result['label']?.toString() ?? '';
      final description =
          result['description']?.toString().toLowerCase() ?? '';

      final isExactMatch =
          _normalize(label) == _normalize(name);

      final isFootballer =
          description.contains('footballer') ||
          description.contains('football player') ||
          description.contains('soccer player');

      if (isExactMatch && isFootballer) {
        return result['id']?.toString();
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> _getEntity(
    String wikidataId,
  ) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'action': 'wbgetentities',
        'ids': wikidataId,
        'props': 'labels|descriptions|claims',
        'languages': 'en',
        'format': 'json',
      },
    );

    final entities = response.data['entities'];

    if (entities is! Map) return null;

    final entity = entities[wikidataId];

    if (entity is! Map || entity['missing'] != null) {
      return null;
    }

    return Map<String, dynamic>.from(entity);
  }

  String? _getDate(
    Map<String, dynamic> claims,
    String property,
  ) {
    final entries = claims[property];

    if (entries is! List || entries.isEmpty) {
      return null;
    }

    for (final entry in entries) {
      final time = entry['mainsnak']?['datavalue']
          ?['value']?['time'];

      if (time is String) {
        final match = RegExp(
          r'^[+-]?(\d{1,4}-\d{2}-\d{2})',
        ).firstMatch(time);

        if (match != null) {
          return match.group(1);
        }
      }
    }

    return null;
  }

  List<String> _getEntityIds(
    Map<String, dynamic> claims,
    String property,
  ) {
    final entries = claims[property];

    if (entries is! List) return [];

    final ids = <String>{};

    for (final entry in entries) {
      final id = entry['mainsnak']?['datavalue']
          ?['value']?['id'];

      if (id is String && id.startsWith('Q')) {
        ids.add(id);
      }
    }

    return ids.toList();
  }

  Future<Map<String, String>> _getEntityLabels(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return {};

    final labels = <String, String>{};

    const batchSize = 40;

    for (var i = 0; i < ids.length; i += batchSize) {
      final batch = ids.skip(i).take(batchSize).toList();

      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'action': 'wbgetentities',
          'ids': batch.join('|'),
          'props': 'labels',
          'languages': 'en',
          'format': 'json',
        },
      );

      final entities = response.data['entities'];

      if (entities is! Map) continue;

      for (final id in batch) {
        final entity = entities[id];

        final label = entity?['labels']?['en']?['value'];

        if (label is String && label.isNotEmpty) {
          labels[id] = label;
        }
      }
    }

    return labels;
  }

  Future<WikidataPlayerFacts?> getPlayerFacts(
    String wikidataId,
  ) async {
    if (!RegExp(r'^Q\d+$').hasMatch(wikidataId)) {
      throw ArgumentError('Invalid Wikidata entity ID.');
    }

    final entity = await _getEntity(wikidataId);

    if (entity == null) return null;

    final labels = entity['labels'];
    final descriptions = entity['descriptions'];
    final claims = entity['claims'];

    if (claims is! Map) return null;

    final claimMap = Map<String, dynamic>.from(claims);

    final name =
        labels?['en']?['value']?.toString() ?? 'Unknown Player';

    final description =
        descriptions?['en']?['value']?.toString();

    final nationalityIds =
        _getEntityIds(claimMap, 'P27');

    final positionIds =
        _getEntityIds(claimMap, 'P413');

    final clubIds =
        _getEntityIds(claimMap, 'P54');

    final occupationIds =
        _getEntityIds(claimMap, 'P106');

    final allIds = {
      ...nationalityIds,
      ...positionIds,
      ...clubIds,
      ...occupationIds,
    }.toList();

    final entityLabels = await _getEntityLabels(allIds);

    List<String> resolve(List<String> ids) {
      return ids
          .map((id) => entityLabels[id])
          .whereType<String>()
          .toList();
    }

    return WikidataPlayerFacts(
      wikidataId: wikidataId,
      name: name,
      description: description,
      dateOfBirth: _getDate(claimMap, 'P569'),
      dateOfDeath: _getDate(claimMap, 'P570'),
      nationalities: resolve(nationalityIds),
      positions: resolve(positionIds),
      clubs: resolve(clubIds),
      occupations: resolve(occupationIds),
    );
  }
}
