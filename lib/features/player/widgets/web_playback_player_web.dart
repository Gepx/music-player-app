import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/utils/constants/colors.dart';

/// Web-specific implementation of Spotify Web Playback SDK
/// Uses dart:html instead of InAppWebView
class WebPlaybackPlayerWeb extends StatefulWidget {
  final String trackUri;
  final VoidCallback? onReady;

  const WebPlaybackPlayerWeb({
    super.key,
    required this.trackUri,
    this.onReady,
    
  });

  @override
  State<WebPlaybackPlayerWeb> createState() => _WebPlaybackPlayerWebState();
}

class _WebPlaybackPlayerWebState extends State<WebPlaybackPlayerWeb> {
  final WebPlaybackSDKService _sdkService = WebPlaybackSDKService.instance;
  bool _isLoading = true;
  bool _sdkReady = false;
  dynamic _player; // Store reference to the Spotify player

  @override
  void initState() {
    super.initState();
    _initializeWebPlaybackSDK();
  }

  Future<void> _initializeWebPlaybackSDK() async {
    try {
      debugPrint('🎵 Initializing Web Playback SDK (Web Platform)...');
      
      // Load Spotify Web Playback SDK script
      if (!_isSpotifySDKLoaded()) {
        await _loadSpotifySDK();
      }

      // Wait for SDK to be ready
      _waitForSDKReady();
    } catch (e) {
      debugPrint('❌ Error initializing Web Playback SDK: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isSpotifySDKLoaded() {
    return html.document.querySelector('script[src="https://sdk.scdn.co/spotify-player.js"]') != null;
  }

  Future<void> _loadSpotifySDK() async {
    final script = html.ScriptElement()
      ..src = 'https://sdk.scdn.co/spotify-player.js'
      ..async = true;
    
    html.document.head?.append(script);
    
    // Wait for script to load
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _waitForSDKReady() {
    // Set up callback for when SDK is ready
    js.context['onSpotifyWebPlaybackSDKReady'] = js.allowInterop(() async {
      debugPrint('✅ Spotify SDK Ready (Web)');
      await _createPlayer();
    });

    // Check if SDK is already ready
    if (js.context.hasProperty('Spotify')) {
      _createPlayer();
    }
  }

  Future<void> _createPlayer() async {
    try {
      final token = await _sdkService.getAccessToken();
      if (token == null) {
        debugPrint('❌ No access token available');
        debugPrint('⚠️  Please complete Premium setup: dart tools/spotify_token_setup.dart');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _sdkReady = false;
          });
        }
        return;
      }

      // Create player using JavaScript
      final spotifyNamespace = js.context['Spotify'];
      final playerConstructor = spotifyNamespace['Player'];

      // Create player options
      final options = js.JsObject.jsify({
        'name': 'Flutter Music Player (Web)',
        'volume': 0.8,
      });

      // Set getOAuthToken - Create a raw JavaScript function that accepts variadic args
      // Spotify's SDK may pass multiple arguments, we only use the first (callback)
      options['getOAuthToken'] = js.JsFunction.withThis((self, [arg1, arg2]) {
        // arg1 is the callback function
        if (arg1 != null && arg1 is js.JsFunction) {
          arg1.apply([token]);
        }
      });

      // Create player
      _player = js.JsObject(playerConstructor as js.JsFunction, [options]);

      // Set up control callbacks for the service
      _sdkService.setPlayerControls(
        onTogglePlayPause: () {
          _player?.callMethod('togglePlay');
        },
        onPlayNext: () {
          _sdkService.playNext();
        },
        onPlayPrevious: () {
          _sdkService.playPrevious();
        },
        onPlayUri: (uri) async {
          final token = await _sdkService.getAccessToken();
          final deviceId = _sdkService.deviceId;
          if (token != null && deviceId != null) {
            await _transferPlayback(deviceId, token);
            await html.HttpRequest.request(
              'https://api.spotify.com/v1/me/player/play?device_id=$deviceId',
              method: 'PUT',
              requestHeaders: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              sendData: '{"uris": ["$uri"]}',
            );
          }
        },
      );

      // Add event listeners
      _player.callMethod('addListener', ['ready', js.allowInterop((data) {
        final deviceId = data['device_id'] as String;
        debugPrint('🎵 Player ready with device ID: $deviceId');
        _sdkService.setDeviceId(deviceId);
        
        if (mounted) {
          setState(() {
            _sdkReady = true;
            _isLoading = false;
          });
        }
        
        widget.onReady?.call();
        
        // Give the device a moment to register with Spotify, then play
        Future.delayed(const Duration(milliseconds: 750), () {
          _playTrack(deviceId, token);
        });
      })]);

      _player.callMethod('addListener', ['not_ready', js.allowInterop((data) {
        debugPrint('⚠️ Player not ready: ${data['device_id']}');
      })]);

      _player.callMethod('addListener', ['player_state_changed', js.allowInterop((state) {
        if (state == null) return;
        
        final position = state['position'] as int?;
        final paused = state['paused'] as bool?;
        
        if (position != null) {
          _sdkService.updatePosition(Duration(milliseconds: position));
        }
        if (paused != null) {
          _sdkService.updatePlayingState(!paused);
        }
      })]);

      _player.callMethod('addListener', ['initialization_error', js.allowInterop((error) {
        final message = error['message'] ?? 'Unknown error';
        debugPrint('❌ Initialization error: $message');
        try {
          final errorJson = js.context['JSON'].callMethod('stringify', [error]);
          debugPrint('Full error: $errorJson');
        } catch (e) {
          debugPrint('Could not stringify error: $e');
        }
      })]);

      _player.callMethod('addListener', ['authentication_error', js.allowInterop((error) {
        final message = error['message'] ?? 'Unknown error';
        debugPrint('❌ Authentication error: $message');
        try {
          final errorJson = js.context['JSON'].callMethod('stringify', [error]);
          debugPrint('Full error: $errorJson');
        } catch (e) {
          debugPrint('Could not stringify error: $e');
        }
        debugPrint('⚠️ Check if your access token is valid');
        debugPrint('⚠️ Try running: dart tools/spotify_token_setup.dart');
      })]);

      _player.callMethod('addListener', ['account_error', js.allowInterop((error) {
        final message = error['message'] ?? 'Unknown error';
        debugPrint('❌ Account error: $message');
        try {
          final errorJson = js.context['JSON'].callMethod('stringify', [error]);
          debugPrint('Full error: $errorJson');
        } catch (e) {
          debugPrint('Could not stringify error: $e');
        }
        debugPrint('⚠️ SPOTIFY PREMIUM IS REQUIRED');
        debugPrint('⚠️ Free accounts cannot use Web Playback SDK');
        debugPrint('⚠️ Check your account at: https://www.spotify.com/account/');
      })]);

      _player.callMethod('addListener', ['playback_error', js.allowInterop((error) {
        final message = error['message'] ?? 'Unknown playback error';
        debugPrint('❌ Playback error: $message');
        
        // Try to get full error details
        try {
          final errorJson = js.context['JSON'].callMethod('stringify', [error]);
          debugPrint('Full error JSON: $errorJson');
        } catch (e) {
          debugPrint('Could not stringify error, trying individual fields...');
          try {
            debugPrint('  - message: ${error['message']}');
            debugPrint('  - reason: ${error['reason']}');
            debugPrint('  - status: ${error['status']}');
            debugPrint('  - statusText: ${error['statusText']}');
          } catch (e2) {
            debugPrint('Could not extract error fields: $e2');
          }
        }
        
        // Attempt recovery: resume then retry play once after a short delay
        try {
          _player.callMethod('resume');
          final deviceId = _sdkService.deviceId;
          if (deviceId != null) {
            Future.delayed(const Duration(milliseconds: 800), () async {
              final token = await _sdkService.getAccessToken();
              if (token != null) {
                _playTrack(deviceId, token);
              }
            });
          }
        } catch (_) {}

        // Check if it's a Premium account issue
        if (message.toString().contains('Premium') || 
            message.toString().contains('premium')) {
          debugPrint('⚠️ This might be a Premium account issue');
          debugPrint('⚠️ Verify your account at: https://www.spotify.com/account/');
        }
      })]);

      // Connect the player
      _player.callMethod('connect');

      debugPrint('✅ Web Playback SDK player created');
    } catch (e) {
      debugPrint('❌ Error creating player: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playTrack(String deviceId, String token) async {
    try {
      debugPrint('🎵 Playing track: ${widget.trackUri}');

      // Ensure playback is transferred to this device
      await _transferPlayback(deviceId, token);

      final response = await html.HttpRequest.request(
        'https://api.spotify.com/v1/me/player/play?device_id=$deviceId',
        method: 'PUT',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        sendData: '{"uris": ["${widget.trackUri}"]}',
      );

      if (response.status == 204 || response.status == 200) {
        debugPrint('✅ Track started playing');
      } else {
        debugPrint('❌ Failed to play track: ${response.status}');
        debugPrint('Response: ${response.responseText}');
      }
    } catch (e) {
      debugPrint('❌ Error playing track: $e');
    }
  }

  Future<void> _transferPlayback(String deviceId, String token) async {
    try {
      final resp = await html.HttpRequest.request(
        'https://api.spotify.com/v1/me/player',
        method: 'PUT',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        sendData: '{"device_ids":["$deviceId"],"play":true}',
      );

      if (resp.status == 204) {
        debugPrint('✅ Playback transferred to device');
      } else {
        debugPrint('⚠️ Transfer playback returned ${resp.status}');
        debugPrint('Response: ${resp.responseText}');
      }
    } catch (e) {
      debugPrint('⚠️ Transfer playback failed: $e');
    }
  }

  @override
  void didUpdateWidget(WebPlaybackPlayerWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackUri != widget.trackUri && _sdkReady) {
      final deviceId = _sdkService.deviceId;
      if (deviceId != null) {
        _sdkService.getAccessToken().then((token) {
          if (token != null) {
            _playTrack(deviceId, token);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This host is meant to be invisible; SDK runs in background
    return const SizedBox.shrink();
  }
}

