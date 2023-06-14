import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store_vendor/providers/product_provider.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:provider/provider.dart';

class MenuWidget extends StatefulWidget {
  final Function(String) onItemClick;

  const MenuWidget({Key? key, required this.onItemClick}) : super(key: key);

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  var vendorData;
  @override
  void initState() {
    getVendorData();
    super.initState();
  }

  Future<DocumentSnapshot> getVendorData() async {
    var result = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(user!.uid)
        .get();

    setState(() {
      vendorData = result;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);
    _provider.getShopName(vendorData != null ? vendorData['shopName'] : '');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FittedBox(
              child: Row(
                children: [
                  Text(
                    vendorData != null ? vendorData['shopName'] : "Shop Name",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: Dimensions.height10,
          ),
          sliderItem('Dashboard', Icons.dashboard_outlined),
          sliderItem('Products', Icons.shopping_bag_outlined),
          sliderItem('Categories', CupertinoIcons.collections),
          sliderItem('Orders', Icons.list_alt_outlined),
          // sliderItem('Reports', Icons.stacked_bar_chart),
          // sliderItem('Settings', Icons.settings_outlined),
          sliderItem('LogOut', Icons.arrow_back_ios)
        ],
      ),
    );
  }

  Widget sliderItem(String title, IconData icons) => InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
        child: SizedBox(
          height: Dimensions.height45,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(children: [
              Icon(icons, color: Colors.black54, size: 18),
              SizedBox(width: Dimensions.width10),
              SmallText(text: title)
            ]),
          ),
        ),
      ),
      onTap: () {
        widget.onItemClick(title);
      });
}
