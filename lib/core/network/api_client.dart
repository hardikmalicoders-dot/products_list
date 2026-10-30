import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  ///TODO: Implement this method to build headers for requests
  Map<String, String> _buildHeaders({String? token, Map<String, String>? customHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  ///TODO: Implement this method to handle POST requests
  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } on FormatException {
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  ///TODO: Implement this method to handle GET requests
  Future<dynamic> get(
    String url, {
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(token: token),
          )
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } on FormatException {
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic decodedBody;
    try {
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }
    } catch (_) {
      decodedBody = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    } else {
      String errorMessage = 'Server error occurred (${response.statusCode})';
      if (decodedBody is Map && decodedBody.containsKey('message')) {
        errorMessage = decodedBody['message'].toString();
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}
