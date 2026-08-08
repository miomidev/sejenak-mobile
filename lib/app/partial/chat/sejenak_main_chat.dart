import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/components/sejenak_text_field.dart';
import 'package:selena/app/partial/chat/sejenak_chat_node.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakMainChat {
  final int id;
  final TextEditingController commentInput = TextEditingController();
  ScrollController _scrollController = ScrollController();

  SejenakMainChat({required this.id}) {
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void showChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1,
        minChildSize: 0.3,
        maxChildSize: 1,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: SejenakColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            verticalDirection: VerticalDirection.down,
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(10),
                  itemCount: 100,
                  itemBuilder: (context, index) => SejenakChatNode(
                    message: "Chat message ${index + 1}",
                    isMe: index.isEven,
                  ),
                ),
              ),
              _buildInputField(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 32.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.cancel_outlined, color: SejenakColor.secondary),
          ),
          SizedBox(width: 10),
          ClipOval(
            child: Image.network(
              "https://images.unsplash.com/photo-1533050487297-09b450131914?auto=format&fit=crop&w=1170&q=80",
              width: 35,
              height: 35,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 8),
          SejenakText(text: "john sejenak"),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: SejenakColor.white,
            border:
                Border(top: BorderSide(width: 1.0, color: Colors.grey[900]!)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: Row(
            children: [
              Expanded(
                  child: SejenakTextField(
                      text: 'Katakan sesuatu', controller: commentInput)),
              SizedBox(width: 5),
              SejenakPrimaryButton(
                  text: "",
                  icon: "assets/svg/send.svg",
                  action: () async {
                    _scrollToBottom();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
