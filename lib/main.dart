import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/auth/initial_bindings.dart';
import 'package:furniture_shop/ui/services/notification_service.dart';
import 'package:furniture_shop/ui/splash_screen/splash_screen.dart';
import 'package:get/get.dart';
import 'ui/components/constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully");
    await NotificationService.initialize();
    print("Notification service initialized successfully");
  } catch (e) {
    print("Error during initialization: $e");
   }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Furniture app',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        hintColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
      initialBinding: AppInitialBindings(),
    );
  }
}
