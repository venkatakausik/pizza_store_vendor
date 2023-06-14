import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/published_category.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:pizza_store_vendor/widgets/unpublished_categories.dart';

import 'add_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  var count = 0;
  getCategoryCount() async {
    await FirebaseFirestore.instance
        .collection('category')
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
    getCategoryCount();
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
                          SmallText(text: "Categories"),
                          SizedBox(
                            width: Dimensions.width10,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.black38,
                            maxRadius: 8,
                            child: FittedBox(
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: SmallText(
                                  text: "${count}",
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
                        Navigator.pushNamed(context, AddCategoryScreen.id);
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
                PublishedCategory(),
                UnPublishedCategory(),
              ]),
            ),
          ),
        ],
      )),
    );
  }
}
