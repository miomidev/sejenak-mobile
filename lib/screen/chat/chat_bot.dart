import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/components/sejenak_text_field.dart';
import 'package:selena/app/partial/chat/sejenak_chat_node.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/chat/chat_bot.dart';

class ChatBotScreen {
  final TextEditingController commentInput = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatBotService _chatService = ChatBotService();

  // Daftar pesan
  final List<Map<String, dynamic>> _messages = []; // {'text': '', 'isMe': true/false}

  ChatBotScreen();

  /// Fungsi scroll ke bawah otomatis
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Fungsi kirim pesan ke chatbot
  Future<void> _sendMessage(BuildContext context) async {
    final text = commentInput.text.trim();
    if (text.isEmpty) return;

    commentInput.clear();
    _messages.add({'text': text, 'isMe': true});
    _scrollToBottom();

    // Update tampilan
    (context as Element).markNeedsBuild();

    try {
      final botReply = await _chatService.sendMessage(text);
      _messages.add({'text': botReply, 'isMe': false});
    } catch (e) {
      _messages.add({'text': '⚠️ Gagal memproses pesan: $e', 'isMe': false});
    }

    _scrollToBottom();
    (context as Element).markNeedsBuild();
  }

  /// Menampilkan modal chat
  void showChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1,
        minChildSize: 0.5,
        maxChildSize: 1,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: SejenakColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              verticalDirection: VerticalDirection.down,
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return SejenakChatNode(
                        message: msg['text'],
                        isMe: msg['isMe'],
                      );
                    },
                  ),
                ),
                _buildInputField(context, setState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header chat
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 32.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.cancel_outlined, color: SejenakColor.secondary),
          ),
          const SizedBox(width: 10),
          // ClipOval(
          //   child: Image.network(
          //     "https://cdn-icons-png.flaticon.com/512/4712/4712109.png",
          //     width: 35,
          //     height: 35,
          //     fit: BoxFit.cover,
          //   ),
          // ),
          const SizedBox(width: 8),
          const SejenakText(text: "Nemo"),
        ],
      ),
    );
  }

  /// Input field bawah
  Widget _buildInputField(BuildContext context, StateSetter setState) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: SejenakColor.white,
            border: Border(
                top: BorderSide(width: 1.0, color: Colors.grey.shade300)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: Row(
            children: [
              Expanded(
                child: SejenakTextField(
                  text: 'Ketik pesan...',
                  controller: commentInput,
                ),
              ),
              const SizedBox(width: 5),
              SejenakPrimaryButton(
                text: "",
                icon: "assets/svg/send.svg",
                action: () async {
                  await _sendMessage(context);
                  setState(() {}); // refresh tampilan setelah pesan dikirim
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
