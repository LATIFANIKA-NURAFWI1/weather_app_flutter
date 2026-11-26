import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/enums/view_state.dart';
import '../core/theme/app_theme.dart';
import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().loadLocalData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectLocation(LocationModel location) async {
    await context.read<SearchViewModel>().addToHistory(location);
    if (mounted) {
      Navigator.pop(context, location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.searchTop,
              AppTheme.searchMid,
              AppTheme.searchBottom,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ambient Glow Orb 1 (Top Left)
            Positioned(
              top: -60,
              left: -50,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color.fromRGBO(99, 137, 175, 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Ambient Glow Orb 2 (Middle Right)
            Positioned(
              top: 260,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color.fromRGBO(56, 92, 128, 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Glass Header
                  _buildHeader(context),

                  // Search Bar
                  _buildSearchBar(context),

                  // Scrollable Body
                  Expanded(
                    child: Consumer<SearchViewModel>(
                      builder: (context, searchVM, _) {
                        return _buildContent(context, searchVM);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button with Frosted Glass
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.22),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    customBorder: const CircleBorder(),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Screen Title
          const Text(
            'Cari Lokasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),

          // Balance Spacer
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.32),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.20),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: Color.fromRGBO(255, 255, 255, 0.75),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama kota...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(255, 255, 255, 0.60),
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      context.read<SearchViewModel>().searchWithDebounce(value);
                      setState(() {});
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      context.read<SearchViewModel>().searchWithDebounce('');
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 0.35),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchViewModel searchVM) {
    if (_searchController.text.isNotEmpty) {
      return _buildSearchResultsView(context, searchVM);
    }
    return _buildFavoritesAndHistoryView(context, searchVM);
  }

  Widget _buildSearchResultsView(
      BuildContext context, SearchViewModel searchVM) {
    switch (searchVM.searchState) {
      case ViewState.loading:
        return const LoadingView(message: 'Mencari lokasi...');

      case ViewState.error:
        return ErrorView(
          message: searchVM.searchError,
          onRetry: () =>
              searchVM.searchWithDebounce(_searchController.text),
        );

      case ViewState.empty:
        return const EmptyView(
          message: 'Kota tidak ditemukan',
          submessage: 'Periksa ejaan nama kota atau coba kata kunci lain',
          icon: Icons.location_off_rounded,
        );

      case ViewState.success:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 255, 255, 0.20),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.22),
                        blurRadius: 32,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < searchVM.searchResults.length; i++) ...[
                        if (i > 0)
                          Container(
                            height: 1,
                            color: const Color.fromRGBO(255, 255, 255, 0.10),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        _buildSearchResultRow(
                          searchVM.searchResults[i],
                          searchVM,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSearchResultRow(
      LocationModel location, SearchViewModel searchVM) {
    final isFav = searchVM.isFavorite(location);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectLocation(location),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Pin Icon Circle Badge
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.15),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                ),
              ),
              const SizedBox(width: 12),

              // City Name & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (location.admin1 != null &&
                            location.admin1!.isNotEmpty)
                          location.admin1!,
                        location.country,
                      ].join(', '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(255, 255, 255, 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Coordinates (Mono Font)
              Text(
                '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Color.fromRGBO(255, 255, 255, 0.50),
                ),
              ),

              const SizedBox(width: 6),

              // Star Favorite Toggle
              IconButton(
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  size: 20,
                  color: isFav
                      ? AppTheme.goldAccent
                      : const Color.fromRGBO(255, 255, 255, 0.40),
                ),
                onPressed: () => searchVM.toggleFavorite(location),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesAndHistoryView(
      BuildContext context, SearchViewModel searchVM) {
    final hasFavorites = searchVM.favorites.isNotEmpty;
    final hasHistory = searchVM.searchHistory.isNotEmpty;

    if (!hasFavorites && !hasHistory) {
      return const EmptyView(
        message: 'Belum ada riwayat atau favorit',
        submessage: 'Pilih lokasi untuk melihat prakiraan cuaca',
        icon: Icons.cloud_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // === SECTION 1: FAVORIT ===
        if (hasFavorites) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Text(
                  '⭐',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 8),
                Text(
                  'Favorit',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(255, 255, 255, 0.90),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          ...searchVM.favorites.map((location) {
            return Dismissible(
              key: ValueKey('fav_${location.latitude}_${location.longitude}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.dangerAccent.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => searchVM.removeFavorite(location),
              child: _buildLocationCard(
                location: location,
                leadingIcon: Icons.star,
                leadingColor: AppTheme.goldAccent,
                leadingBg: const Color.fromRGBO(251, 191, 36, 0.20),
                leadingBorder: const Color.fromRGBO(252, 211, 77, 0.30),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color.fromRGBO(255, 255, 255, 0.60),
                ),
                onTap: () => _selectLocation(location),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // Subtle Frosted Gradient Divider
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color.fromRGBO(255, 255, 255, 0.20),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // === SECTION 2: RIWAYAT PENCARIAN ===
        if (hasHistory) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color.fromRGBO(255, 255, 255, 0.75),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Riwayat Pencarian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(255, 255, 255, 0.90),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: searchVM.clearHistory,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_sweep,
                          size: 15,
                          color: AppTheme.dangerAccent,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Hapus Semua',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.dangerAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...searchVM.searchHistory.map((location) {
            final isFav = searchVM.isFavorite(location);
            return _buildLocationCard(
              location: location,
              leadingIcon: Icons.access_time,
              leadingColor: const Color.fromRGBO(255, 255, 255, 0.70),
              leadingBg: const Color.fromRGBO(255, 255, 255, 0.10),
              leadingBorder: const Color.fromRGBO(255, 255, 255, 0.15),
              trailing: IconButton(
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  size: 20,
                  color: isFav
                      ? AppTheme.goldAccent
                      : const Color.fromRGBO(255, 255, 255, 0.40),
                ),
                onPressed: () => searchVM.toggleFavorite(location),
              ),
              onTap: () => _selectLocation(location),
            );
          }),
        ],

        const SizedBox(height: 16),

        // Bottom Airy Hint
        const Center(
          child: Column(
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 40,
                color: Color.fromRGBO(255, 255, 255, 0.35),
              ),
              SizedBox(height: 6),
              Text(
                'Pilih lokasi untuk melihat prakiraan cuaca',
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromRGBO(255, 255, 255, 0.45),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationCard({
    required LocationModel location,
    required IconData leadingIcon,
    required Color leadingColor,
    required Color leadingBg,
    required Color leadingBorder,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.16),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Circular Badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: leadingBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: leadingBorder, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Icon(leadingIcon, size: 20, color: leadingColor),
                      ),
                      const SizedBox(width: 14),

                      // Location text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (location.admin1 != null &&
                                    location.admin1!.isNotEmpty)
                                  location.admin1!,
                                location.country,
                              ].join(', '),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color.fromRGBO(255, 255, 255, 0.70),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      trailing,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
