import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/services/auth/auth_service.dart';
import 'package:music_player/data/repositories/playlist_repository.dart';
import 'package:music_player/data/models/app/app_models.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/models/user_model.dart';
import 'package:music_player/features/profile/widget/profile_content.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService.instance;
  final PlaylistRepository _playlistRepository = PlaylistRepository.instance;
  UserModel? _currentUser;
  List<PlaylistModel> _playlists = [];
  bool _isLoading = true;
  bool _isLoadingPlaylists = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
      if (user != null) {
        _loadPlaylists();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('❌ Error loading user data: $e');
    }
  }

  Future<void> _loadPlaylists() async {
    setState(() {
      _isLoadingPlaylists = true;
    });
    try {
      final playlists = await _playlistRepository.getUserPlaylists();
      setState(() {
        _playlists = playlists;
        _isLoadingPlaylists = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPlaylists = false;
      });
      debugPrint('❌ Error loading playlists: $e');
    }
  }

  void _handleSeeAllPlaylists() {
    Get.snackbar(
      'Coming Soon',
      'Full playlists view coming soon',
      backgroundColor: FColors.darkerGrey,
      colorText: FColors.textWhite,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FColors.black,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: FColors.primary),
                )
                : ProfileContent(
                  user: _currentUser,
                  playlists: _playlists,
                  isLoadingPlaylists: _isLoadingPlaylists,
                  onSeeAllPlaylists: _handleSeeAllPlaylists,
                ),
      ),
    );
  }
}
