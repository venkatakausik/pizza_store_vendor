import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:pizza_store_vendor/providers/auth_provider.dart';
import 'package:pizza_store_vendor/providers/order_provider.dart';
import 'package:pizza_store_vendor/providers/product_provider.dart';
import 'package:pizza_store_vendor/screens/add_category_screen.dart';
import 'package:pizza_store_vendor/screens/add_product_screen.dart';
import 'package:pizza_store_vendor/screens/home_screen.dart';
import 'package:pizza_store_vendor/screens/login_screen.dart';
import 'package:pizza_store_vendor/screens/register_screen.dart';
import 'package:pizza_store_vendor/screens/reset_password.dart';
import 'package:pizza_store_vendor/screens/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message ${message.messageId}');
}

Future<void> main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Store Vendor App',
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
        fontFamily: 'Metropolis',
      ),
      builder: EasyLoading.init(),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ResetPasswordScreen.id: (context) => ResetPasswordScreen(),
        AddProductScreen.id: (context) => AddProductScreen(),
        AddCategoryScreen.id: (context) => AddCategoryScreen()
      },
    );
  }
}
