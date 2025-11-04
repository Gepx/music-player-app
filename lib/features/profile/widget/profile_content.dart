import 'package:flutter/material.dart';
import 'package:music_player/data/models/user_model.dart';
import 'package:music_player/data/models/app/app_models.dart';
import 'package:music_player/features/profile/widget/profile_header.dart';
import 'package:music_player/features/profile/widget/playlists_section.dart';
import 'package:music_player/features/profile/widget/logout_button.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.user,
    required this.playlists,
    required this.isLoadingPlaylists,
    required this.onSeeAllPlaylists,
  });

  final UserModel? user;
  final List<PlaylistModel> playlists;
  final bool isLoadingPlaylists;
  final VoidCallback onSeeAllPlaylists;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProfileHeader(user: user),
        ),
        SliverToBoxAdapter(
          child: PlaylistsSection(
            playlists: playlists,
            isLoading: isLoadingPlaylists,
            onSeeAll: onSeeAllPlaylists,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 32),
            child: const LogoutButton(),
          ),
        ),
      ],
    );
  }
}

