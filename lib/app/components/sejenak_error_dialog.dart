import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';

/// Fungsi untuk menampilkan dialog error dengan gaya Sejenak
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: SejenakColor.primary,
                size: 60,
              ),
              const SizedBox(height: 16),
              SejenakText(
                text: "Terjadi Kesalahan",
                type: SejenakTextType.h5,
                color: SejenakColor.primary,
              ),
              const SizedBox(height: 12),
              SejenakText(
                text: message,
                type: SejenakTextType.regular,
                color: SejenakColor.secondary,
              ),
              const SizedBox(height: 24),
              SejenakPrimaryButton(
                text: "Tutup",
                color: SejenakColor.primary,
                action: () async {
    Navigator.of(context).pop();
  },
              ),
            ],
          ),
        ),
      );
    },
  );
}
