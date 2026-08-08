import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:selena/models/user_models/user.dart' as models;
import 'package:selena/screen/auth/verification.dart';

import '../../app/components/sejenak_error.dart';
import '../../models/user_models/user_models.dart';
import '../../session/user_session.dart';
import '../api.dart';
import '../controller.dart';

abstract class SejenakAuth {
  Future<void> login(BuildContext context);
  Future<void> signOut();
}

abstract class AuthWithRegister {
  Future<void> register(BuildContext context);
  Future<void> verification(BuildContext context);
  Future<void> resendCode(BuildContext context);
}

class SejenakApiAuthService implements SejenakAuth, AuthWithRegister {
  final AuthFormController formController;
  SejenakApiAuthService(this.formController);

  @override
  Future<void> login(BuildContext context) async {
    print(
        "name: ${formController.name.text} password ${formController.password.text}");
    try {
      final response = await DioHttpClient.getInstance().post(
        API.login,
        data: {
          "email": formController.name.text,
          "password": formController.password.text,
        },
      );

      print("Response: ${response.data}");

      if (response.statusCode == 200) {
        UserSession().setUser(UserModels(
          code: response.data["code"] ?? "",
          status: response.data["status"] ?? "",
          refreshToken: response.data["refresh_token"] ?? "",
          expiresIn: response.data["expires_in"] ?? "",
          refreshExpiresIn: response.data["refresh_expires_in"] ?? "",
          token: response.data["access_token"] ?? "",
          totalPost: response.data["total_post"] ?? "",
          totalJournal: response.data["total_journal"] ?? "",
          totalLike: response.data["total_like"] ?? "",
          journalThisMonth: response.data["journal_this_month"] ?? "",
          journalStreak: response.data["journal_streak"] ?? "",
          postStreak: response.data["post_streak"] ?? "",
          user: response.data["user"] is Map<String, dynamic>
              ? models.User.fromJson(
                  response.data["user"] as Map<String, dynamic>)
              : null,
        ));
        DioHttpClient.getInstance().setToken(response.data["access_token"]);

        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Error: ${e.response?.statusCode}");
  print("Message: ${e.response?.data}");

  final errorMessage = e.response?.data['message'] ?? 'Terjadi kesalahan';
  showErrorDialog(context, errorMessage);
      } else {
        print("Error: $e");
      }
    }
  }

  @override
  Future<void> resendCode(BuildContext context) async {
    print("code: ${formController.code.text}");

    try {
      final response = await DioHttpClient.getInstance().post(
        API.resendCode,
        data: {
          "email": formController.email.text,
        },
      );

      print("Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Resend berhasil")),
  );
} else {
  showErrorDialog(context, "Login gagal! Silakan coba lagi!");
  print("Error: Status code bukan 200, status code: ${response.statusCode}");
}
    } catch (e) {
      if (e is DioException) {
        print("Dio Error: ${e.response?.statusCode}");
        print("Message: ${e.response?.data}");
        showErrorDialog(context, "Login gagal! Silakan coba lagi!");
      } else {
        print("Error: $e");
        showErrorDialog(context, "Terjadi kesalahan! Silakan coba lagi.");
      }
    }
  }
  @override
  Future<void> verification(BuildContext context) async {
    print("code: ${formController.code.text}");

    try {
      final response = await DioHttpClient.getInstance().post(
        API.verification,
        data: {
          "code": formController.code.text,
          "email": formController.email.text,
        },
      );

      print("Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        // Proses data user
        UserSession().setUser(UserModels(
          code: response.data["code"] ?? "",
          status: response.data["status"] ?? "",
          token: response.data["token"] ?? "",
          user: response.data["user"] is Map<String, dynamic>
              ? models.User.fromJson(
                  response.data["user"] as Map<String, dynamic>)
              : null,
        ));
        DioHttpClient.getInstance().setToken(response.data["token"]);

        Navigator.pushReplacementNamed(context, '/comunity');
      } else {
        showErrorDialog(context, "Login gagal! Silakan coba lagi!");
        print(
            "Error: Status code bukan 200, status code: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Error: ${e.response?.statusCode}");
        print("Message: ${e.response?.data}");
        showErrorDialog(context, "Login gagal! Silakan coba lagi!");
      } else {
        print("Error: $e");
        showErrorDialog(context, "Terjadi kesalahan! Silakan coba lagi.");
      }
    }
  }

  @override
  Future<void> register(BuildContext context) async {
    try {
      final response =
          await DioHttpClient.getInstance().post(API.register, data: {
        'name': formController.name.text,
        'username': formController.username.text,
        'email': formController.email.text,
        'password': formController.password.text,
        'password_confirmation': formController.passwordVerification.text,
      });
      print("response : ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              authFormController: formController,
            ),
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Error: ${e.response?.statusCode}");
        print("Message: ${e.response?.data}");
        showErrorDialog(context, "register gagal! Silakan coba lagi!");
      }
    }
  }

  @override
  Future<void> signOut() async {
    print("sign out");
  }
}

class GoogleAuthService implements SejenakAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      serverClientId:
          '550689254127-ja7pf95dlkjqd6v4aiv745l20ab689d5.apps.googleusercontent.com',
      clientId:
          '550689254127-mt8fvk5hohjrradridrgru8tq6r1p324.apps.googleusercontent.com');
  @override
  Future<void> login(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print(googleUser);
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final String? firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken != null) {
        print("ID Token: ${firebaseIdToken}");
      } else {
        print("ID Token tidak ditemukan.");
      }
      if (googleAuth.idToken == null) {
        showErrorDialog(context, "Login gagal! ID Token tidak ditemukan.");
        return;
      }     
      try {
        DioHttpClient.getInstance().setToken(firebaseIdToken!);
        final response = await DioHttpClient.getInstance().post(
          API.googleAuth,
          data: {
            'access_token' : googleAuth.accessToken,
            'name': googleUser.displayName,
            'username': googleUser.displayName,
            'email': googleUser.email,
            'profil': googleUser.photoUrl,
          },
        );
        if (response.statusCode == 200) {
          print(response);
          UserSession().setUser(UserModels(
            code: response.data["code"] ?? "",
            status: response.data["status"] ?? "",
            token: response.data["token"] ?? "",
            user: response.data["user"] is Map<String, dynamic>
                ? models.User.fromJson(
                    response.data["user"] as Map<String, dynamic>)
                : null,
          ));
          DioHttpClient.getInstance().setToken(response.data["token"]);

          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } catch (e) {
        if (e is DioException) {
          print("Dio Error: ${e.response?.statusCode}");
          print("Message: ${e.response?.data}");
          showErrorDialog(context, "register gagal! Silakan coba lagi!");
        }
      }
    } catch (e) {
      showErrorDialog(context, "login gagal! Silakan coba lagi!");
      print("Google Sign-In Error: ${e.toString()}");
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
