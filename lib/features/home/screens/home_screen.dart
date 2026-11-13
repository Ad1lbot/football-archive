import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/player.dart';
import '../../../providers/player_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  Timer? _debounce;

  final List<String> _suggestions = [
    'Cristiano Ronaldo',
    'Jude Bellingham',
    'Harry Kane',
    'Zinedine Zidane',
    'Pelé',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlayerProvider>().loadSavedPlayers();
      }
    });
  }

  void _search(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 600),
      () {
        if (mounted) {
          context.read<PlayerProvider>().searchPlayers(value);
        }
      },
    );
  }

  void _selectSuggestion(String name) {
    _searchController.text = name;

    context.read<PlayerProvider>().searchPlayers(name);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),

                  const SizedBox(height: 32),

                  _buildWelcomeSection(),

                  const SizedBox(height: 26),

                  _buildSearchBar(),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    'EXPLORE FOOTBALL',
                    'Discover legendary players and modern stars',
                  ),

                  const SizedBox(height: 16),

                  _buildSuggestions(),

                  const SizedBox(height: 32),

                  _buildSectionTitle(
                    'PLAYER DATABASE',
                    'Your saved football collection',
                  ),

                  const SizedBox(height: 16),
                ]),
              ),
            ),

            Consumer<PlayerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                }

                if (provider.errorMessage != null &&
                    provider.players.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(
                      Icons.wifi_off,
                      'Unable to load players',
                      provider.errorMessage!,
                    ),
                  );
                }

                if (provider.players.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(
                      Icons.sports_soccer,
                      'Your archive starts here',
                      'Search for your favourite footballers '
                          'to build your personal collection.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;

                      final columns = width >= 750 ? 3 : 2;

                      return SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final player = provider.players[index];

                            return _buildPlayerCard(player);
                          },
                          childCount: provider.players.length,
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.4),
            ),
          ),
          child: const Icon(
            Icons.sports_soccer,
            color: AppTheme.primary,
            size: 27,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FOOTBALL',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'ARCHIVE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings coming soon.'),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE BEAUTIFUL GAME,',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppTheme.primary,
          ),
        ),

        const SizedBox(height: 9),

        const Text(
          'Every Legend.\nEvery Generation.',
          style: TextStyle(
            fontSize: 31,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Explore football legends, discover today\'s stars '
          'and preserve the history of football.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _search,
      onSubmitted: (value) {
        _debounce?.cancel();

        context.read<PlayerProvider>().searchPlayers(value);
      },
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Search football players...',
        prefixIcon: const Icon(
          Icons.search,
          color: AppTheme.primary,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            _searchController.clear();
            _debounce?.cancel();

            context.read<PlayerProvider>().clearSearch();
            context.read<PlayerProvider>().loadSavedPlayers(
              refresh: true,
            );
          },
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppTheme.primary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Wrap(
      spacing: 9,
      runSpacing: 10,
      children: _suggestions.map((name) {
        return InkWell(
          onTap: () => _selectSuggestion(name),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.surfaceLight,
              ),
            ),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surfaceLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                color: AppTheme.surfaceLight,
                child: player.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: player.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const Icon(
                            Icons.person,
                            size: 65,
                            color: AppTheme.textSecondary,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person,
                        size: 65,
                        color: AppTheme.textSecondary,
                      ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  player.team ?? 'Club unavailable',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  player.position ?? 'Position unavailable',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 58,
              color: AppTheme.primary,
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
