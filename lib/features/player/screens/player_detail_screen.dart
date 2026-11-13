import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/player_provider.dart';
import '../../../data/models/player.dart';
import '../../../data/models/wikidata_player_facts.dart';

class PlayerDetailScreen extends StatefulWidget {
  final String playerId;

  const PlayerDetailScreen({
    super.key,
    required this.playerId,
  });

  @override
  State<PlayerDetailScreen> createState() =>
      _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<PlayerProvider>().loadPlayerDetails(
        widget.playerId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text(
          'Player Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetails) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            );
          }

          final player = provider.selectedPlayer;

          if (player == null) {
            return _buildError(provider.errorMessage);
          }

          return _buildProfile(
            player,
            provider.historicalFacts,
          );
        },
      ),
    );
  }

  Widget _buildError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 65,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Player information unavailable',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Unable to retrieve player information.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<PlayerProvider>().loadPlayerDetails(
                  widget.playerId,
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(
    Player player,
    WikidataPlayerFacts? facts,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlayerHeader(player),

          const SizedBox(height: 25),

          _buildSectionTitle('PLAYER INFORMATION'),

          _buildInformationCard([
            _buildInfoRow('Full Name', player.name),
            _buildInfoRow(
              'Nationality',
              player.nationality,
            ),
            _buildInfoRow(
              'Date of Birth',
              player.dateOfBirth ?? facts?.dateOfBirth,
            ),
            _buildInfoRow(
              'Date of Death',
              player.dateOfDeath ?? facts?.dateOfDeath,
            ),
            _buildInfoRow('Position', player.position),
            _buildInfoRow('Current Club', player.team),
            _buildInfoRow('Jersey Number', player.jerseyNumber),
            _buildInfoRow('Height', player.height),
            _buildInfoRow('Weight', player.weight),
          ]),

          if (player.description != null) ...[
            const SizedBox(height: 25),
            _buildSectionTitle('BIOGRAPHY'),
            _buildInformationCard([
              Text(
                player.description!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ]),
          ],

          if (facts != null) ...[
            const SizedBox(height: 25),

            _buildSectionTitle('HISTORICAL RECORDS'),

            if (facts.clubs.isNotEmpty)
              _buildListCard('Recorded Clubs', facts.clubs),

            if (facts.nationalities.isNotEmpty)
              _buildListCard(
                'Nationalities',
                facts.nationalities,
              ),

            if (facts.positions.isNotEmpty)
              _buildListCard(
                'Recorded Positions',
                facts.positions,
              ),

            if (facts.occupations.isNotEmpty)
              _buildListCard(
                'Occupations',
                facts.occupations,
              ),
          ],

          const SizedBox(height: 25),

          const Center(
            child: Text(
              'FOOTBALL ARCHIVE',
              style: TextStyle(
                color: AppTheme.textSecondary,
                letterSpacing: 3,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildPlayerHeader(Player player) {
    final imageUrl = player.posterUrl ??
        player.cutoutUrl ??
        player.thumbnailUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surfaceLight,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 190,
              height: 190,
              color: AppTheme.surfaceLight,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return const Icon(
                          Icons.person,
                          size: 85,
                          color: AppTheme.textSecondary,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      size: 85,
                      color: AppTheme.textSecondary,
                    ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            player.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            player.team ?? 'Club unavailable',
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            player.position ?? 'Position unavailable',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildInformationCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surfaceLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildInformationCard([
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ...values.map(
          (value) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  size: 7,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
