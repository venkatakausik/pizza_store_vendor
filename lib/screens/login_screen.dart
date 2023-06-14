import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store_vendor/providers/auth_provider.dart';
import 'package:pizza_store_vendor/screens/home_screen.dart';
import 'package:pizza_store_vendor/screens/register_screen.dart';
import 'package:pizza_store_vendor/screens/reset_password.dart';
import 'package:pizza_store_vendor/services/firebase_services.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late Icon icon;
  bool _visible = false;
  var _emailTextController = TextEditingController();
  late String email;
  late String password;
  bool _loading = false;
  FirebaseServices _firebaseServices = FirebaseServices();
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SmallText(
                            text: "Login",
                            size: 30,
                          )
                        ],
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      TextFormField(
                        controller: _emailTextController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter email';
                          }
                          final bool _isValidEmail = EmailValidator.validate(
                              _emailTextController.text);
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
                                    width: 2,
                                    color: Theme.of(context).primaryColor)),
                            focusColor: Theme.of(context).primaryColor),
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter password';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 characters';
                          }

                          setState(() {
                            password = value;
                          });
                          return null;
                        },
                        obscureText: _visible == false ? true : false,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Password',
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _visible = !_visible;
                                  });
                                },
                                icon: _visible
                                    ? Icon(Icons.visibility)
                                    : Icon(Icons.visibility_off)),
                            prefixIcon: Icon(
                              Icons.vpn_key_outlined,
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: Theme.of(context).primaryColor)),
                            focusColor: Theme.of(context).primaryColor),
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, ResetPasswordScreen.id);
                            },
                            child: Text("Forgot Password",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Metropolis')),
                          ),
                        ],
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
                                    _authData
                                        .loginVendor(email, password)
                                        .then((credential) {
                                      if (credential != null) {
                                        setState(() {
                                          _loading = false;
                                        });
                                        _firebaseServices
                                            .getToken()
                                            .then((value) {
                                          _firebaseServices
                                              .updateUserDeviceToken(
                                                  deviceToken: value)
                                              .then((value) {
                                            Navigator.pushReplacementNamed(
                                                context, HomeScreen.id);
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          _loading = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: SmallText(
                                                    text: _authData.error)));
                                      }
                                    });
                                  }
                                },
                                child: _loading
                                    ? LinearProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        backgroundColor: Colors.transparent,
                                      )
                                    : SmallText(
                                        text: "Login",
                                        color: Colors.white,
                                      )),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, RegisterScreen.id);
                              },
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: RichText(
                                  text: TextSpan(text: '', children: [
                                TextSpan(
                                    text: "Don't have an account ? ",
                                    style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Metropolis')),
                                TextSpan(
                                    text: "Register",
                                    style: TextStyle(
                                        color: Colors.red,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Metropolis')),
                              ]))),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
