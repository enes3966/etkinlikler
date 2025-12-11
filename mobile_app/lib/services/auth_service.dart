import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  // Giriş yapma
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'] as String;

        // Token'ı kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);

        // Kullanıcı bilgilerini al ve kaydet
        final user = await getCurrentUser(token);
        if (user != null) {
          await prefs.setString(userKey, json.encode(user.toJson()));
        }

        return {'success': true, 'token': token, 'user': user};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Giriş başarısız',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Kayıt olma
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/auth/signup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'is_active': true,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Kayıt başarılı'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Kayıt başarısız',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Mevcut kullanıcı bilgilerini alma
  Future<UserModel?> getCurrentUser(String? token) async {
    if (token == null) return null;

    try {
      final url = Uri.parse('$baseUrl/users/me');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return UserModel.fromJson(data);
      }
    } catch (e) {
      print('Kullanıcı bilgisi alınamadı: $e');
    }
    return null;
  }

  // Oturum kontrolü
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Kayıtlı kullanıcı bilgisini alma
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(userKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(json.decode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Token alma
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Çıkış yapma
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }
}

