import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:music_player/data/services/playback/spotify_embed_service.dart';
import 'package:music_player/utils/constants/colors.dart';

class SpotifyEmbedPlayer extends StatefulWidget {
  final String trackId;
  final VoidCallback? onReady;

  const SpotifyEmbedPlayer({
    super.key,
    required this.trackId,
    this.onReady,
  });

  @override
  State<SpotifyEmbedPlayer> createState() => _SpotifyEmbedPlayerState();
}

class _SpotifyEmbedPlayerState extends State<SpotifyEmbedPlayer> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  String _currentTrackId = '';

  @override
  void initState() {
    super.initState();
    _currentTrackId = widget.trackId;
  }

  @override
  void didUpdateWidget(SpotifyEmbedPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId && _controller != null) {
      // Reload with new track
      _currentTrackId = widget.trackId;
      final embedUrl = SpotifyEmbedService.instance.getEmbedUrl(widget.trackId);
      _controller!.loadUrl(urlRequest: URLRequest(url: WebUri(embedUrl)));
      
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = SpotifyEmbedService.instance.getEmbedUrl(_currentTrackId);

    return Container(
      height: 152, // Standard Spotify embed height (compact player)
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
              key: ValueKey(_currentTrackId),
              initialUrlRequest: URLRequest(
                url: WebUri(embedUrl),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                transparentBackground: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                useShouldOverrideUrlLoading: true,
                useHybridComposition: true,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                debugPrint('🎵 WebView created for track: $_currentTrackId');
              },
              onLoadStart: (controller, url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
                debugPrint('🔄 Loading Spotify embed: $url');
              },
              onLoadStop: (controller, url) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
                SpotifyEmbedService.instance.setEmbedReady(true);
                widget.onReady?.call();
                debugPrint('✅ Spotify embed loaded: $url');
              },
              onLoadError: (controller, url, code, message) {
                debugPrint('❌ Embed player error: $message');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
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
                        'Loading Spotify Player...',
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

