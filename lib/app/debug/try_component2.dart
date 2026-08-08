import 'package:flutter/material.dart';
import 'package:selena/app/partial/comunity/sejenak_comment_container.dart';

class TryComponent2 extends StatelessWidget {
  const TryComponent2({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SejenakCommentContainer(
                postImage:
                    "https://images.unsplash.com/photo-1533050487297-09b450131914?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80",
                text:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                name: "john sekejap",
                date: "jan 9, 2022",
                likes: 10,
                comment: 0,
                isLike: false,
                isMe: false,
                child: Column(
                  children: [
                    SejenakCommentContainer(
                      postImage:
                          "https://images.unsplash.com/photo-1533050487297-09b450131914?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80",
                      text:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                      name: "john sekejap",
                      date: "jan 9, 2022",
                      likes: 10,
                      comment: 0,
                      isLike: false,
                      isMe: false,
                    ),
                    SejenakCommentContainer(
                      postImage:
                          "https://images.unsplash.com/photo-1533050487297-09b450131914?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80",
                      text:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                      name: "john sekejap",
                      date: "jan 9, 2022",
                      likes: 10,
                      comment: 0,
                      isLike: false,
                      isMe: false,
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
