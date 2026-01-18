import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../utils/constants/colors.dart';
import 'widgets/playlists_tab.dart';
import '../library/liked_songs_page.dart';

/// Library Page
/// Main page with tabs for Playlists and Liked Songs
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FColors.dark,
      appBar: AppBar(
        backgroundColor: FColors.dark,
        elevation: 0,
        title: const Text(
          'Library',
          style: TextStyle(
            color: FColors.textWhite,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: FColors.primary,
          labelColor: FColors.primary,
          unselectedLabelColor: FColors.darkGrey,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              icon: Icon(Iconsax.music_playlist),
              text: 'Playlists',
            ),
            Tab(
              icon: Icon(Iconsax.heart),
              text: 'Liked Songs',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PlaylistsTab(),
          LikedSongsPage(),
        ],
      ),
    );
  }
}

