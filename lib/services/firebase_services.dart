import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseServices {
  CollectionReference category =
      FirebaseFirestore.instance.collection('category');

  CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  CollectionReference deliveryPartners =
      FirebaseFirestore.instance.collection('boys');

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  CollectionReference vendors =
      FirebaseFirestore.instance.collection('vendors');

  CollectionReference order = FirebaseFirestore.instance.collection('orders');

  Future<void> publishProducts({id}) {
    return products.doc(id).update({'published': true});
  }

  Future<void> unPublishProducts({id}) {
    return products.doc(id).update({'published': false});
  }

  Future<void> unPublishcategories({id}) {
    return category.doc(id).update({'published': false});
  }

  Future<void> publishCategories({id}) {
    return category.doc(id).update({'published': true});
  }

  Future<void> deleteProducts({id}) {
    return products.doc(id).delete();
  }

  Future<void> deleteCategories({id}) {
    return category.doc(id).delete();
  }

  User? user = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot> getShopDetails() async {
    DocumentSnapshot doc = await vendors.doc(user!.uid).get();
    return doc;
  }

  Future<DocumentSnapshot> getCustomerDetails(id) async {
    DocumentSnapshot doc = await users.doc(id).get();
    return doc;
  }

  Future<void> selectDeliveryPartners(orderId, location, name, phone) {
    var result = order.doc(orderId).update({
      'deliveryPartner': {'name': name, 'phone': phone, 'location': location}
    });
    return result;
  }

  Future<String> getToken() async {
    var deviceToken = '';
    await FirebaseMessaging.instance.getToken().then((value) {
      print("My token is $value");
      deviceToken = value!;
    });
    return deviceToken;
  }

  Future<void> updateUserDeviceToken({deviceToken}) async {
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('vendors')
        .doc(user?.uid)
        .update({"deviceToken": deviceToken});
  }
}
