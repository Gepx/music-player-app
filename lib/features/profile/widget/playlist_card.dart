import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/models/app/app_models.dart';
import 'package:music_player/utils/constants/colors.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({super.key, required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    final trackCount = playlist.totalTracks;
    final coverUrl = playlist.coverUrl;

    return InkWell(
      onTap: () {
        Get.snackbar(
          playlist.name,
          'Playlist details coming soon',
          backgroundColor: FColors.darkerGrey,
          colorText: FColors.textWhite,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient:
              coverUrl == null
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FColors.primary, FColors.secondary],
                  )
                  : null,
          image:
              coverUrl != null
                  ? DecorationImage(
                    image: NetworkImage(coverUrl),
                    fit: BoxFit.cover,
                  )
                  : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            if (coverUrl != null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      color: FColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Playlist • $trackCount ${trackCount == 1 ? 'song' : 'songs'}',
                    style: TextStyle(
                      color: FColors.textWhite.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'Poppins',
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
}
