import 'package:flutter/foundation.dart';

import '../data/models/player.dart';
import '../data/models/wikidata_player_facts.dart';
import '../data/repositories/player_repository.dart';

class PlayerProvider extends ChangeNotifier {
  final PlayerRepository _repository;

  PlayerProvider({
    PlayerRepository? repository,
  }) : _repository = repository ?? PlayerRepository();

  List<Player> _players = [];
  List<Player> _favoritePlayers = [];

  Player? _selectedPlayer;
  WikidataPlayerFacts? _historicalFacts;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingDetails = false;
  bool _isLoadingFavorites = false;

  bool _hasMore = true;

  String? _errorMessage;
  String _searchQuery = '';

  static const int _pageSize = 20;

  int _currentOffset = 0;

  List<Player> get players => List.unmodifiable(_players);

  List<Player> get favoritePlayers =>
      List.unmodifiable(_favoritePlayers);

  Player? get selectedPlayer => _selectedPlayer;

  WikidataPlayerFacts? get historicalFacts =>
      _historicalFacts;

  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  bool get isLoadingDetails => _isLoadingDetails;

  bool get isLoadingFavorites => _isLoadingFavorites;

  bool get hasMore => _hasMore;

  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;

  Future<void> loadSavedPlayers({
    bool refresh = false,
  }) async {
    if (_isLoading || _isLoadingMore) return;

    if (refresh) {
      _currentOffset = 0;
      _hasMore = true;
      _players = [];
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _repository.getSavedPlayers(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _players = refresh ? result : [..._players, ...result];

      _currentOffset = _players.length;

      _hasMore = result.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Unable to load saved players.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePlayers() async {
    if (_isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _searchQuery.isNotEmpty) {
      return;
    }

    _isLoadingMore = true;

    notifyListeners();

    try {
      final result = await _repository.getSavedPlayers(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _players = [..._players, ...result];

      _currentOffset = _players.length;

      _hasMore = result.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Unable to load more players.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchPlayers(String query) async {
    _searchQuery = query.trim();
    _errorMessage = null;

    if (_searchQuery.isEmpty) {
      await loadSavedPlayers(refresh: true);
      return;
    }

    _isLoading = true;

    notifyListeners();

    try {
      var result = await _repository.searchPlayers(_searchQuery);

      if (result.isEmpty) {
        result = await _repository.searchSavedPlayers(
          _searchQuery,
          limit: 50,
        );
      }

      _players = result;
      _currentOffset = result.length;
      _hasMore = false;
    } catch (e) {
      _errorMessage = 'Unable to search players.';
      _players = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlayerDetails(String playerId) async {
    _isLoadingDetails = true;
    _selectedPlayer = null;
    _historicalFacts = null;
    _errorMessage = null;

    notifyListeners();

    try {
      final player = await _repository.getPlayerDetails(playerId);

      _selectedPlayer = player;

      if (player == null) {
        _errorMessage = 'Player information not found.';
        return;
      }

      if (player.wikidataId != null) {
        _historicalFacts =
            await _repository.getHistoricalFacts(
          player.wikidataId!,
        );
      }
    } catch (e) {
      _errorMessage = 'Unable to load player information.';
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<bool> addPlayer(Player player) async {
    try {
      await _repository.addPlayer(player);

      await loadSavedPlayers(refresh: true);

      return true;
    } catch (e) {
      _errorMessage = 'Unable to add player.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlayer(Player player) async {
    try {
      final updated = await _repository.updatePlayer(player);

      if (updated == 0) {
        _errorMessage = 'Player record not found.';
        notifyListeners();
        return false;
      }

      await loadSavedPlayers(refresh: true);

      return true;
    } catch (e) {
      _errorMessage = 'Unable to update player.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlayer(String playerId) async {
    try {
      final deleted = await _repository.deletePlayer(playerId);

      if (deleted == 0) return false;

      _players.removeWhere((player) => player.id == playerId);

      _favoritePlayers.removeWhere(
        (player) => player.id == playerId,
      );

      if (_selectedPlayer?.id == playerId) {
        _selectedPlayer = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Unable to delete player.';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;

    notifyListeners();

    try {
      _favoritePlayers =
          await _repository.getFavoritePlayers();
    } catch (e) {
      _errorMessage = 'Unable to load favorites.';
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(String playerId) async {
    try {
      final isFavorite =
          await _repository.isFavorite(playerId);

      if (isFavorite) {
        await _repository.removeFavorite(playerId);
      } else {
        await _repository.addFavorite(playerId);
      }

      await loadFavorites();

      return true;
    } catch (e) {
      _errorMessage = 'Unable to update favorite.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> isFavorite(String playerId) {
    return _repository.isFavorite(playerId);
  }

  void clearSearch() {
    _searchQuery = '';
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
