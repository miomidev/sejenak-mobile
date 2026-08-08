import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:selena/background/background_handler.dart';
import 'package:selena/firebase_options.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/screen/landing_page/landing_page.dart';
import 'package:selena/services/audio/audio_initializer/audio_initializer.dart';
import 'package:selena/services/journal/journal.dart';
import 'package:selena/services/sensor/sensor.dart';
import 'package:selena/session/user_session.dart';
import 'package:workmanager/workmanager.dart';

import 'routes/routes.dart';

late SensorSyncService sensorSyncService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  await AudioInitializer.init();
  final journalService = JournalApiService();
  final userSession = UserSession();
  await userSession.loadUserFromPrefs();

  final sensorService = SensorService();
  final sensorCache = SensorCache();
  await sensorCache.init();
  
  sensorSyncService = SensorSyncService(
    sensorService: sensorService,
    sensorCache: sensorCache,
  );
  await sensorSyncService.init();

  if (userSession.isLoggedIn) {
    await sensorService.requestPermissions();
    await sensorService.startListening();
    sensorSyncService.startPeriodicSync();
    
    await Workmanager().registerPeriodicTask(
      "sensor-sync-task",
      "sensor_sync",
      frequency: Duration(minutes: 60),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      inputData: <String, dynamic>{
        'sync_type': 'sensor',
      },
    );

    await Workmanager().registerPeriodicTask(
      "journal-sync-task",
      "journal_sync",
      frequency: Duration(hours: 2),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: <String, dynamic>{
        'sync_type': 'journal',
      },
    );
  }

  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.last : ConnectivityResult.none;
    if (result != ConnectivityResult.none) {
      journalService.syncPendingJournals();
      sensorSyncService.syncPendingData();
    }
  });

  runApp(MainApp());
}



class MainApp extends StatelessWidget {
  final isLoggedIn = UserSession().isLoggedIn;
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: SejenakColor.white,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            backgroundColor: SejenakColor.white,
            selectedItemColor: SejenakColor.secondary,
            unselectedItemColor: SejenakColor.stroke,
            selectedLabelStyle:
                TextStyle(fontSize: 12, fontFamily: 'Lexend', wordSpacing: 0.4),
            unselectedLabelStyle:
                TextStyle(fontSize: 12, fontFamily: 'Lexend', wordSpacing: 0.4),
          )),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
  WidgetBuilder? builder = SejenakRoute.routes[settings.name];

  if (builder == null) return null;

  if (settings.name == '/profile' || settings.name == '/profile') {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: 400),
    );
  } else {
    // tanpa animasi
    return MaterialPageRoute(builder: builder, settings: settings);
  }
},

      home: LandingPage(),
    );
  }
}
