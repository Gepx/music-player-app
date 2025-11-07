# 🗄️ SQLite Cache Implementation

## ✅ Implementation Complete!

Sistem SQLite caching untuk Spotify API data telah berhasil diimplementasikan dengan lengkap.

---

## 📊 Database Schema

### Tables Created:
1. **cache_metadata** - Metadata untuk tracking cache (expiry, hit count)
2. **tracks** - Cache untuk track data
3. **albums** - Cache untuk album data
4. **artists** - Cache untuk artist data
5. **playlists** - Cache untuk playlist data
6. **playlist_tracks** - Junction table untuk many-to-many relationship
7. **search_history** - History pencarian user
8. **recently_played** - Track yang recently played
9. **user_favorites** - Item favorit user

### Indexes Created:
- Spotify ID indexes untuk fast lookups
- Artist/Album name indexes untuk search
- Cache key indexes untuk metadata
- Timestamp indexes untuk recently played

---

## 🔧 Services Implemented

### `SpotifySQLiteCacheService`

**Location:** `lib/data/services/database/spotify_sqlite_cache_service.dart`

#### Core Features:
- ✅ Track caching & retrieval
- ✅ Album caching & retrieval
- ✅ Artist caching & retrieval
- ✅ Playlist caching with tracks
- ✅ Search history management
- ✅ Recently played tracking
- ✅ Favorites management
- ✅ Cache expiry (24 hours)
- ✅ Auto cleanup expired cache
- ✅ Cache statistics

#### Key Methods:

**Track Operations:**
```dart
await cacheTrack(track);
await cacheTracks(tracks);
final track = await getCachedTrack(trackId);
final results = await searchCachedTracks(query);
final albumTracks = await getTracksByAlbum(albumId);
```

**Album Operations:**
```dart
await cacheAlbum(album);
await cacheAlbums(albums);
final album = await getCachedAlbum(albumId);
final results = await searchCachedAlbums(query);
```

**Artist Operations:**
```dart
await cacheArtist(artist);
final artist = await getCachedArtist(artistId);
final results = await searchCachedArtists(query);
```

**Playlist Operations:**
```dart
await cachePlaylist(playlist, tracks);
final playlist = await getCachedPlaylist(playlistId);
final tracks = await getPlaylistTracks(playlistId);
final playlists = await getAllCachedPlaylists();
```

**Search & History:**
```dart
await saveSearchHistory(query, type, resultsCount);
final history = await getSearchHistory(limit: 20);
await clearSearchHistory();
```

**Recently Played:**
```dart
await saveRecentlyPlayed(trackId, DateTime.now());
final recentTracks = await getRecentlyPlayed(limit: 50);
```

**Favorites:**
```dart
await addFavorite(itemId, itemType);
await removeFavorite(itemId, itemType);
final isFav = await isFavorite(itemId, itemType);
final favTracks = await getFavoriteTracks();
```

**Cache Management:**
```dart
await clearExpiredCache();
await clearAllCache();
final stats = await getCacheStats();
```

---

## 🎨 Model Updates

All models now support SQLite serialization:

### TrackModel
```dart
// Convert to SQLite
final map = track.toSQLite();

// Create from SQLite
final track = TrackModel.fromSQLite(map);
```

### AlbumModel
```dart
final map = album.toSQLite();
final album = AlbumModel.fromSQLite(map);
```

### ArtistModel
```dart
// Handles JSON encoding for genres list
final map = artist.toSQLite();
final artist = ArtistModel.fromSQLite(map);
```

### PlaylistModel
```dart
final map = playlist.toSQLite();
final playlist = PlaylistModel.fromSQLite(map);
```

---

## 🚀 Usage Example

### Initialize Service

```dart
// In main.dart or app initialization
await SpotifySQLiteCacheService.instance.initialize();
```

### Basic Caching Flow

