import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import 'auth_service.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  final AuthService _authService = AuthService();
  Timer? _pollTimer;
  final List<MessageModel> _messages = [];
  final StreamController<List<MessageModel>> _messagesController =
      StreamController<List<MessageModel>>.broadcast();

  Stream<List<MessageModel>> get messagesStream => _messagesController.stream;

  Future<String?> _getAuthToken() async {
    return await _authService.getToken();
  }

  Future<int?> _getCurrentUserId() async {
    final user = await _authService.getSavedUser();
    return user?.id;
  }

  // Mesajları getir (genel grup mesajları için receiver_id = 0 kullanabiliriz)
  Future<List<MessageModel>> getMessages({int? receiverId}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return [];

      final receiver = receiverId ?? 0;
      final url = Uri.parse('$baseUrl/chat/messages?receiver_id=$receiver');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final messages = data.map((json) => MessageModel.fromJson(json)).toList();
        // In-memory listeyi güncelle
        _messages.clear();
        _messages.addAll(messages);
        return messages;
      }
      
      // Hata durumunda in-memory mesajları döndür
      return List.from(_messages);
    } catch (e) {
      print('Mesaj yükleme hatası: $e');
      // Hata durumunda in-memory mesajları döndür
      return List.from(_messages);
    }
  }

  // Mesaj gönder
  Future<Map<String, dynamic>> sendMessage(String content, int receiverId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {'success': false, 'message': 'Giriş yapmanız gerekiyor'};
      }

      final senderId = await _getCurrentUserId();
      if (senderId == null) {
        return {'success': false, 'message': 'Kullanıcı bilgisi alınamadı'};
      }

      // API'ye mesaj gönder
      final url = Uri.parse('$baseUrl/chat/messages');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'receiver_id': receiverId,
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final message = MessageModel.fromJson(data);
        
        // In-memory'ye ekle
        _messages.add(message);
        _messagesController.add(List.from(_messages));

        return {'success': true, 'message': message};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Mesaj gönderilemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Mesaj gönderilemedi: $e'};
    }
  }

  // Gerçek zamanlı mesajlaşma için polling başlat
  void startPolling({int? receiverId}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final messages = await getMessages(receiverId: receiverId);
      _messagesController.add(messages);
    });
  }

  // Polling'i durdur
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void dispose() {
    stopPolling();
    _messagesController.close();
  }
}

