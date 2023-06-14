import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store_vendor/providers/auth_provider.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  static const String id = 'reset-password-screen';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  var _emailTextController = TextEditingController();
  late String email;
  late String password;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "images/forgot_pass.png",
                  height: 250,
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                RichText(
                    text: TextSpan(text: '', children: [
                  TextSpan(
                      text: 'Forgot Password',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(
                      style: TextStyle(color: Colors.red, fontSize: 10),
                      text:
                          "Don't worry, provide us your registered email, we'll send you an email to reset your password")
                ])),
                SizedBox(
                  height: Dimensions.height10,
                ),
                TextFormField(
                  controller: _emailTextController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter email';
                    }
                    final bool _isValidEmail =
                        EmailValidator.validate(_emailTextController.text);
                    if (!_isValidEmail) {
                      return 'Invalid email format';
                    }

                    setState(() {
                      email = value;
                    });
                    return null;
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _loading = true;
                              });
                              _authData.resetPassword(email);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: SmallText(
                                      text:
                                          "Check your email ${email} for reset password link")));
                            }

                            Navigator.pushReplacementNamed(
                                context, LoginScreen.id);
                          },
                          child: _loading
                              ? LinearProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : SmallText(
                                  text: "Reset Password",
                                  color: Colors.white,
                                )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
