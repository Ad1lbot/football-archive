class WikidataPlayerFacts {
  final String wikidataId;
  final String name;
  final String? description;

  final String? dateOfBirth;
  final String? dateOfDeath;

  final List<String> nationalities;
  final List<String> positions;
  final List<String> clubs;
  final List<String> occupations;

  const WikidataPlayerFacts({
    required this.wikidataId,
    required this.name,
    this.description,
    this.dateOfBirth,
    this.dateOfDeath,
    this.nationalities = const [],
    this.positions = const [],
    this.clubs = const [],
    this.occupations = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'wikidataId': wikidataId,
      'name': name,
      'description': description,
      'dateOfBirth': dateOfBirth,
      'dateOfDeath': dateOfDeath,
      'nationalities': nationalities,
      'positions': positions,
      'clubs': clubs,
      'occupations': occupations,
    };
  }

  factory WikidataPlayerFacts.fromJson(
    Map<String, dynamic> json,
  ) {
    return WikidataPlayerFacts(
      wikidataId: json['wikidataId'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'],
      dateOfBirth: json['dateOfBirth'],
      dateOfDeath: json['dateOfDeath'],
      nationalities: List<String>.from(
        json['nationalities'] ?? [],
      ),
      positions: List<String>.from(
        json['positions'] ?? [],
      ),
      clubs: List<String>.from(
        json['clubs'] ?? [],
      ),
      occupations: List<String>.from(
        json['occupations'] ?? [],
      ),
    );
  }
}
