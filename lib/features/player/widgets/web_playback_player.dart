import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/utils/constants/colors.dart';

class WebPlaybackPlayer extends StatefulWidget {
  final String trackUri;
  final VoidCallback? onReady;

  const WebPlaybackPlayer({
    super.key,
    required this.trackUri,
    this.onReady,
  });

  @override
  State<WebPlaybackPlayer> createState() => _WebPlaybackPlayerState();
}

class _WebPlaybackPlayerState extends State<WebPlaybackPlayer> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  final WebPlaybackSDKService _sdkService = WebPlaybackSDKService.instance;

  // #region agent log
  void _debugLog(String loc, String msg, Map<String, dynamic> data, String hypId) {
    final payload = {'location': loc, 'message': msg, 'data': data, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'sessionId': 'debug-session', 'hypothesisId': hypId};
    try { File('/Users/vin/Code/music-player-app/.cursor/debug.log').writeAsStringSync('${payload.toString().replaceAll("'", '"')}\n', mode: FileMode.append); } catch (_) {}
  }
  // #endregion

  @override
  void initState() {
    super.initState();
    // #region agent log
    _debugLog('web_playback_player.dart:initState', 'WebPlaybackPlayer initState', {'trackUri': widget.trackUri}, 'B');
    // #endregion
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    // #region agent log
    _debugLog('web_playback_player.dart:_initializeSDK', 'SDK initialize starting', {}, 'B');
    // #endregion
    await _sdkService.initialize();
    // #region agent log
    _debugLog('web_playback_player.dart:_initializeSDK', 'SDK initialize complete', {}, 'B');
    // #endregion
  }

  Future<void> _playTrack(String trackUri) async {
    final token = await _sdkService.getAccessToken();
    if (token != null && _controller != null) {
      await _controller!.evaluateJavascript(source: '''
        playTrack('$trackUri', '$token');
      ''');
    }
  }

  Future<void> _runJs(String source) async {
    if (_controller == null) return;
    try {
      await _controller!.evaluateJavascript(source: source);
    } catch (e) {
      debugPrint('❌ Web Playback JS error: $e');
    }
  }

  String _getWebPlaybackHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Spotify Web Playback</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #121212;
            color: #fff;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            overflow: hidden;
        }
        .player-container {
            width: 100%;
            max-width: 600px;
            padding: 20px;
        }
        .player-info {
            text-align: center;
            margin-bottom: 20px;
        }
        .track-name {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 8px;
        }
        .artist-name {
            font-size: 14px;
            color: #b3b3b3;
        }
        .controls {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
            margin: 20px 0;
        }
        button {
            background: #1db954;
            border: none;
            border-radius: 50%;
            width: 48px;
            height: 48px;
            cursor: pointer;
            color: white;
            font-size: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.1s, background 0.2s;
        }
        button:hover {
            background: #1ed760;
            transform: scale(1.06);
        }
        button:active {
            transform: scale(0.96);
        }
        .progress-bar {
            width: 100%;
            height: 4px;
            background: #4d4d4d;
            border-radius: 2px;
            margin: 20px 0;
            cursor: pointer;
            position: relative;
        }
        .progress-fill {
            height: 100%;
            background: #1db954;
            border-radius: 2px;
            width: 0%;
            transition: width 0.1s linear;
        }
        .time-info {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #b3b3b3;
        }
        .status {
            text-align: center;
            padding: 20px;
            color: #b3b3b3;
            font-size: 14px;
        }
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: #1db954;
            animation: spin 1s ease-in-out infinite;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="player-container">
        <div class="status" id="status">
            <div class="loading"></div>
            <p>Connecting to Spotify...</p>
        </div>
        <div id="player" style="display: none;">
            <div class="player-info">
                <div class="track-name" id="trackName">No track playing</div>
                <div class="artist-name" id="artistName">-</div>
            </div>
            <div class="progress-bar" id="progressBar">
                <div class="progress-fill" id="progressFill"></div>
            </div>
            <div class="time-info">
                <span id="currentTime">0:00</span>
                <span id="duration">0:00</span>
            </div>
            <div class="controls">
                <button onclick="previousTrack()">⏮</button>
                <button id="playPauseBtn" onclick="togglePlayPause()">▶</button>
                <button onclick="nextTrack()">⏭</button>
            </div>
        </div>
    </div>

    <script src="https://sdk.scdn.co/spotify-player.js"></script>
    <script>
        let player;
        let deviceId;
        let currentTrackUri;
        let accessToken;

        window.onSpotifyWebPlaybackSDKReady = () => {
            console.log('[HYP-C] Spotify SDK Ready callback fired');
            initializePlayer();
        };

        async function initializePlayer() {
            console.log('[HYP-D] initializePlayer() starting');
            // Get token from Flutter
            try {
                const token = await getAccessToken();
                console.log('[HYP-D] Token received: ' + (token ? 'yes' : 'no'));
                if (!token) {
                    console.error('[HYP-D] No access token available');
                    updateStatus('Failed to get access token. Please ensure you are logged in.');
                    return;
                }
                accessToken = token;

                console.log('[HYP-E] Creating Spotify.Player instance');
                player = new Spotify.Player({
                    name: 'Flutter Music Player',
                    getOAuthToken: cb => { cb(accessToken); },
                    volume: 0.8
                });
                console.log('[HYP-E] Spotify.Player created, adding listeners');

                // Error handling
                player.addListener('initialization_error', ({ message }) => {
                    console.error('[HYP-E] Initialization Error: ' + message);
                    updateStatus('Initialization error: ' + message);
                });

                player.addListener('authentication_error', ({ message }) => {
                    console.error('[HYP-E] Authentication Error: ' + message);
                    updateStatus('Authentication error. Please ensure you have Spotify Premium.');
                });

                player.addListener('account_error', ({ message }) => {
                    console.error('[HYP-E] Account Error: ' + message);
                    updateStatus('Account error: Spotify Premium required');
                });

                player.addListener('playback_error', ({ message }) => {
                    console.error('[HYP-E] Playback Error: ' + message);
                });

                // Playback status updates
                player.addListener('player_state_changed', state => {
                    if (!state) return;
                    
                    updatePlayerUI(state);
                    
                    // Notify Flutter
                    if (window.flutter_inappwebview) {
                        window.flutter_inappwebview.callHandler('onStateChange', {
                            position: state.position,
                            duration: state.duration,
                            paused: state.paused
                        });
                    }
                });

                // Ready
                player.addListener('ready', ({ device_id }) => {
                    console.log('[HYP-E] Player READY with Device ID: ' + device_id);
                    deviceId = device_id;
                    document.getElementById('status').style.display = 'none';
                    document.getElementById('player').style.display = 'block';
                    
                    // Notify Flutter
                    if (window.flutter_inappwebview) {
                        window.flutter_inappwebview.callHandler('onReady', { deviceId: device_id });
                    }
                });

                player.addListener('not_ready', ({ device_id }) => {
                    console.log('[HYP-E] Player NOT READY, device offline: ' + device_id);
                });

                // Connect
                console.log('[HYP-E] Calling player.connect()');
                player.connect().then(success => {
                    console.log('[HYP-E] player.connect() resolved: ' + success);
                }).catch(err => {
                    console.error('[HYP-E] player.connect() rejected: ' + err);
                });

            } catch (error) {
                console.error('[HYP-E] initializePlayer catch block: ' + error.message);
                updateStatus('Failed to initialize player: ' + error.message);
            }
        }

        async function getAccessToken() {
            // This will be injected by Flutter
            if (window.flutter_inappwebview) {
                try {
                    const result = await window.flutter_inappwebview.callHandler('getAccessToken');
                    return result;
                } catch (e) {
                    console.error('Failed to get token:', e);
                }
            }
            return null;
        }

        async function playTrack(trackUri, token) {
            if (token) accessToken = token;
            if (!deviceId || !accessToken) return;

            currentTrackUri = trackUri;

            try {
                const response = await fetch(\`https://api.spotify.com/v1/me/player/play?device_id=\${deviceId}\`, {
                    method: 'PUT',
                    body: JSON.stringify({ uris: [trackUri] }),
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': \`Bearer \${accessToken}\`
                    },
                });

                if (!response.ok) {
                    console.error('Failed to play track:', response.status);
                }
            } catch (error) {
                console.error('Error playing track:', error);
            }
        }

        function togglePlayPause() {
            if (!player) return;
            player.togglePlay();
        }

        function pausePlayback() {
            if (!player) return;
            player.pause();
        }

        function resumePlayback() {
            if (!player) return;
            player.resume();
        }

        function nextTrack() {
            if (!player) return;
            player.nextTrack();
        }

        function previousTrack() {
            if (!player) return;
            player.previousTrack();
        }

        function seekTo(ms) {
            if (!player) return;
            player.seek(ms);
        }

        function updatePlayerUI(state) {
            const track = state.track_window.current_track;
            document.getElementById('trackName').textContent = track.name;
            document.getElementById('artistName').textContent = track.artists.map(a => a.name).join(', ');
            
            const progress = (state.position / state.duration) * 100;
            document.getElementById('progressFill').style.width = progress + '%';
            
            document.getElementById('currentTime').textContent = formatTime(state.position);
            document.getElementById('duration').textContent = formatTime(state.duration);
            
            document.getElementById('playPauseBtn').textContent = state.paused ? '▶' : '⏸';
        }

        function formatTime(ms) {
            const seconds = Math.floor(ms / 1000);
            const mins = Math.floor(seconds / 60);
            const secs = seconds % 60;
            return mins + ':' + (secs < 10 ? '0' : '') + secs;
        }

        function updateStatus(message) {
            document.getElementById('status').innerHTML = '<p>' + message + '</p>';
        }

        // Progress bar click
        document.addEventListener('DOMContentLoaded', () => {
            document.getElementById('progressBar').addEventListener('click', (e) => {
                const bar = e.currentTarget;
                const clickX = e.offsetX;
                const width = bar.offsetWidth;
                const percentage = clickX / width;
                
                player.getCurrentState().then(state => {
                    if (state) {
                        const seekTo = Math.floor(state.duration * percentage);
                        player.seek(seekTo);
                    }
                });
            });
        });
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: FColors.darkContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: FColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            InAppWebView(
              key: ValueKey(widget.trackUri),
              initialData: InAppWebViewInitialData(
                data: _getWebPlaybackHTML(),
                mimeType: 'text/html',
                encoding: 'utf-8',
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                transparentBackground: true,
                useHybridComposition: true,
              ),
              onWebViewCreated: (controller) {
                // #region agent log
                _debugLog('web_playback_player.dart:onWebViewCreated', 'WebView created', {}, 'B');
                // #endregion
                _controller = controller;

                // Add JavaScript handler for getting access token
                controller.addJavaScriptHandler(
                  handlerName: 'getAccessToken',
                  callback: (args) async {
                    final token = await _sdkService.getAccessToken();
                    // #region agent log
                    _debugLog('web_playback_player.dart:getAccessToken', 'Token requested from JS', {'hasToken': token != null}, 'D');
                    // #endregion
                    return token;
                  },
                );

                // Add JavaScript handler for ready callback
                controller.addJavaScriptHandler(
                  handlerName: 'onReady',
                  callback: (args) {
                    // #region agent log
                    _debugLog('web_playback_player.dart:onReady', 'Spotify SDK ready callback', {'args': args.toString()}, 'E');
                    // #endregion
                    if (args.isNotEmpty && args[0] is Map) {
                      final data = args[0] as Map;
                      final deviceId = data['deviceId'] as String?;
                      if (deviceId != null) {
                        _sdkService.setDeviceId(deviceId);
                        widget.onReady?.call();
                      }
                    }
                    return null;
                  },
                );

                // Add JavaScript handler for state changes
                controller.addJavaScriptHandler(
                  handlerName: 'onStateChange',
                  callback: (args) {
                    if (args.isNotEmpty && args[0] is Map) {
                      final data = args[0] as Map;
                      final position = data['position'] as int?;
                      final duration = data['duration'] as int?;
                      final paused = data['paused'] as bool?;
                      
                      if (position != null) {
                        _sdkService.updatePosition(Duration(milliseconds: position));
                      }
                      if (duration != null && duration > 0) {
                        _sdkService.updateTotalDuration(Duration(milliseconds: duration));
                      }
                      if (paused != null) {
                        _sdkService.updatePlayingState(!paused);
                      }
                    }
                    return null;
                  },
                );

                _sdkService.setPlayerControls(
                  onTogglePlayPause: () => _runJs('togglePlayPause();'),
                  onPause: () => _runJs('pausePlayback();'),
                  onResume: () => _runJs('resumePlayback();'),
                  onPlayNext: () => _runJs('nextTrack();'),
                  onPlayPrevious: () => _runJs('previousTrack();'),
                  onPlayUri: (uri) => _playTrack(uri),
                  onSeek: (positionMs) => _runJs('seekTo($positionMs);'),
                );

                debugPrint('🎵 WebView created for Web Playback SDK');
              },
              onLoadStart: (controller, url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              onLoadStop: (controller, url) async {
                // #region agent log
                _debugLog('web_playback_player.dart:onLoadStop', 'WebView load complete', {'url': url?.toString()}, 'C');
                // #endregion
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }

                debugPrint('✅ Web Playback SDK loaded');
              },
              onLoadError: (controller, url, code, message) {
                // #region agent log
                _debugLog('web_playback_player.dart:onLoadError', 'WebView load error', {'code': code, 'message': message}, 'C');
                // #endregion
                debugPrint('❌ Web Playback SDK error: $message');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onConsoleMessage: (controller, consoleMessage) {
                // #region agent log
                _debugLog('web_playback_player.dart:console', 'JS Console', {'level': consoleMessage.messageLevel.toString(), 'msg': consoleMessage.message}, 'C_E');
                // #endregion
                debugPrint('🌐 Console: ${consoleMessage.message}');
              },
            ),
            
            // Loading indicator
            if (_isLoading)
              Container(
                color: FColors.darkContainer,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: FColors.primary,
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Loading Spotify Web Player...',
                        style: TextStyle(
                          color: FColors.textWhite,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

