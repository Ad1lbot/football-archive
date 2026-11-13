class Player {
  final String id;
  final String name;

  final String? nationality;
  final String? position;
  final String? team;
  final String? dateOfBirth;
  final String? dateOfDeath;

  final String? jerseyNumber;
  final String? height;
  final String? weight;

  final String? description;

  final String? thumbnailUrl;
  final String? cutoutUrl;
  final String? posterUrl;

  final String? sportsDbId;
  final String? wikidataId;
  final String? apiFootballId;

  final String generation;
  final String dataSource;

  const Player({
    required this.id,
    required this.name,
    this.nationality,
    this.position,
    this.team,
    this.dateOfBirth,
    this.dateOfDeath,
    this.jerseyNumber,
    this.height,
    this.weight,
    this.description,
    this.thumbnailUrl,
    this.cutoutUrl,
    this.posterUrl,
    this.sportsDbId,
    this.wikidataId,
    this.apiFootballId,
    this.generation = 'current',
    this.dataSource = 'api',
  });

  static String? _readString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();

    return result.isEmpty ? null : result;
  }

  factory Player.fromTheSportsDbJson(
    Map<String, dynamic> json,
  ) {
    final playerId = _readString(json['idPlayer']) ?? '';

    return Player(
      id: playerId,
      name: _readString(json['strPlayer']) ?? 'Unknown Player',

      nationality: _readString(json['strNationality']),
      position: _readString(json['strPosition']),
      team: _readString(json['strTeam']),

      dateOfBirth: _readString(json['dateBorn']),
      dateOfDeath: _readString(json['dateDied']),

      jerseyNumber: _readString(json['strNumber']),
      height: _readString(json['strHeight']),
      weight: _readString(json['strWeight']),

      description: _readString(json['strDescriptionEN']),

      thumbnailUrl: _readString(json['strThumb']),
      cutoutUrl: _readString(json['strCutout']),
      posterUrl: _readString(json['strPoster']),

      sportsDbId: playerId,
      wikidataId: _readString(json['idWikidata']),
      apiFootballId: _readString(json['idAPIfootball']),

      generation: 'current',
      dataSource: 'thesportsdb',
    );
  }

  factory Player.fromDatabaseMap(
    Map<String, dynamic> map,
  ) {
    return Player(
      id: map['id'].toString(),
      name: map['name'] ?? 'Unknown Player',

      nationality: map['nationality'],
      position: map['position'],
      team: map['team'],

      dateOfBirth: map['date_of_birth'],
      dateOfDeath: map['date_of_death'],

      jerseyNumber: map['jersey_number'],
      height: map['height'],
      weight: map['weight'],

      description: map['description'],

      thumbnailUrl: map['thumbnail_url'],
      cutoutUrl: map['cutout_url'],
      posterUrl: map['poster_url'],

      sportsDbId: map['sports_db_id'],
      wikidataId: map['wikidata_id'],
      apiFootballId: map['api_football_id'],

      generation: map['generation'] ?? 'current',
      dataSource: map['data_source'] ?? 'local',
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,

      'nationality': nationality,
      'position': position,
      'team': team,

      'date_of_birth': dateOfBirth,
      'date_of_death': dateOfDeath,

      'jersey_number': jerseyNumber,
      'height': height,
      'weight': weight,

      'description': description,

      'thumbnail_url': thumbnailUrl,
      'cutout_url': cutoutUrl,
      'poster_url': posterUrl,

      'sports_db_id': sportsDbId,
      'wikidata_id': wikidataId,
      'api_football_id': apiFootballId,

      'generation': generation,
      'data_source': dataSource,
    };
  }
}
