import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakHeaderPage extends StatelessWidget {
  final String? text;
  final String? profile;
  const SejenakHeaderPage({super.key, this.text, this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SejenakText(
                text: text ?? "",
                type: SejenakTextType.h3,
                fontWeight: FontWeight.bold,
                color: SejenakColor.stroke,
              ),
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            profile != null ? NetworkImage(profile!) : null,
                        child: profile != null
                            ? null
                            : Icon(Icons.person, size: 30, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
