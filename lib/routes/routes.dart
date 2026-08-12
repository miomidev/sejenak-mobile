import 'package:flutter/material.dart';
import 'package:selena/screen/counseling/counseling.dart';
import 'package:selena/screen/journal/journal.dart';
import 'package:selena/screen/profile/profile.dart';
import 'package:selena/screen/landing_page/landing_page.dart';
import 'package:selena/screen/settings/settings_page.dart';
import 'package:selena/screen/transaction/token_purchase.dart';
import 'package:selena/screen/proposal/proposal_screen.dart';
import 'package:selena/screen/chat/chat_konselor.dart';

import '/screen/auth/login.dart';
import '/screen/auth/register.dart';
import '../screen/comunity/comunity.dart';
import '../screen/dashboard/dashboard.dart';
import '../screen/meditation/meditation.dart';
import '../screen/meditation/meditation_list_page.dart';

class SejenakRoute {
  static final Map<String, WidgetBuilder> routes = {
    '/comunity': (context) => Comunity(),
    '/settings': (context) => SettingsPage(),
    '/meditation-list-page': (context) => MeditationListPage(),
    '/dashboard': (context) => Dashboard(),
    '/meditation': (context) => Meditation(),
    '/login': (context) => LoginScreen(),
    '/register': (context) => RegisterScreen(),
    '/chat': (context) => Counseling(),
    '/chat-konselor': (context) => ChatKonselorScreen(),
    '/journal': (context) => Journal(),
    '/landing-page': (context) => LandingPage(),
    '/profile': (context) => Profile(),
    '/token-purchase': (context) => TokenPurchaseScreen(),
    '/proposal': (context) => ProposalScreen(),
  };
}
