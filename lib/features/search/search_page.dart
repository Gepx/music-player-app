import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_search_result.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/features/search/widget/search_content.dart';
import 'package:music_player/features/search/widget/search_header.dart';
import 'package:music_player/features/search/widget/subwidget/search_results_empty.dart';
import 'package:music_player/features/search/widget/subwidget/search_results_list.dart';
import 'package:music_player/features/search/widget/subwidget/search_loading.dart';
import 'package:music_player/utils/constants/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SpotifyApiService _spotifyApi = SpotifyApiService.instance;
  
  bool _isSearching = false;
  bool _isLoading = false;
  SpotifySearchResult? _searchResult;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResult = null;
        _errorMessage = null;
      });
      return;
    }

    // Debounce search by 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _spotifyApi.search(
        query: query,
        type: SpotifySearchType.all,
        limit: 10,
      );

      setState(() {
        _searchResult = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() {
        _errorMessage = 'Failed to search. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchResult = null;
      _errorMessage = null;
    });
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Widget _buildSearchContent() {
    if (!_isSearching) {
      return const SearchContent();
    }

    if (_isLoading) {
      return const SearchLoading();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: FColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: FColors.textWhite,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_searchResult == null) {
      return const SearchResultsEmpty();
    }

    return SearchResultsList(searchResult: _searchResult!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            SearchHeader(
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              isSearching: _isSearching,
              onSearchChanged: _onSearchChanged,
              onClearSearch: _clearSearch,
            ),

            // Content
            Expanded(
              child: _buildSearchContent(),
            ),
          ],
        ),
      ),
    );
  }
}
