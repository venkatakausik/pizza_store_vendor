import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:pizza_store_vendor/providers/auth_provider.dart';
import 'package:pizza_store_vendor/screens/login_screen.dart';
import 'package:pizza_store_vendor/screens/order_screen.dart';
import 'package:pizza_store_vendor/services/drawer_services.dart';
import 'package:pizza_store_vendor/services/firebase_services.dart';
import 'package:pizza_store_vendor/widgets/drawer_menu_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DrawerServices _services = DrawerServices();
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();
  String title = '';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseServices _firebaseServices = FirebaseServices();

  @override
  void initState() {
    _firebaseServices.getToken().then((value) {
      _firebaseServices.updateUserDeviceToken(deviceToken: value);
    });
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = const DarwinInitializationSettings();
    final InitializationSettings settings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );

    flutterLocalNotificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    super.initState();
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    if (notificationResponse.payload != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const OrderScreen()));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContent: true);
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('pizza_store_vendor', 'pizza_store_vendor',
              importance: Importance.max,
              styleInformation: bigTextStyleInformation,
              priority: Priority.max,
              playSound: false);
      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, notificationDetails,
          payload: message.data['body']);
    });
  }

  @override
  Widget build(BuildContext context) {
    var _authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: SliderDrawer(
            key: _sliderDrawerKey,
            appBar: SliderAppBar(
                appBarColor: Colors.white,
                title: Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700))),
            sliderOpenSize: 250,
            slider: MenuWidget(
              onItemClick: (title) {
                _sliderDrawerKey.currentState?.closeSlider();
                setState(() {
                  this.title = title;
                });

                if (title == 'LogOut') {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, LoginScreen.id);
                }
              },
            ),
            child: _services.drawerScreen(title)),
      ),
    );
  }
}
