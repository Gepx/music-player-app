/// Spotify API Constants
/// Contains all Spotify API endpoints and configuration
class SpotifyConstants {
  // Private constructor to prevent instantiation
  SpotifyConstants._();

  // -------------------- API URLs -------------------- //

  /// Base URL for Spotify Web API
  static const String baseUrl = 'https://api.spotify.com/v1';

  // -------------------- API Endpoints -------------------- //

  // Search
  static const String searchEndpoint = '/search';

  // Tracks
  static const String tracksEndpoint = '/tracks';
  static const String savedTracksEndpoint = '/me/tracks';
  static const String trackEndpoint = '/tracks/{id}';

  // Albums
  static const String albumsEndpoint = '/albums';
  static const String savedAlbumsEndpoint = '/me/albums';
  static const String albumEndpoint = '/albums/{id}';
  static const String albumTracksEndpoint = '/albums/{id}/tracks';

  // Artists
  static const String artistsEndpoint = '/artists';
  static const String artistEndpoint = '/artists/{id}';
  static const String artistTopTracksEndpoint = '/artists/{id}/top-tracks';
  static const String artistAlbumsEndpoint = '/artists/{id}/albums';
  static const String artistRelatedArtistsEndpoint = '/artists/{id}/related-artists';

  // Playlists
  static const String playlistsEndpoint = '/playlists';
  static const String userPlaylistsEndpoint = '/me/playlists';
  static const String playlistEndpoint = '/playlists/{id}';
  static const String playlistTracksEndpoint = '/playlists/{id}/tracks';
  static const String featuredPlaylistsEndpoint = '/browse/featured-playlists';

  // User Profile
  static const String meEndpoint = '/me';
  static const String userEndpoint = '/users/{id}';

  // Player
  static const String playerEndpoint = '/me/player';
  static const String currentlyPlayingEndpoint = '/me/player/currently-playing';
  static const String recentlyPlayedEndpoint = '/me/player/recently-played';
  static const String playerDevicesEndpoint = '/me/player/devices';
  static const String playerPlayEndpoint = '/me/player/play';
  static const String playerPauseEndpoint = '/me/player/pause';
  static const String playerNextEndpoint = '/me/player/next';
  static const String playerPreviousEndpoint = '/me/player/previous';
  static const String playerSeekEndpoint = '/me/player/seek';
  static const String playerVolumeEndpoint = '/me/player/volume';
  static const String playerShuffleEndpoint = '/me/player/shuffle';
  static const String playerRepeatEndpoint = '/me/player/repeat';
  static const String playerQueueEndpoint = '/me/player/queue';

  // Recommendations
  static const String recommendationsEndpoint = '/recommendations';
  static const String availableGenresEndpoint = '/recommendations/available-genre-seeds';

  // Audio Features
  static const String audioFeaturesEndpoint = '/audio-features/{id}';
  static const String audioFeaturesMultipleEndpoint = '/audio-features';

  // Browse
  static const String newReleasesEndpoint = '/browse/new-releases';
  static const String categoriesEndpoint = '/browse/categories';
  static const String categoryEndpoint = '/browse/categories/{id}';
  static const String categoryPlaylistsEndpoint = '/browse/categories/{id}/playlists';

  // Follow
  static const String followingEndpoint = '/me/following';
  static const String followEndpoint = '/me/following/contains';

  // Top Items
  static const String topTracksEndpoint = '/me/top/tracks';
  static const String topArtistsEndpoint = '/me/top/artists';

  // -------------------- Query Limits -------------------- //

  /// Default limit for paginated requests
  static const int defaultLimit = 20;

  /// Maximum limit for paginated requests
  static const int maxLimit = 50;

  /// Minimum limit for paginated requests
  static const int minLimit = 1;

  // -------------------- Cache Keys -------------------- //

  /// Cache key prefix for tracks
  static const String cacheKeyTracks = 'spotify_tracks';

  /// Cache key prefix for albums
  static const String cacheKeyAlbums = 'spotify_albums';

  /// Cache key prefix for artists
  static const String cacheKeyArtists = 'spotify_artists';

  /// Cache key prefix for playlists
  static const String cacheKeyPlaylists = 'spotify_playlists';

  /// Cache key for search results
  static const String cacheKeySearch = 'spotify_search';

  /// Cache key for user library
  static const String cacheKeyLibrary = 'spotify_library';

  // -------------------- Error Messages -------------------- //

  static const String errorUnauthorized = 'Invalid Spotify API token. Please check your .env configuration.';
  static const String errorRateLimit = 'Rate limit exceeded. Please try again later.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorBadRequest = 'Invalid request. Please check your parameters.';
  static const String errorServerError = 'Server error. Please try again later.';
  static const String errorNoConnection = 'No internet connection.';
  static const String errorUnknown = 'An unknown error occurred.';

  // -------------------- Time Ranges -------------------- //

  /// Time range options for top items
  static const String timeRangeShort = 'short_term'; // ~4 weeks
  static const String timeRangeMedium = 'medium_term'; // ~6 months
  static const String timeRangeLong = 'long_term'; // several years

  // -------------------- Repeat Modes -------------------- //

  static const String repeatOff = 'off';
  static const String repeatTrack = 'track';
  static const String repeatContext = 'context';

  // -------------------- Search Types -------------------- //

  static const String searchTypeTrack = 'track';
  static const String searchTypeAlbum = 'album';
  static const String searchTypeArtist = 'artist';
  static const String searchTypePlaylist = 'playlist';
  static const String searchTypeAll = 'track,album,artist,playlist';

  // -------------------- Album Types -------------------- //

  static const String albumTypeAlbum = 'album';
  static const String albumTypeSingle = 'single';
  static const String albumTypeCompilation = 'compilation';

  // -------------------- Markets -------------------- //

  /// Market code for US
  static const String marketUS = 'US';

  /// Use user's market from their profile
  static const String marketFromToken = 'from_token';

  // -------------------- Helper Methods -------------------- //

  /// Build full URL for endpoint
  static String buildUrl(String endpoint) => '$baseUrl$endpoint';

  /// Replace ID placeholder in endpoint
  static String replaceId(String endpoint, String id) {
    return endpoint.replaceAll('{id}', id);
  }
}
