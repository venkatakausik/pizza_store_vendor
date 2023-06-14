import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pizza_store_vendor/providers/product_provider.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:provider/provider.dart';

import '../widgets/category_list.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  static const String id = 'add-category-screen';

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  var _categoryTextController = TextEditingController();
  File? _image;
  late String categoryName;
  late String sku;

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);
    return Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: Column(
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
                          child: SmallText(text: "Categories / Add"),
                        ),
                      ),
                      ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (categoryName.isNotEmpty) {
                                if (_image != null) {
                                  EasyLoading.show(status: 'Saving..');
                                  _provider
                                      .uploadCategoryImage(
                                          _image!.path, categoryName)
                                      .then((url) {
                                    if (url != null) {
                                      EasyLoading.dismiss();
                                      _provider.saveCategoryDataToDB(
                                          context: context,
                                          name: categoryName,
                                          sku: sku);

                                      setState(() {
                                        _formKey.currentState!.reset();
                                        _categoryTextController.clear();
                                        _image = null;
                                      });
                                    } else {
                                      _provider.alertDialog(
                                          context: context,
                                          title: 'Image upload',
                                          content:
                                              'Failed to upload category image');
                                    }
                                  });
                                } else {
                                  _provider.alertDialog(
                                      context: context,
                                      title: 'Category Image',
                                      content: 'Category image not selected');
                                }
                              } else {
                                _provider.alertDialog(
                                    context: context,
                                    content: 'Category name is not entered',
                                    title: 'Category');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor),
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          label: SmallText(text: "Save")),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter category name";
                                  }
                                  setState(() {
                                    categoryName = value;
                                  });
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelText: "Category Name",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade100))),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    _provider.getCategoryImage().then((image) {
                                      setState(() {
                                        this._image = image;
                                      });
                                    });
                                  },
                                  child: SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: Card(
                                      child: Center(
                                          child: _image == null
                                              ? SmallText(
                                                  text: "Select image",
                                                )
                                              : Image.file(_image!)),
                                    ),
                                  ),
                                ),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter category code";
                                  }
                                  setState(() {
                                    sku = value;
                                  });
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelText: "SKU",
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade100))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
