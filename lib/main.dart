import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:novau/core/theme/app_theme.dart';
import 'package:novau/core/theme/theme_provider.dart';
import 'package:novau/features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDummyApiKeyForNovaUApplication",
        authDomain: "novau-bec.firebaseapp.com",
        projectId: "novau-bec",
        storageBucket: "novau-bec.appspot.com",
        messagingSenderId: "123456789012",
        appId: "1:123456789012:web:abcdef1234567890",
      ),
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Smart Campus Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const LoginPage(),
    );
  }
}
