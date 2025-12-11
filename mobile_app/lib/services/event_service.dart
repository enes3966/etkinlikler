import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import 'auth_service.dart';

class EventService {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  final AuthService _authService = AuthService();

  Future<String?> _getAuthToken() async {
    return await _authService.getToken();
  }

  // Tüm etkinlikleri getir
  Future<List<EventModel>> getEvents() async {
    try {
      final url = Uri.parse('$baseUrl/events/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('Etkinlikler yüklenemedi');
      }
    } catch (e) {
      print('Etkinlik yükleme hatası: $e');
      return [];
    }
  }

  // Etkinlik detayını getir
  Future<EventModel?> getEventById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/events/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return EventModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Etkinlik detay hatası: $e');
      return null;
    }
  }

  // Yeni etkinlik oluştur
  Future<Map<String, dynamic>> createEvent(EventModel event) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {'success': false, 'message': 'Giriş yapmanız gerekiyor'};
      }

      final url = Uri.parse('$baseUrl/events/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(event.toCreateJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'event': EventModel.fromJson(data),
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Etkinlik oluşturulamadı',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }
}

