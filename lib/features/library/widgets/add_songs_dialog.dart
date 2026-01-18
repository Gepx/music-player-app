import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../utils/constants/colors.dart';
import '../../../data/services/spotify/spotify_api_service.dart';
import '../../../data/models/spotify/spotify_track.dart';

/// Add Songs Dialog
/// Search and add songs to a playlist
class AddSongsDialog extends StatefulWidget {
  final String playlistId;
  final List<String> existingTrackIds;

  const AddSongsDialog({
    super.key,
    required this.playlistId,
    required this.existingTrackIds,
  });

  @override
  State<AddSongsDialog> createState() => _AddSongsDialogState();
}

class _AddSongsDialogState extends State<AddSongsDialog> {
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  final TextEditingController _searchController = TextEditingController();
  
  List<SpotifyTrack> _searchResults = [];
  Map<String, SpotifyTrack> _selectedTracks = {};
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await _spotify.searchTracks(query, limit: 20);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _toggleTrack(SpotifyTrack track) {
    setState(() {
      if (_selectedTracks.containsKey(track.id)) {
        _selectedTracks.remove(track.id);
      } else {
        _selectedTracks[track.id] = track;
      }
    });
  }

  void _addSelectedTracks() {
    if (_selectedTracks.isNotEmpty) {
      Navigator.pop(context, _selectedTracks.values.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: FColors.darkContainer,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(Iconsax.music_library_2, color: FColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add Songs',
                    style: TextStyle(
                      color: FColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: FColors.textWhite),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: FColors.textWhite,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: 'Search for songs...',
                hintStyle: TextStyle(
                  color: FColors.textWhite.withOpacity(0.4),
                  fontFamily: 'Poppins',
                ),
                prefixIcon: const Icon(Iconsax.search_normal, color: FColors.primary),
                filled: true,
                fillColor: FColors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: FColors.primary),
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _search(value);
                  }
                });
              },
              onSubmitted: _search,
            ),
          ),

          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _buildResults(),
          ),

          // Add Button
          if (_selectedTracks.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: FColors.dark,
                border: Border(
                  top: BorderSide(color: FColors.darkerGrey.withOpacity(0.5)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _addSelectedTracks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add ${_selectedTracks.length} ${_selectedTracks.length == 1 ? 'Song' : 'Songs'}',
                    style: const TextStyle(
                      color: FColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: FColors.primary),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal,
              size: 64,
              color: FColors.textWhite.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for songs to add',
              style: TextStyle(
                color: FColors.textWhite.withOpacity(0.6),
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.music,
              size: 64,
              color: FColors.textWhite.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                color: FColors.textWhite.withOpacity(0.6),
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final track = _searchResults[index];
        final isAlreadyInPlaylist = widget.existingTrackIds.contains(track.id);
        final isSelected = _selectedTracks.containsKey(track.id);
        final imageUrl = track.album?.images.isNotEmpty == true
            ? track.album!.images.first.url
            : null;

        return ListTile(
          enabled: !isAlreadyInPlaylist,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
          title: Text(
            track.name,
            style: TextStyle(
              color: isAlreadyInPlaylist 
                  ? FColors.textWhite.withOpacity(0.4)
                  : FColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.artists.map((a) => a.name).join(', '),
                style: TextStyle(
                  color: FColors.textWhite.withOpacity(0.6),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isAlreadyInPlaylist)
                Text(
                  'Already in playlist',
                  style: TextStyle(
                    color: FColors.primary.withOpacity(0.7),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
            ],
          ),
          trailing: isAlreadyInPlaylist
              ? Icon(
                  Icons.check_circle,
                  color: FColors.primary.withOpacity(0.5),
                )
              : Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleTrack(track),
                  activeColor: FColors.primary,
                  checkColor: FColors.textWhite,
                ),
          onTap: isAlreadyInPlaylist ? null : () => _toggleTrack(track),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: FColors.darkerGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note, color: FColors.darkGrey),
    );
  }
}

