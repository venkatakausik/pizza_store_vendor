import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store_vendor/providers/product_provider.dart';
import 'package:pizza_store_vendor/services/firebase_services.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:provider/provider.dart';

import '../widgets/published_product.dart';
import '../widgets/unpublished_product.dart';
import 'add_product_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var count = 0;

  getProductCount() async {
    await FirebaseFirestore.instance
        .collection('products')
        .count()
        .get()
        .then((value) {
      setState(() {
        count = value.count;
      });
    });
  }

  @override
  void initState() {
    getProductCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: Column(
        children: [
          Material(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Container(
                      child: Row(
                        children: [
                          SmallText(text: "Products"),
                          SizedBox(
                            width: Dimensions.width5,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.black38,
                            maxRadius: 10,
                            child: FittedBox(
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: SmallText(
                                  text: '${count}',
                                  weight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AddProductScreen.id);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: SmallText(
                        text: "Add New",
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          ),
          SizedBox(
            width: Dimensions.height10,
          ),
          TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(
                  text: 'Published',
                ),
                Tab(
                  text: 'UnPublished',
                ),
              ]),
          Expanded(
            child: Container(
              child: TabBarView(children: [
                PublishedProduct(),
                UnPublishedProduct(),
              ]),
            ),
          ),
        ],
      )),
    );
  }
}
