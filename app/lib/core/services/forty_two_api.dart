import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Create API Exception with message and return this.
class FortyTwoApiException implements Exception {

  const FortyTwoApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

//create the Api client format and process the custom errors 
class FortyTwoApi {

  FortyTwoApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _accessToken;
  DateTime? _tokenExpiry;

  String errorMessage(Object error) {
    if (error is FortyTwoApiException) {
      return error.message;
    }
    if (error is TimeoutException) {
      return 'The request took too long. Check your connection and try again.';
    }
    if (error is http.ClientException) {
      return 'Could not connect to 42. Check your internet connection.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // Get the profile of user_login
  Future<Map<String, dynamic>> fetchUser(String login) async {
    final token = await _getAccessToken();
    final uri = Uri.parse('https://api.intra.42.fr/v2/users/$login');
    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 404) {
      throw const FortyTwoApiException('Login not found.');
    }
    throw FortyTwoApiException(_messageForStatus(response.statusCode));
  }

  // Get proyectos of userId
  Future<List<Map<String, dynamic>>> fetchUserProjects(int userId) async {
    final token = await _getAccessToken();
    const pageSize = 100;
    final projects = <Map<String, dynamic>>[];
    var page = 1;

    while (true) {
      final uri = Uri.https('api.intra.42.fr', '/v2/projects_users', {
        'filter[user_id]': userId.toString(),
        'page[number]': page.toString(),
        'page[size]': pageSize.toString(),
      });
      final response = await _client.get(uri, headers: _headers(token));

      if (response.statusCode != 200) {
        throw FortyTwoApiException(_messageForStatus(response.statusCode));
      }

      final data = jsonDecode(response.body);
      if (data is! List) {
        throw const FortyTwoApiException(
          'The projects response is invalid.',
        );
      }

      final pageProjects = data.whereType<Map<String, dynamic>>().map((projectUser) {
        return {
          ...projectUser,
          'validated': projectUser['validated?'] == true,
        };
      }).toList();
      projects.addAll(pageProjects);

      if (pageProjects.length < pageSize) {
        return projects;
      }
      page++;
    }
  }

  // Search users using prefix in the sesion init
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int limit = 10,
  }) async {
    final token = await _getAccessToken();
    final uri = Uri.https('api.intra.42.fr', '/v2/users', {
      'range[login]': '$query,${query}zzzz',
      'page[size]': limit.toString(),
    });
    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode != 200) {
      throw FortyTwoApiException(_messageForStatus(response.statusCode));
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }

/*
  Recreate Access token, if accessToken exist and tokenExpiry not caducated reused
  if not update token with POST /oauth/token and save accessToken and tokenExpiry
*/
  Future<String> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null) {
      if (DateTime.now().toUtc().isBefore(_tokenExpiry!)) {
        return _accessToken!;
      }
    }

    final clientId = dotenv.env['CLIENT_ID'];
    final clientSecret = dotenv.env['CLIENT_SECRET'];
    if (clientId == null || clientId.isEmpty || clientSecret == null || clientSecret.isEmpty) {
      throw const FortyTwoApiException(
        'Missing 42 credentials. Check the .env file.',
      );
    }

    final response = await _client.post(
      Uri.parse('https://api.intra.42.fr/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode != 200) {
      throw FortyTwoApiException(
        'Could not authenticate with 42 (${response.statusCode}).',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = json['access_token'] as String?;
    final expiresIn = json['expires_in'] as int?;
    if (accessToken == null || expiresIn == null) {
      throw const FortyTwoApiException(
        'The authentication response is invalid.',
      );
    }
    _accessToken = accessToken;
    _tokenExpiry = DateTime.now()
        .toUtc()
        .add(Duration(seconds: expiresIn > 30 ? expiresIn - 30 : expiresIn));
    return accessToken;
  }

  // Builds the headers for requests.
  Map<String, String> _headers(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  // Maps HTTP status codes with custom menssages
  String _messageForStatus(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return 'You do not have permission to access 42 data.';
    }
    if (statusCode == 429) {
      return 'Too many requests. Wait a moment and try again.';
    }
    if (statusCode >= 500) {
      return 'The 42 service is unavailable. Try again later.';
    }
    return 'The 42 service returned an error ($statusCode).';
  }
}
