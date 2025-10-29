import 'package:flutter/material.dart';
import 'package:music_player/features/search/widget/search_content.dart';
import 'package:music_player/features/search/widget/search_header.dart';
import 'package:music_player/features/search/widget/subwidget/search_results_empty.dart';
import 'package:music_player/utils/constants/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  void _onSearchChanged() {
    setState(() {});
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
              child:
                  _isSearching
                      ? const SearchResultsEmpty()
                      : const SearchContent(),
            ),
          ],
        ),
      ),
    );
  }
}
