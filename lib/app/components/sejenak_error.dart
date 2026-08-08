import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';

Future<void> showErrorDialog(BuildContext context, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon utama
              Icon(
                Icons.error_outline_rounded,
                color: SejenakColor.primary,
                size: 60,
              ),
              const SizedBox(height: 16),

              // Judul dialog
              SejenakText(
                text: "Oops...!",
                type: SejenakTextType.h5,
                color: SejenakColor.primary,
              ),
              const SizedBox(height: 12),

              // Pesan error
              SejenakText(
                text: message,
                type: SejenakTextType.regular,
                color: SejenakColor.secondary,
              ),
              const SizedBox(height: 24),

              // Tombol Tutup
              SizedBox(
                width: double.infinity,
                child: SejenakPrimaryButton(
                  text: "Tutup",
                  color: SejenakColor.primary,
                  action: () async{
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
