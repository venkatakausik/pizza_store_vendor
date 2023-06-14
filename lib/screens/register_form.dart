import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store_vendor/providers/auth_provider.dart';
import 'package:pizza_store_vendor/screens/home_screen.dart';
import 'package:pizza_store_vendor/services/firebase_services.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _nameTextController = TextEditingController();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cPasswordTextController = TextEditingController();
  var _locationTextController = TextEditingController();
  late String email;
  late String password;
  late String mobile;
  late String storeName;
  bool _isLoading = false;
  FirebaseServices _firebaseServices = FirebaseServices();

  scaffoldMessage(message) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: SmallText(text: message)));
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return _isLoading
        ? CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          )
        : Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter store name';
                      }
                      setState(() {
                        _nameTextController.text = value;
                      });
                      setState(() {
                        this.storeName = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.add_business),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        labelText: 'Business Name',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Mobile Number';
                      }
                      setState(() {
                        this.mobile = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone_iphone),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        labelText: 'Mobile Number',
                        prefixText: "+01 ",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter email address';
                      }
                      final bool _isValidEmail =
                          EmailValidator.validate(_emailTextController.text);
                      if (!_isValidEmail) {
                        return 'Invalid email format';
                      }

                      setState(() {
                        this.email = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        labelText: 'Email',
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _passwordTextController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter password';
                      }
                      if (value.length < 6) {
                        return 'Minimum 6 characters';
                      }

                      setState(() {
                        this.password = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                        labelText: 'Password',
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _cPasswordTextController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Confirm password';
                      }

                      if (value.length < 6) {
                        return 'Minimum 6 characters';
                      }

                      if (_passwordTextController.text !=
                          _cPasswordTextController.text) {
                        return 'Password doesn\'t match';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                        labelText: 'Confirm Password',
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLines: 6,
                    controller: _locationTextController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please press Navigation button';
                      }
                      if (_authData.storeLatitude == null) {
                        return 'Please press Navigation button ';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.location_on_outlined),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        suffixIcon: IconButton(
                            onPressed: () {
                              _locationTextController.text =
                                  "Locating...\n Please wait..";
                              _authData.getCurrentAddress().then((address) {
                                if (address != null) {
                                  setState(() {
                                    _locationTextController.text =
                                        '${_authData.placeName}\n${_authData.shopAddress}';
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: SmallText(
                                              text:
                                                  "Couldn't find location !! Please try again")));
                                }
                              });
                            },
                            icon: Icon(Icons.location_searching)),
                        labelText: 'Business Location',
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            _authData
                                .registerVendor(email, password)
                                .then((credential) {
                              if (credential?.user?.uid != null) {
                                _firebaseServices
                                    .getToken()
                                    .then((deviceToken) {
                                  _authData.saveVendorDataToDB(
                                      shopName: storeName,
                                      mobile: mobile,
                                      deviceToken: deviceToken);
                                });
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.pushReplacementNamed(
                                    context, HomeScreen.id);
                              } else {
                                scaffoldMessage(_authData.error);
                              }
                            });
                          }
                        },
                        child: SmallText(
                          text: 'Register',
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, LoginScreen.id);
                        },
                        style:
                            ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                        child: RichText(
                            text: TextSpan(text: '', children: [
                          TextSpan(
                              text: "Already have an account ? ",
                              style: TextStyle(
                                  letterSpacing: 0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Metropolis')),
                          TextSpan(
                              text: "Login",
                              style: TextStyle(
                                  letterSpacing: 0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Metropolis')),
                        ]))),
                  ],
                )
              ],
            ),
          );
  }
}
