import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store_vendor/screens/login_screen.dart';
import 'package:pizza_store_vendor/screens/register_form.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';

import '../widgets/small_text.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const String id = 'register-screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SmallText(
                      text: "Register",
                      size: 30,
                    )
                  ],
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                RegisterForm(),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
