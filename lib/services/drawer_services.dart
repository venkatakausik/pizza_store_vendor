import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store_vendor/screens/dashboars_screen.dart';
import 'package:pizza_store_vendor/screens/login_screen.dart';

import '../screens/category_screen.dart';
import '../screens/order_screen.dart';
import '../screens/product_screen.dart';

class DrawerServices {
  Widget drawerScreen(title) {
    if (title == 'Dashboard') {
      return MainScreen();
    }

    if (title == 'Products') {
      return ProductScreen();
    }

    if (title == 'Categories') {
      return CategoryScreen();
    }

    if (title == 'Orders') {
      return OrderScreen();
    }

    return MainScreen();
  }
}
