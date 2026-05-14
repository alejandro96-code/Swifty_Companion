import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FortyTwoApi {
  FortyTwoApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _accessToken;
  DateTime? _tokenExpiry;

  Future<Map<String, dynamic>> fetchUser(String login) async {
    final token = await _getAccessToken();
    final uri = Uri.parse('https://api.intra.42.fr/v2/users/$login');
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 404) {
      throw Exception('Login no encontrado');
    }

    throw Exception('Error de API: ${response.statusCode}');
  }

  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int limit = 10,
  }) async {
    final token = await _getAccessToken();
    final rangeEnd = '${query}zzzz';
    final params = <String, String>{
      'range[login]': '$query,$rangeEnd',
      'page[size]': '$limit',
    };
    final uri = Uri.https('api.intra.42.fr', '/v2/users', params);
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error de API: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<String> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null) {
      final now = DateTime.now().toUtc();
      if (now.isBefore(_tokenExpiry!)) {
        return _accessToken!;
      }
    }

    final clientId = dotenv.env['CLIENT_ID'];
    final clientSecret = dotenv.env['CLIENT_SECRET'];

    if (clientId == null || clientSecret == null) {
      throw Exception('Faltan CLIENT_ID o CLIENT_SECRET en .env');
    }

    final uri = Uri.parse('https://api.intra.42.fr/oauth/token');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener token: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = json['access_token'] as String?;
    final expiresIn = json['expires_in'] as int?;

    if (accessToken == null || expiresIn == null) {
      throw Exception('Respuesta de token invalida');
    }

    _accessToken = accessToken;
    _tokenExpiry = DateTime.now().toUtc().add(Duration(seconds: expiresIn - 30));

    return accessToken;
  }
}
