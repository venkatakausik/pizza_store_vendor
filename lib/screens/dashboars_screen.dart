import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:pizza_store_vendor/screens/home_screen.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';

import '../widgets/drawer_menu_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SmallText(text: "Dashboard Screen"),
      ),
    );
  }
}
