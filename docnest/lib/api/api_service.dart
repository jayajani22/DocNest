import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A global singleton instance of the [ApiService] for easy access from the UI.
final ApiService apiService = ApiService._internal();

Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access');
}

/// A service class for handling all API requests to the Django backend.
class ApiService {
  // --- Base URL Configuration ---
  // Set this to `false` to use the LAN IP for testing on other devices.
  static const bool _useLocalhost = true;

  // The base URL for the API.
  // Using kIsWeb to check if the app is running on the web.
  final String baseUrl = _useLocalhost
      ? "http://127.0.0.1:8000/api/"
      : "http://192.168.129.188:8000/api/";

  String? _accessToken;
  String? _refreshToken;

  // Private constructor for the singleton pattern.
  ApiService._internal();

  /// Initializes the API service by loading tokens from shared preferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  /// Sets the authorization tokens for subsequent requests and stores them.
  Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', accessToken);
    prefs.setString('refresh_token', refreshToken);
  }

  /// Constructs the headers for API requests.
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  // Helper to send requests with token refresh logic
  Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestBuilder) async {
    try {
      return await requestBuilder();
    } catch (e) {
      // If the request fails due to a 401, try to refresh the token and retry
      if (e is http.ClientException && e.message.contains('401')) {
        if (await _refreshAccessToken()) {
          return await requestBuilder(); // Retry the request with the new token
        }
      }
      rethrow;
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    final url = Uri.parse('${baseUrl}token/refresh/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['access'];
      if (newAccessToken != null) {
        await setTokens(
            newAccessToken, _refreshToken!); // Update only access token
        return true;
      }
    }
    // If refresh fails, clear tokens and force re-login
    await logout();
    return false;
  }

  // --- 1. AUTHENTICATION ---

  Future<String> login(String username, String password) async {
    final url = Uri.parse('${baseUrl}token/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        print(
            'Login Success! Access token: $accessToken, Refresh token: $refreshToken');
        if (accessToken != null && refreshToken != null) {
          await setTokens(accessToken, refreshToken);
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('access', accessToken);
          return accessToken;
        } else {
          throw Exception('Login successful, but tokens were not received.');
        }
      } else {
        print('Login failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> signup(String username, String password) async {
    final url = Uri.parse('${baseUrl}signup/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 201) {
        return;
      } else {
        print('Signup failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('refresh_token');
    prefs.remove('access');
  }

  // --- 2. DOCUMENTS ---

  Future<List<dynamic>> fetchDocuments() async {
    final url = Uri.parse('${baseUrl}documents/');
    try {
      final res = await _sendRequest(() => http.get(url, headers: _headers));
      if (res.statusCode == 200) {
        if (res.body.isEmpty) return [];
        return jsonDecode(res.body);
      } else {
        print('Failed to load documents: ${res.statusCode}');
        print('Response body: ${res.body}');
        throw Exception('Server error: ${res.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> openDocument(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open document');
    }
  }

  Future<void> deleteDocument(int id) async {
    final url = Uri.parse('${baseUrl}documents/$id/');
    try {
      final res = await _sendRequest(() => http.delete(url, headers: _headers));
      if (res.statusCode == 200 || res.statusCode == 204) {
        return;
      } else {
        print('Failed to delete document: ${res.statusCode}');
        print('Response body: ${res.body}');
        throw Exception('Server error: ${res.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> uploadDocument(
      String name, String fileName, Uint8List fileBytes) async {
    final url = Uri.parse('${baseUrl}documents/');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $_accessToken';
      request.fields['name'] = name;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 201) {
        return;
      } else {
        final response = await http.Response.fromStream(streamedResponse);
        print('Failed to upload document: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- 3. NOTES ---

  Future<List<dynamic>> fetchNotes() async {
    final url = Uri.parse('${baseUrl}notes/');
    try {
      final res = await _sendRequest(() => http.get(url, headers: _headers));
      if (res.statusCode == 200) {
        if (res.body.isEmpty) return [];
        return jsonDecode(res.body);
      } else {
        print('Failed to load notes: ${res.statusCode}');
        print('Response body: ${res.body}');
        throw Exception('Server error: ${res.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> addNote(String title, String content) async {
    final url = Uri.parse('${baseUrl}notes/');
    try {
      final response = await _sendRequest(() => http.post(
        url,
        headers: _headers,
        body: jsonEncode({'title': title, 'content': content}),
      ));
      if (response.statusCode == 201) {
        return;
      } else {
        print('Failed to add note: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> updateNote(int id, String title, String content) async {
    final url = Uri.parse('${baseUrl}notes/$id/');
    try {
      final response = await _sendRequest(() => http.put(
            url,
            headers: _headers,
            body: jsonEncode({'title': title, 'content': content}),
          ));
      if (response.statusCode == 200) {
        return;
      } else {
        print('Failed to update note: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deleteNote(int id) async {
    final url = Uri.parse('${baseUrl}notes/$id/');
    try {
      final res = await _sendRequest(() => http.delete(url, headers: _headers));
      if (res.statusCode == 204) {
        return;
      } else {
        print('Failed to delete note: ${res.statusCode}');
        print('Response body: ${res.body}');
        throw Exception('Server error: ${res.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception('Failed to connect to the server. Please check your network connection and try again.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- 4. PASSWORD VAULT ---

  Future<Map<String, dynamic>> fetchUserSummary() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${baseUrl}summary/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch summary: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchPasswords() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${baseUrl}passwords/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('Error: ${response.body}');
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<void> addPassword(Map<String, dynamic> data) async {
    final token = await _getToken();
    await http.post(
      Uri.parse('${baseUrl}passwords/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
  }

  Future<void> updatePassword(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('${baseUrl}passwords/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update password: ${response.statusCode}');
    }
  }

  Future<void> deletePassword(int id) async {
    final token = await _getToken();
    await http.delete(
      Uri.parse('${baseUrl}passwords/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
