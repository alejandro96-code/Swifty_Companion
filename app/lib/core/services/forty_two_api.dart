import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FortyTwoApiException implements Exception {
  const FortyTwoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

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
      return 'La solicitud tardo demasiado. Comprueba tu conexion e intentalo de nuevo.';
    }
    if (error is http.ClientException) {
      return 'No se pudo conectar con 42. Comprueba tu conexion a internet.';
    }
    return 'Ha ocurrido un error inesperado. Intentalo de nuevo.';
  }

  Future<Map<String, dynamic>> fetchUser(String login) async {
    final token = await _getAccessToken();
    final uri = Uri.parse('https://api.intra.42.fr/v2/users/$login');
    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 404) {
      throw const FortyTwoApiException('Login no encontrado.');
    }
    throw FortyTwoApiException(_messageForStatus(response.statusCode));
  }

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
          'La respuesta de proyectos no es valida.',
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

  Future<String> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null) {
      if (DateTime.now().toUtc().isBefore(_tokenExpiry!)) {
        return _accessToken!;
      }
    }

    final clientId = dotenv.env['CLIENT_ID'];
    final clientSecret = dotenv.env['CLIENT_SECRET'];
    if (clientId == null ||
        clientId.isEmpty ||
        clientSecret == null ||
        clientSecret.isEmpty) {
      throw const FortyTwoApiException(
        'Faltan las credenciales de 42. Revisa el archivo .env.',
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
        'No se pudo autenticar con 42 (${response.statusCode}).',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = json['access_token'] as String?;
    final expiresIn = json['expires_in'] as int?;
    if (accessToken == null || expiresIn == null) {
      throw const FortyTwoApiException(
        'La respuesta de autenticacion no es valida.',
      );
    }

    _accessToken = accessToken;
    _tokenExpiry = DateTime.now()
        .toUtc()
        .add(Duration(seconds: expiresIn > 30 ? expiresIn - 30 : expiresIn));
    return accessToken;
  }

  Map<String, String> _headers(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  String _messageForStatus(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return 'No tienes permiso para consultar los datos de 42.';
    }
    if (statusCode == 429) {
      return 'Demasiadas solicitudes. Espera un momento e intentalo de nuevo.';
    }
    if (statusCode >= 500) {
      return 'El servicio de 42 no esta disponible. Intentalo mas tarde.';
    }
    return 'El servicio de 42 devolvio un error ($statusCode).';
  }
}
