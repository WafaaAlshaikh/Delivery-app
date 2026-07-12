// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform; 
import 'package:flutter/foundation.dart' show kIsWeb;  

import 'core/localization/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/socket_service.dart';
import 'services/notification_service.dart';
import 'screens/onboarding/splash_screen.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC84uzCJlzhsdCY16UTtYgtW4uiC-QT7MY",
    authDomain: "delivery-d2e88.firebaseapp.com",
    projectId: "delivery-d2e88",
    storageBucket: "delivery-d2e88.firebasestorage.app",
    messagingSenderId: "37666647494",
    appId: "1:37666647494:web:19000ef6c4688d3c4c16c7",
    measurementId: "G-336PFW8FN4",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyC84uzCJlzhsdCY16UTtYgtW4uiC-QT7MY",
    authDomain: "delivery-d2e88.firebaseapp.com",
    projectId: "delivery-d2e88",
    storageBucket: "delivery-d2e88.firebasestorage.app",
    messagingSenderId: "37666647494",
    appId: "1:37666647494:android:1:37666647494:android:b3fa99224adef7fe4c16c7", 
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyC84uzCJlzhsdCY16UTtYgtW4uiC-QT7MY",
    authDomain: "delivery-d2e88.firebaseapp.com",
    projectId: "delivery-d2e88",
    storageBucket: "delivery-d2e88.firebasestorage.app",
    messagingSenderId: "37666647494",
    appId: "1:37666647494:ios:YOUR_IOS_APP_ID", 
    iosClientId: "YOUR_IOS_CLIENT_ID", 
    iosBundleId: "com.example.frontend",
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    throw UnsupportedError('Platform not supported');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  await StorageService.init();

  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    print('✅ Notification Service initialized');
  } catch (e) {
    print('❌ Notification Service error: $e');
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      SocketService.getSocket();
    } catch (e) {
      print('❌ Socket Service error: $e');
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'PickNGo - Delivery App',
          debugShowCheckedModeBanner: false,

          locale: locale,
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(
              AppTheme.lightTheme.textTheme,
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}