```dart
final cacheService = SpotifySQLiteCacheService.instance;

// 1. Try to get from cache
var track = await cacheService.getCachedTrack(trackId);

// 2. If not in cache, fetch from API
if (track == null) {
  track = await spotifyApi.getTrack(trackId);
  
  // 3. Cache the result
  await cacheService.cacheTrack(track);
}

// 4. Use the track
playTrack(track);
```

### Complex Queries

```dart
// Search in cached data
final results = await cacheService.searchCachedTracks('love');

// Get tracks by album
final albumTracks = await cacheService.getTracksByAlbum(albumId);

// Get playlist with tracks
final playlist = await cacheService.getCachedPlaylist(playlistId);
final tracks = await cacheService.getPlaylistTracks(playlistId);

// Recently played
await cacheService.saveRecentlyPlayed(trackId, DateTime.now());
final recent = await cacheService.getRecentlyPlayed(limit: 20);
```

---

## 📈 Cache Statistics

```dart
final stats = await cacheService.getCacheStats();

print(stats);
// Output:
// {
//   'tracks': 150,
//   'albums': 45,
//   'artists': 30,
//   'playlists': 10,
//   'totalItems': 235,
//   'cacheExpiry': '24 hours'
// }
```

---

## 🔄 Migration

Database automatically migrates from version 1 to version 2:
- Version 1: Only user table
- Version 2: All Spotify cache tables added

Migration happens automatically on app launch.

---

## 🧹 Maintenance

### Auto Cleanup
```dart
// Runs on app startup
await cacheService.clearExpiredCache();
```

### Manual Cleanup
```dart
// Clear specific cache
await cacheService.invalidateCache('track_123');

// Clear all cache
await cacheService.clearAllCache();
```

---

## 🎯 Next Steps

### Recommended Enhancements:

1. **Implement Hybrid Caching Strategy**
   ```dart
   // Use Hive for fast simple lookups
   // Use SQLite for complex queries
   class MusicRepository {
     Future<TrackModel?> getTrack(String id) async {
       // Try Hive first
       var track = await hiveCache.get(id);
       if (track != null) return track;
       
       // Try SQLite
       track = await sqliteCache.getCachedTrack(id);
       if (track != null) {
         await hiveCache.put(id, track); // Sync to Hive
         return track;
       }
       
       // Fetch from API
       track = await api.getTrack(id);
       await Future.wait([
         hiveCache.put(id, track),
         sqliteCache.cacheTrack(track),
       ]);
       return track;
     }
   }
   ```

2. **Add Background Sync**
   ```dart
   Timer.periodic(Duration(hours: 6), (_) async {
     await cacheService.clearExpiredCache();
   });
   ```

3. **Cache Analytics**
   ```dart
   class CacheAnalytics {
     int hits = 0;
     int misses = 0;
     double get hitRate => hits / (hits + misses);
   }
   ```

4. **Offline Mode**
   ```dart
   Future<List<TrackModel>> getPopularTracks() async {
     if (await hasInternet()) {
       return await api.getPopularTracks();
     } else {
       // Fallback to cached data
       return await cacheService.getAllCachedTracks(limit: 50);
     }
   }
   ```

---

## 📝 Notes

- Cache expiry: **24 hours** (configurable)
- Max cache size: **Unlimited** (cleanup old entries manually if needed)
- Database version: **2**
- All queries are indexed for performance
- Supports complex relational queries (JOINs)
- Thread-safe (uses SQLite batch operations)

---

## 🎉 Success!

SQLite caching system is now fully implemented and ready to use!

**Total Implementation:**
- ✅ 9 Database tables
- ✅ 13+ Indexes
- ✅ 600+ lines of cache service code
- ✅ 4 Models with SQLite serialization
- ✅ Migration system
- ✅ Auto cleanup
- ✅ Statistics & monitoring

**Performance Benefits:**
- 🚀 Fast offline access
- 🔍 Complex search queries
- 💾 Reduced API calls
- 📊 Better analytics
- 🔗 Relational data support

Happy coding! 🎵

