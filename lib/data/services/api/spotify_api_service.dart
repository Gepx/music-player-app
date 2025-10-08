import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getAccessToken() async {
  final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
  final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];

  final credential = base64Encode(utf8.encode('$clientId:$clientSecret'));

  final response = await http.post(
    Uri.parse('https://accounts.spotify.com/api/token'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic $credential',
    },
    body: {'grant_type': 'client_credentials'},
  );
  final data = jsonDecode(response.body);
  return data['access_token'];
}
