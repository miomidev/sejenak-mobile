import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:selena/app/components/sejenak_loading.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/auth/auth.dart';
import 'package:selena/services/controller.dart';

class VerificationScreen extends StatefulWidget {
  final AuthFormController authFormController;

  const VerificationScreen({
    super.key,
    required this.authFormController,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}


class _VerificationScreenState extends State<VerificationScreen> {
  bool isLoading = false;
  late SejenakApiAuthService auth;
  List<TextEditingController> codeControllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  Future<void> handleVerification() async {
    setState(() => isLoading = true);

    String verificationCode =
        codeControllers.map((controller) => controller.text).join();
    widget.authFormController.code.text = verificationCode;


    setState(() => isLoading = false);

    if (verificationCode.length == 6) {
      auth = SejenakApiAuthService(widget.authFormController);
      // ignore: use_build_context_synchronously
      auth.verification(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Verifikasi berhasil! Kode: $verificationCode')),
      // );
    }
  }
  Future<void> handleResendCode() async {
    setState(() => isLoading = true);
      auth = SejenakApiAuthService(widget.authFormController);
      // ignore: use_build_context_synchronously
      auth.resendCode(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Verifikasi berhasil! Kode: $verificationCode')),
      // );
    setState(() => isLoading = false);
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  @override
  void initState() {
    super.initState();
    // Setup listener untuk setiap controller
    for (int i = 0; i < codeControllers.length; i++) {
      codeControllers[i].addListener(() {
        if (codeControllers[i].text.length == 1 && i < 5) {
          FocusScope.of(context).requestFocus(focusNodes[i + 1]);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in codeControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Icon(Icons.close, color: SejenakColor.primary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: isLoading
          ? const Center(child: SejenakLoading())
          : Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 50, right: 50),
                child: Column(
                  children: [
                    SizedBox(height: 64),
                    SvgPicture.asset(
                      'assets/svg/logo_mini.svg',
                      width: 40,
                      height: 37,
                      colorFilter: ColorFilter.mode(
                        SejenakColor.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 10),
                    SejenakText(
                      text: "Sejenak",
                      type: SejenakTextType.h3,
                    ),
                    SizedBox(height: 103),
                    SejenakText(
                      text: "Verifikasi Kode",
                      type: SejenakTextType.h5,
                    ),
                    SizedBox(height: 8),
                    SejenakText(
                      text: "Masukkan 6 digit kode yang dikirim ke email Anda",
                      type: SejenakTextType.small,
                      color: SejenakColor.secondary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),

                    // Input kode verifikasi 6 digit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 40,
                          height: 50,
                          child: TextField(
                            controller: codeControllers[index],
                            focusNode: focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                color: SejenakColor.dark),
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: SejenakColor.primary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: SejenakColor.primary, width: 2),
                              ),
                            ),
                            onChanged: (value) => _onCodeChanged(value, index),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 32),
                    SejenakPrimaryButton(
                      text: "Verifikasi",
                      action: handleVerification,
                      color: SejenakColor.secondary,
                    ),
                    SizedBox(height: 21),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SejenakText(
                          text: "Tidak menerima kode? ",
                          type: SejenakTextType.small,
                          color: SejenakColor.secondary,
                        ),
                        GestureDetector(
                          onTap: () {
                            print("Kirim ulang kode");
                          },
                          child: SejenakText(
                            text: "Kirim Ulang",
                            type: SejenakTextType.small,
                            color: SejenakColor.primary,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
