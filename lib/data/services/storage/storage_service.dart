import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Firebase Storage Service
/// Handles file uploads and downloads (profile pictures, album art, audio files)
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // -------------------- Storage Paths -------------------- //

  static const String _profilePicturesPath = 'profile_pictures';
  static const String _albumArtPath = 'album_art';
  static const String _songsPath = 'songs';
  static const String _playlistCoversPath = 'playlist_covers';

  // -------------------- Upload Operations -------------------- //

  /// Upload profile picture
  Future<String?> uploadProfilePicture({
    required String userId,
    required File file,
    Function(double)? onProgress,
  }) async {
    return await _uploadFile(
      file: file,
      path: '$_profilePicturesPath/$userId',
      onProgress: onProgress,
    );
  }

  /// Upload album art
  Future<String?> uploadAlbumArt({
    required String albumId,
    required File file,
    Function(double)? onProgress,
  }) async {
    return await _uploadFile(
      file: file,
      path: '$_albumArtPath/$albumId',
      onProgress: onProgress,
    );
  }

  /// Upload song file
  Future<String?> uploadSong({
    required String songId,
    required File file,
    Function(double)? onProgress,
  }) async {
    return await _uploadFile(
      file: file,
      path: '$_songsPath/$songId',
      onProgress: onProgress,
    );
  }

  /// Upload playlist cover
  Future<String?> uploadPlaylistCover({
    required String playlistId,
    required File file,
    Function(double)? onProgress,
  }) async {
    return await _uploadFile(
      file: file,
      path: '$_playlistCoversPath/$playlistId',
      onProgress: onProgress,
    );
  }

  // -------------------- Generic Upload -------------------- //

  /// Generic file upload with progress tracking
  Future<String?> _uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('📤 Uploading file to: $path');
      
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Track upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase upload error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }

  // -------------------- Download Operations -------------------- //

  /// Get download URL for a file
  Future<String?> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('❌ Error getting download URL: $e');
      return null;
    }
  }

  /// Download file to local device
  Future<File?> downloadFile({
    required String storagePath,
    required String localPath,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('📥 Downloading file from: $storagePath');
      
      final ref = _storage.ref().child(storagePath);
      final file = File(localPath);
      final downloadTask = ref.writeToFile(file);

      // Track download progress
      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;
      debugPrint('✅ File downloaded successfully to: $localPath');
      return file;
    } catch (e) {
      debugPrint('❌ Download error: $e');
      return null;
    }
  }

  // -------------------- Delete Operations -------------------- //

  /// Delete file from storage
  Future<bool> deleteFile(String path) async {
    try {
      debugPrint('🗑️ Deleting file: $path');
      final ref = _storage.ref().child(path);
      await ref.delete();
      debugPrint('✅ File deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return false;
    }
  }

  /// Delete profile picture
  Future<bool> deleteProfilePicture(String userId) async {
    return await deleteFile('$_profilePicturesPath/$userId');
  }

  /// Delete album art
  Future<bool> deleteAlbumArt(String albumId) async {
    return await deleteFile('$_albumArtPath/$albumId');
  }

  // -------------------- Metadata Operations -------------------- //

  /// Get file metadata
  Future<FullMetadata?> getMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } catch (e) {
      debugPrint('❌ Error getting metadata: $e');
      return null;
    }
  }

  /// Update file metadata
  Future<bool> updateMetadata(String path, SettableMetadata metadata) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.updateMetadata(metadata);
      debugPrint('✅ Metadata updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating metadata: $e');
      return false;
    }
  }
}

