import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';

class ProductProvider with ChangeNotifier {
  String? selectedCategory = 'not selected';
  File? productImage;
  late File categoryImageFile;
  late String pickedError;
  late String shopName;
  String? categoryImage;
  String? productUrl;
  late String categoryUrl;

  selectCategory(selectedCategory, categoryImage) {
    this.selectedCategory = selectedCategory;
    this.categoryImage = categoryImage;
    notifyListeners();
  }

  Future<File> getProductImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.productImage = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickedError = 'No image selected';
      print('No image selected');
      notifyListeners();
    }
    return this.productImage!;
  }

  Future<File> getCategoryImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.categoryImageFile = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickedError = 'No image selected';
      print('No image selected');
      notifyListeners();
    }
    return this.categoryImageFile;
  }

  getShopName(shopName) {
    this.shopName = shopName;
    notifyListeners();
  }

  resetProvider() {
    this.selectedCategory = null;
    this.productImage = null;
    this.categoryImage = null;
    this.productUrl = null;
    notifyListeners();
  }

  Future<String> uploadProductImage(filePath, productName) async {
    File file = File(filePath);
    FirebaseStorage _storage = FirebaseStorage.instance;
    var timestamp = Timestamp.now().microsecondsSinceEpoch;
    try {
      await _storage
          .ref('productImage/${this.shopName}/$productName$timestamp')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }

    String _downloadUrl = await _storage
        .ref('productImage/${this.shopName}/$productName$timestamp')
        .getDownloadURL();
    this.productUrl = _downloadUrl;
    notifyListeners();
    return _downloadUrl;
  }

  Future<String> uploadCategoryImage(filePath, categoryName) async {
    File file = File(filePath);
    FirebaseStorage _storage = FirebaseStorage.instance;
    var timestamp = Timestamp.now().microsecondsSinceEpoch;
    try {
      await _storage.ref('categoryImage/$categoryName$timestamp').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }

    String _downloadUrl = await _storage
        .ref('categoryImage/$categoryName$timestamp')
        .getDownloadURL();
    this.categoryUrl = _downloadUrl;
    notifyListeners();
    return _downloadUrl;
  }

  alertDialog({context, title, content}) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: SmallText(text: title),
            content: SmallText(text: content),
            actions: [
              CupertinoDialogAction(
                child: SmallText(text: 'OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> saveCategoryDataToDB({name, context, sku}) async {
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    CollectionReference _products =
        FirebaseFirestore.instance.collection('category');
    try {
      _products.doc(timestamp.toString()).set({
        'name': name,
        'categoryId': timestamp.toString(),
        'sku': sku,
        'published': false,
        'categoryImage': this.categoryUrl,
      });
      alertDialog(
        context: context,
        title: 'Save category',
        content: 'Category Details saved successfully',
      );
    } catch (e) {
      alertDialog(
        context: context,
        title: 'Save Data',
        content: '${e.toString()}',
      );
    }
  }

  Future<void> saveProductDataToDb(
      {productName,
      description,
      price,
      comparedPrice,
      collection,
      sku,
      tax,
      cookingTime,
      itemType,
      itemSize,
      toppings,
      context}) async {
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(timestamp.toString()).set({
        'seller': {"shopName": this.shopName, "sellerUid": user!.uid},
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'itemType': itemType,
        'itemSize': itemSize,
        'toppings': toppings,
        'sku': sku,
        'category': {
          'mainCategory': this.selectedCategory,
          'categoryImage': this.categoryImage
        },
        'tax': tax,
        'published': false,
        'productId': timestamp.toString(),
        'productImage': this.productUrl,
        'cookingTime': cookingTime
      });
      alertDialog(
        context: context,
        title: 'Save Data',
        content: 'Product Details saved successfully',
      );
    } catch (e) {
      alertDialog(
        context: context,
        title: 'Save Data',
        content: '${e.toString()}',
      );
    }
    return null;
  }

  Future<void> updateProduct(
      {productName,
      description,
      price,
      comparedPrice,
      collection,
      sku,
      tax,
      context,
      productId,
      image,
      category,
      cookingTime,
      itemType,
      itemSize,
      toppings,
      categoryImage}) async {
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(productId).update({
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'itemType': itemType,
        'itemSize': itemSize,
        'toppings': toppings,
        'sku': sku,
        'category': {
          'mainCategory': category,
          'categoryImage':
              this.categoryImage == null ? categoryImage : this.categoryImage
        },
        'tax': tax,
        'productImage': this.productUrl == null ? image : this.productUrl,
        'cookingTime': cookingTime
      });
      alertDialog(
        context: context,
        title: 'Save Data',
        content: 'Product Details saved successfully',
      );
    } catch (e) {
      alertDialog(
        context: context,
        title: 'Save Data',
        content: '${e.toString()}',
      );
    }
    return null;
  }
}
