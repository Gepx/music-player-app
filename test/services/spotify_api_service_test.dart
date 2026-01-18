import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:music_player/data/services/spotify/spotify_api_service.dart';

void main() {
  test('SpotifyApiService handleResponseForTest returns parsed data on success', () {
    final response = http.Response('{"foo":"bar"}', 200);

    final value = SpotifyApiService.instance.handleResponseForTest<String>(
      response,
      (json) => json['foo'] as String,
    );

    expect(value, 'bar');
  });

  test('SpotifyApiService handleResponseForTest throws SpotifyApiException on error', () {
    final response = http.Response(
      '{"error":{"status":401,"message":"Unauthorized"}}',
      401,
    );

    expect(
      () => SpotifyApiService.instance.handleResponseForTest<String>(
        response,
        (json) => json['foo'] as String,
      ),
      throwsA(isA<SpotifyApiException>()),
    );
  });
}

