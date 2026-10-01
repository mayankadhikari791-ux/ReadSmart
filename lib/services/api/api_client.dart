import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../core/network/network_exceptions.dart';
import '../../core/network/resource.dart';

/// Robust HTTP API client with built-in timeout, status code mapping,
/// header injection, and network exception normalization.
class ApiClient {
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _timeout = timeout ?? AppConfig.requestTimeout;

  /// Default headers sent with requests.
  Map<String, String> _buildHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Api-Key': AppConfig.apiKey,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Performs a resilient GET request.
  Future<Resource<dynamic>> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    return _sendRequest(() {
      final uri = Uri.parse('$_baseUrl$endpoint')
          .replace(queryParameters: queryParameters);
      return _client.get(uri, headers: _buildHeaders(token: token));
    });
  }

  /// Performs a resilient POST request.
  Future<Resource<dynamic>> post(
    String endpoint, {
    dynamic body,
    String? token,
  }) async {
    return _sendRequest(() {
      final uri = Uri.parse('$_baseUrl$endpoint');
      return _client.post(
        uri,
        headers: _buildHeaders(token: token),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Performs a resilient PUT request.
  Future<Resource<dynamic>> put(
    String endpoint, {
    dynamic body,
    String? token,
  }) async {
    return _sendRequest(() {
      final uri = Uri.parse('$_baseUrl$endpoint');
      return _client.put(
        uri,
        headers: _buildHeaders(token: token),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Performs a resilient DELETE request.
  Future<Resource<dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    return _sendRequest(() {
      final uri = Uri.parse('$_baseUrl$endpoint');
      return _client.delete(uri, headers: _buildHeaders(token: token));
    });
  }

  /// Internal request execution wrapper with comprehensive exception mapping.
  Future<Resource<dynamic>> _sendRequest(
    Future<http.Response> Function() requestFn,
  ) async {
    try {
      final response = await requestFn().timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return Resource.error(const NoInternetFailure());
    } on TimeoutException {
      return Resource.error(const TimeoutFailure());
    } on FormatException {
      return Resource.error(const InvalidDataFailure());
    } catch (e) {
      return Resource.error(UnknownFailure(e.toString(), e));
    }
  }

  /// Maps HTTP response status codes to typed [Resource] responses.
  Resource<dynamic> _handleResponse(http.Response response) {
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) {
        return Resource.success(null);
      }
      try {
        final decoded = jsonDecode(response.body);
        return Resource.success(decoded);
      } catch (e) {
        return Resource.error(const InvalidDataFailure('Could not parse response JSON'));
      }
    }

    if (status == 401 || status == 403) {
      return Resource.error(const UnauthorizedFailure());
    }

    if (status == 408 || status == 504) {
      return Resource.error(const TimeoutFailure());
    }

    if (status >= 500) {
      return Resource.error(
        ServerFailure('Server responded with error code $status', statusCode: status),
      );
    }

    return Resource.error(
      ServerFailure('Request failed with status $status: ${response.body}',
          statusCode: status),
    );
  }

  void close() {
    _client.close();
  }
}

