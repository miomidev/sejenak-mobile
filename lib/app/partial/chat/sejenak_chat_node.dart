import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakChatNode extends StatelessWidget {
  final String message;
  final bool isMe; // True jika pesan dari pengguna sendiri

  SejenakChatNode({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isMe ? SejenakColor.secondary : SejenakColor.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: isMe ? Radius.circular(15) : Radius.circular(0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(15),
            ),
          ),
          child: SejenakText(
            text: message,
            textAlign: TextAlign.left,
          )),
    );
  }
}
