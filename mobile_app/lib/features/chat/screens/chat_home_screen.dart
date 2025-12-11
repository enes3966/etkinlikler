import 'package:flutter/material.dart';
import '../../../pages/chat/chat_page.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatPage(
      receiverId: 0, // 0 = genel grup sohbeti
      receiverName: 'Genel Sohbet',
    );
  }
}
