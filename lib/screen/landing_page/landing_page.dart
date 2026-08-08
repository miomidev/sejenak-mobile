import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:selena/app/components/sejenak_loading.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/auth/auth.dart';
import 'package:selena/session/user_session.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GoogleAuthService googleAuth = GoogleAuthService();
  bool isLoading = false;
  void _loadUserSession() async {
    await UserSession().loadUserFromPrefs();
print("user is login = ${UserSession().isLoggedIn}");
    if (UserSession().isLoggedIn) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/comunity'); // ganti dengan route utama
    }
  }
  void handleGoogleLogin() async {
    setState(() {
      isLoading = true;
    });
    await googleAuth.login(context);
    setState(() {
      isLoading = false;
    });
  }
@override
void initState() {

  super.initState();
_loadUserSession();  
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: SejenakLoading())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 64),
                    SvgPicture.asset(
                      'assets/svg/logo_mini.svg',
                      width: 40,
                      height: 37,
                      colorFilter: ColorFilter.mode(
                        SejenakColor.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SvgPicture.asset(
                      'assets/svg/icon.svg',
                      width: 221,
                      height: 220,
                    ),
                    const SizedBox(height: 97),
                    const SejenakText(
                      text: 'Luangkan sejenak waktu untuk diri anda',
                      type: SejenakTextType.h5,
                    ),
                    const SizedBox(height: 11),
                    SejenakPrimaryButton(
                      text: 'Masuk dengan Google',
                      icon: 'assets/svg/google.svg',
                      action: () async {
                        handleGoogleLogin();
                      },
                    ),
                    const SizedBox(height: 11),
                    SejenakPrimaryButton(
                      text: 'Masuk dengan Email',
                      icon: 'assets/svg/mail.svg',
                      action: () async {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SejenakText(text: "Belum punya akun?"),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            " Buat disini",
                            style: TextStyle(
                              color: Color.fromARGB(255, 14, 82, 137),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 64),
                    const Text(
                      "Dengan membuat akun, anda setuju dengan Kebijakan Penggunaan kamu dan memahami bahwa Kebijakan Privasi kami ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: SejenakColor.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
