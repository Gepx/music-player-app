import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/spotify_api_test_controller.dart';

/// Spotify API Test Screen
/// Interactive testing dashboard for all Spotify API endpoints
class SpotifyApiTestScreen extends StatelessWidget {
  const SpotifyApiTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpotifyApiTestController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify API Tester'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.isConfigured.value
                      ? Icons.check_circle
                      : Icons.error,
                  color: controller.isConfigured.value
                      ? Colors.green
                      : Colors.red,
                ),
                onPressed: () {},
                tooltip: controller.isConfigured.value 
                    ? 'API Configured' 
                    : 'API Not Configured',
              )),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: controller.clearResults,
            tooltip: 'Clear Results',
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration Status Banner
          Obx(() => _buildConfigBanner(controller)),

          // Test Categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection('Configuration', [
                  _buildTestButton(
                    'Check API Configuration',
                    Icons.settings,
                    controller.testCheckConfiguration,
                    color: Colors.blue,
                  ),
                ]),
                const Divider(height: 32),
                _buildSection('Search', [
                  _buildTestButton(
                    'Search Tracks',
                    Icons.search,
                    controller.testSearchTracks,
                  ),
                  _buildTestButton(
                    'Search Albums',
                    Icons.album,
                    controller.testSearchAlbums,
                  ),
                  _buildTestButton(
                    'Search Artists',
                    Icons.person,
                    controller.testSearchArtists,
                  ),
                ]),
                const Divider(height: 32),
                _buildSection('Tracks', [
                  _buildTestButton(
                    'Get Track by ID',
                    Icons.music_note,
                    controller.testGetTrack,
                  ),
                  _buildTestButton(
                    'Get Saved Tracks',
                    Icons.library_music,
                    controller.testGetSavedTracks,
                  ),
                  _buildTestButton(
                    'Save Track',
                    Icons.favorite,
                    controller.testSaveTrack,
                  ),
                ]),
                const Divider(height: 32),
                _buildSection('Albums', [
                  _buildTestButton(
                    'Get Album',
                    Icons.album,
                    controller.testGetAlbum,
                  ),
                  _buildTestButton(
                    'Get Album Tracks',
                    Icons.queue_music,
                    controller.testGetAlbumTracks,
                  ),
                ]),
                const Divider(height: 32),
                _buildSection('Artists', [
                  _buildTestButton(
                    'Get Artist',
                    Icons.person,
                    controller.testGetArtist,
                  ),
                  _buildTestButton(
                    'Get Top Tracks',
                    Icons.trending_up,
                    controller.testGetArtistTopTracks,
                  ),
                ]),
                const Divider(height: 32),
                _buildSection('Playlists', [
                  _buildTestButton(
                    'Get User Playlists',
                    Icons.playlist_play,
                    controller.testGetUserPlaylists,
                  ),
                  _buildTestButton(
                    'Get Playlist',
                    Icons.list,
                    controller.testGetPlaylist,
                  ),
                ]),
                const Divider(height: 32),
                _buildSection('Browse', [
                  _buildTestButton(
                    'Featured Playlists',
                    Icons.star,
                    controller.testGetFeaturedPlaylists,
                  ),
                  _buildTestButton(
                    'New Releases',
                    Icons.new_releases,
                    controller.testGetNewReleases,
                  ),
                ]),
                const Divider(height: 32),
                _buildSection('Recommendations', [
                  _buildTestButton(
                    'Get Recommendations',
                    Icons.auto_awesome,
                    controller.testGetRecommendations,
                  ),
                ]),
                const Divider(height: 32),
                _buildSection('Repository Tests', [
                  _buildTestButton(
                    'Test Music Repository',
                    Icons.storage,
                    controller.testMusicRepository,
                  ),
                  _buildTestButton(
                    'Test Cache',
                    Icons.cached,
                    controller.testCache,
                  ),
                ]),
              ],
            ),
          ),

          // Results Panel
          Obx(() => _buildResultsPanel(controller)),
        ],
      ),
    );
  }

  Widget _buildConfigBanner(SpotifyApiTestController controller) {
    if (!controller.isConfigured.value) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.orange,
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Not Configured',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET to your .env file',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: controller.testCheckConfiguration,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Check Config'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.green,
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Configured ✓',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'OAuth configured - Tokens auto-refresh every hour',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }

  Widget _buildTestButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: color,
        foregroundColor: color != null ? Colors.white : null,
      ),
    );
  }

  Widget _buildResultsPanel(SpotifyApiTestController controller) {
    if (controller.results.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[700]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  'Results',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (controller.isLoading.value)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: controller.results.length,
              itemBuilder: (context, index) {
                final result = controller.results[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildResultItem(result),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(TestResult result) {
    Color statusColor;
    IconData statusIcon;

    switch (result.status) {
      case TestStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case TestStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case TestStatus.loading:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.testName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                result.timestamp,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (result.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              result.message,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
              ),
            ),
          ],
          if (result.data != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result.data.toString(),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

