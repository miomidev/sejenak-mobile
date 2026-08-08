import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_user_list.dart';
import 'package:selena/app/partial/sejenak_navbar.dart';

class TryComponent4 extends StatelessWidget {
  const TryComponent4({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            SejenakAudioList(
                action: () async {},
                title: 'Sejenak Audio List',
                image:
                    "https://images.unsplash.com/photo-1484517586036-ed3db9e3749e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
                text:
                    'hallo sldcjlsdjclsd csdc lskdjc sdcs dclsdcj sldc lsd cd csldc sc sdlkcjslcj sk cljlj ')
          ])),
      bottomNavigationBar: SejenakNavbar(),
    );
  }
}
