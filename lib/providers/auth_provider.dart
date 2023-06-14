import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:geolocator/geolocator.dart';

class AuthProvider with ChangeNotifier {
  late double storeLatitude;
  late double storeLongitude;
  late String shopAddress;
  late String placeName;
  String error = '';
  late String email;

  Future getCurrentAddress() async {
    bool _serviceEnabled;
    LocationPermission _permissionGranted;
    Position _locationData;

    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      await Geolocator.openLocationSettings();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await Geolocator.checkPermission();
    if (_permissionGranted == LocationPermission.denied) {
      _permissionGranted = await Geolocator.requestPermission();
      if (_permissionGranted == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (_permissionGranted == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _locationData = await Geolocator.getCurrentPosition();
    this.storeLatitude = _locationData.latitude;
    this.storeLongitude = _locationData.longitude;
    notifyListeners();

    List<geocode.Placemark> _placemarks =
        await geocode.placemarkFromCoordinates(
            _locationData.latitude, _locationData.longitude);
    var storeAddress = _placemarks.first;
    this.shopAddress = storeAddress.street! +
        ", " +
        storeAddress.subLocality! +
        ", " +
        storeAddress.locality! +
        ", " +
        storeAddress.country! +
        ", " +
        storeAddress.postalCode!;
    this.placeName = storeAddress.name!;
    notifyListeners();
    return storeAddress;
  }

  // register using email address
  Future<UserCredential?> registerVendor(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'The password provided is too weak.';
        notifyListeners();
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        this.error = 'The account already exists for that email.';
        notifyListeners();
        print('The account already exists for that email.');
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return null;
  }

  // login vendor
  Future<UserCredential?> loginVendor(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return null;
  }

  // reset password
  Future<void> resetPassword(email) async {
    this.email = email;
    notifyListeners();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
  }

  // save vendor details in firestore DB
  Future<void> saveVendorDataToDB(
      {String? shopName, String? mobile, String? deviceToken}) async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentReference _vendors =
        FirebaseFirestore.instance.collection('vendors').doc(user?.uid);
    _vendors.set({
      'uid': user?.uid,
      'shopName': shopName,
      'mobile': mobile,
      'email': this.email,
      'address': '${this.placeName}: ${this.shopAddress}',
      'location': GeoPoint(this.storeLatitude, this.storeLongitude),
      'shopOpen': true,
      'deviceToken': deviceToken,
    });
    return null;
  }
}
