#!/usr/bin/env dart
// Spotify Premium Token Setup Script
// Run this ONCE to get your refresh token for the .env file

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🎵 Spotify Premium Token Setup\n');
  print('This script will help you get a refresh token for your Premium account.');
  print('You\'ll need to log in to Spotify ONCE, then the token will auto-refresh.\n');

  // Step 1: Get credentials from .env or user input
  print('Step 1: Enter your Spotify App credentials');
  print('(Get these from: https://developer.spotify.com/dashboard)\n');

  stdout.write('Client ID: ');
  final clientId = stdin.readLineSync() ?? '';

  stdout.write('Client Secret: ');
  final clientSecret = stdin.readLineSync() ?? '';

  if (clientId.isEmpty || clientSecret.isEmpty) {
    print('❌ Client ID and Secret are required!');
    exit(1);
  }

  // Step 2: Generate auth URL
  final redirectUri = 'http://127.0.0.1:8888/callback';
  final scopes = [
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-currently-playing',
    'streaming',
    'user-read-email',
    'user-read-private',
  ].join('%20');

  final authUrl = 'https://accounts.spotify.com/authorize?'
      'client_id=$clientId'
      '&response_type=code'
      '&redirect_uri=$redirectUri'
      '&scope=$scopes';

  print('\n✅ Credentials saved!\n');
  print('Step 2: Authorization');
  print('─' * 60);
  print('Open this URL in your browser and log in with your PREMIUM account:\n');
  print(authUrl);
  print('\n─' * 60);
  print('\nAfter logging in, you\'ll be redirected to 127.0.0.1:8888.');
  print('Copy the ENTIRE URL from your browser address bar and paste it here:\n');

  stdout.write('Redirected URL: ');
  final redirectedUrl = stdin.readLineSync() ?? '';

  // Extract authorization code
  final codeMatch = RegExp(r'code=([^&]+)').firstMatch(redirectedUrl);
  if (codeMatch == null) {
    print('❌ Could not find authorization code in URL');
    exit(1);
  }

  final authCode = codeMatch.group(1)!;
  print('\n✅ Authorization code received!\n');

  // Step 3: Exchange code for tokens
  print('Step 3: Getting tokens...');

  final tokenUrl = 'https://accounts.spotify.com/api/token';
  final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

  try {
    final response = await HttpClient()
        .postUrl(Uri.parse(tokenUrl))
        .then((request) {
      request.headers.set('Authorization', 'Basic $credentials');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.write(
          'grant_type=authorization_code'
          '&code=$authCode'
          '&redirect_uri=$redirectUri');
      return request.close();
    });

    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody);

    if (data['refresh_token'] != null) {
      final refreshToken = data['refresh_token'];
      final accessToken = data['access_token'];

      print('✅ Tokens received!\n');
      print('═' * 60);
      print('🎉 SUCCESS! Add these to your .env file:');
      print('═' * 60);
      print('');
      print('SPOTIFY_PREMIUM_CLIENT_ID=$clientId');
      print('SPOTIFY_PREMIUM_CLIENT_SECRET=$clientSecret');
      print('SPOTIFY_PREMIUM_REFRESH_TOKEN=$refreshToken');
      print('');
      print('═' * 60);
      print('');
      print('⚠️  KEEP THESE SECRET! Never commit .env to git.');
      print('✅ Your app will now auto-authenticate with your Premium account.');
      print('');
      print('Access Token (expires in 1 hour): $accessToken');
      print('');
    } else {
      print('❌ Error: ${data['error_description'] ?? 'Unknown error'}');
      exit(1);
    }
  } catch (e) {
    print('❌ Error getting tokens: $e');
    exit(1);
  }
}

