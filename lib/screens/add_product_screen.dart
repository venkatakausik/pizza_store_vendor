import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:pizza_store_vendor/providers/product_provider.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:provider/provider.dart';

import '../widgets/category_list.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  static const String id = 'add-product-screen';

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added'
  ];

  var _categoryTextController = TextEditingController();
  var _comparedPriceTextController = TextEditingController();
  File? _image;
  late String productName;
  late String description;
  late double price;
  late double comparedPrice;
  late String sku;
  double tax = 0.0;
  late String cookingTime;

  String _itemType = "Veg";

  final _itemTypes = ["Veg", "Non Veg"];

  bool isSizeSelectionEnabled = false;
  bool isToppingsSelectionEnabled = false;

  List<TextEditingController> _nameControllers = [];
  List<TextFormField> _nameFields = [];
  List<TextEditingController> _priceControllers = [];
  List<TextFormField> _priceFields = [];

  List<TextEditingController> _toppingsNameControllers = [];
  List<TextFormField> _toppingsNameFields = [];
  List<TextEditingController> _toppingsPriceControllers = [];
  List<TextFormField> _toppingsPriceFields = [];

  Widget _sizeListView() {
    final children = [
      for (var i = 0; i < _nameControllers.length; i++)
        Container(
          margin: EdgeInsets.all(5),
          child: InputDecorator(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _nameFields[i],
                SizedBox(
                  height: Dimensions.height10,
                ),
                _priceFields[i],
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    onPressed: () {
                      setState(() {
                        _nameFields.removeAt(i);
                        _priceFields.removeAt(i);
                        _nameControllers.removeAt(i);
                        _priceControllers.removeAt(i);
                      });
                    },
                    child: SmallText(text: "Cancel"))
              ],
            ),
            decoration: InputDecoration(
              labelText: i.toString(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        )
    ];
    return Column(
      children: children,
    );
  }

  Widget _toppingsListView() {
    final children = [
      for (var i = 0; i < _toppingsNameControllers.length; i++)
        Container(
          margin: EdgeInsets.all(5),
          child: InputDecorator(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _toppingsNameFields[i],
                SizedBox(
                  height: Dimensions.height10,
                ),
                _toppingsPriceFields[i],
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    onPressed: () {
                      setState(() {
                        _toppingsNameFields.removeAt(i);
                        _toppingsPriceFields.removeAt(i);
                        _toppingsNameControllers.removeAt(i);
                        _toppingsPriceControllers.removeAt(i);
                      });
                    },
                    child: SmallText(text: "Cancel"))
              ],
            ),
            decoration: InputDecoration(
              labelText: i.toString(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        )
    ];
    return SingleChildScrollView(
      child: Column(
        children: children,
      ),
    );
  }

  TextFormField _generateTextField(
      TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return "Enter $hint";
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        labelText: hint,
      ),
    );
  }

  Widget _addToppingsTile() {
    return ListTile(
      title: Icon(Icons.add),
      onTap: () {
        final name = TextEditingController();
        final tel = TextEditingController();

        final nameField = _generateTextField(name, "Topping");
        final telField = _generateTextField(tel, "Price");

        setState(() {
          _toppingsNameControllers.add(name);
          _toppingsPriceControllers.add(tel);
          _toppingsNameFields.add(nameField);
          _toppingsPriceFields.add(telField);
        });
      },
    );
  }

  Widget _addSizeTile() {
    return ListTile(
      title: Icon(Icons.add),
      onTap: () {
        final name = TextEditingController();
        final tel = TextEditingController();

        final nameField = _generateTextField(name, "Size");
        final telField = _generateTextField(tel, "Price");

        setState(() {
          _nameControllers.add(name);
          _priceControllers.add(tel);
          _nameFields.add(nameField);
          _priceFields.add(telField);
        });
      },
    );
  }

  String? dropDownValue;
  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);
    return SafeArea(
      child: Scaffold(
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
                        child: SmallText(text: "Products / Add"),
                      ),
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_categoryTextController.text.isNotEmpty) {
                              if ((isSizeSelectionEnabled == true &&
                                      _nameControllers.isNotEmpty) ||
                                  (isSizeSelectionEnabled == false &&
                                      _nameControllers.isEmpty)) {
                                if ((isToppingsSelectionEnabled == true &&
                                    _toppingsNameControllers.isNotEmpty) || (isToppingsSelectionEnabled == false &&
                                    _toppingsNameControllers.isEmpty)) {
                                  if (_image != null) {
                                    EasyLoading.show(status: 'Saving..');
                                    _provider
                                        .uploadProductImage(
                                            _image!.path, productName)
                                        .then((url) {
                                      if (url != null) {
                                        EasyLoading.dismiss();
                                        var sizePrice = [];
                                        var toppingsPrice = [];
                                        if (isSizeSelectionEnabled == true &&
                                            _nameControllers.length != 0) {
                                          for (int i = 0;
                                              i < _nameControllers.length;
                                              i++) {
                                            sizePrice.add({
                                              "name": _nameControllers[i].text,
                                              "price": double.parse(
                                                  _priceControllers[i].text)
                                            });
                                          }
                                        }

                                        if (isToppingsSelectionEnabled ==
                                                true &&
                                            _toppingsNameControllers.length !=
                                                0) {
                                          for (int i = 0;
                                              i <
                                                  _toppingsNameControllers
                                                      .length;
                                              i++) {
                                            toppingsPrice.add({
                                              "name":
                                                  _toppingsNameControllers[i]
                                                      .text,
                                              "price": double.parse(
                                                  _toppingsPriceControllers[i]
                                                      .text)
                                            });
                                          }
                                        }

                                        _provider.saveProductDataToDb(
                                            context: context,
                                            comparedPrice: comparedPrice,
                                            collection: dropDownValue,
                                            description: description,
                                            price: price,
                                            sku: sku,
                                            tax: tax,
                                            itemType: _itemType,
                                            itemSize: sizePrice,
                                            toppings: toppingsPrice,
                                            cookingTime: int.parse(cookingTime),
                                            productName: productName);

                                        setState(() {
                                          _formKey.currentState!.reset();
                                          dropDownValue = null;
                                          _comparedPriceTextController.clear();
                                          _categoryTextController.clear();
                                          _image = null;
                                          isSizeSelectionEnabled = false;
                                          isToppingsSelectionEnabled = false;
                                          _nameControllers.clear();
                                          _priceControllers.clear();
                                          _toppingsNameControllers.clear();
                                          _toppingsPriceControllers.clear();
                                        });
                                      } else {
                                        _provider.alertDialog(
                                            context: context,
                                            title: 'Image upload',
                                            content:
                                                'Failed to upload product image');
                                      }
                                    });
                                  } else {
                                    _provider.alertDialog(
                                        context: context,
                                        title: 'Product Image',
                                        content: 'Provide Product Image');
                                  }
                                } else {
                                  _provider.alertDialog(
                                      context: context,
                                      title: 'Toppings selection',
                                      content: 'No Toppings info added');
                                }
                              } else {
                                _provider.alertDialog(
                                    context: context,
                                    title: 'Size selection',
                                    content:
                                        'Size selection enabled but no size info');
                              }
                            } else {
                              _provider.alertDialog(
                                  context: context,
                                  content: 'Category is not selected',
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
                                  return "Enter product name";
                                }
                                setState(() {
                                  productName = value;
                                });
                                return null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Product Name",
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  labelStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade100))),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              maxLength: 500,
                              validator: (value) {
                                setState(() {
                                  description = value!;
                                });
                                return null;
                              },
                              decoration: InputDecoration(
                                  labelText: "About Product",
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  labelStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade100))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _provider.getProductImage().then((image) {
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter product price";
                                }
                                setState(() {
                                  price = double.parse(value);
                                });
                                return null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Price",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade100))),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  if (price > double.parse(value)) {
                                    return "Compared price should be higher than price";
                                  }
                                  setState(() {
                                    comparedPrice = double.parse(value);
                                  });
                                } else {
                                  setState(() {
                                    comparedPrice = double.nan;
                                  });
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Compared Price",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade100))),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  SmallText(
                                    text: "Collection",
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: Dimensions.width10,
                                  ),
                                  DropdownButton<String>(
                                    value: dropDownValue,
                                    items: _collections
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                          value: value,
                                          child: SmallText(text: value));
                                    }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        dropDownValue = value;
                                      });
                                    },
                                    icon: Icon(Icons.arrow_drop_down),
                                    hint: SmallText(text: "Select collection"),
                                  )
                                ],
                              ),
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter product code";
                                }
                                setState(() {
                                  sku = value;
                                });
                                return null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Product code",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade100))),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: Dimensions.height20,
                                bottom: Dimensions.height10,
                              ),
                              child: Row(
                                children: [
                                  SmallText(text: "Category"),
                                  SizedBox(
                                    width: Dimensions.width10,
                                  ),
                                  Expanded(
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Select Category name";
                                          }
                                          return null;
                                        },
                                        controller: _categoryTextController,
                                        decoration: InputDecoration(
                                            hintText: "Not Selected",
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColor)),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.grey.shade100))),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CategoryList();
                                            }).whenComplete(() {
                                          setState(() {
                                            _categoryTextController.text =
                                                _provider.selectedCategory!;
                                          });
                                        });
                                      },
                                      icon: Icon(Icons.edit_outlined))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 70.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SmallText(text: "Select product type"),
                                  RadioGroup<String>.builder(
                                    direction: Axis.horizontal,
                                    groupValue: _itemType,
                                    horizontalAlignment:
                                        MainAxisAlignment.spaceAround,
                                    onChanged: (value) => setState(() {
                                      _itemType = value ?? '';
                                    }),
                                    items: _itemTypes,
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                    ),
                                    itemBuilder: (item) => RadioButtonBuilder(
                                      item,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SmallText(
                                        text: "Enable product size selection"),
                                    FlutterSwitch(
                                      width: 55.0,
                                      height: 25.0,
                                      valueFontSize: 12.0,
                                      toggleSize: 12.0,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      value: isSizeSelectionEnabled,
                                      onToggle: (val) {
                                        setState(() {
                                          isSizeSelectionEnabled = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                if (isSizeSelectionEnabled)
                                  Column(
                                    children: [
                                      _sizeListView(),
                                      _addSizeTile(),
                                    ],
                                  )
                              ],
                            ),
                            SizedBox(
                              height: Dimensions.height10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SmallText(
                                        text: "Enable toppings selection"),
                                    FlutterSwitch(
                                      width: 55.0,
                                      height: 25.0,
                                      valueFontSize: 12.0,
                                      toggleSize: 12.0,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      value: isToppingsSelectionEnabled,
                                      onToggle: (val) {
                                        setState(() {
                                          isToppingsSelectionEnabled = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                if (isToppingsSelectionEnabled)
                                  Column(
                                    children: [
                                      _toppingsListView(),
                                      _addToppingsTile(),
                                    ],
                                  )
                              ],
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  setState(() {
                                    tax = double.parse(value);
                                  });
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: "Tax %",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade100))),
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter cooking time (approx. in minutes)";
                                }
                                setState(() {
                                  cookingTime = value;
                                });
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText:
                                      "Cooking time in minutes (approx.)",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
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
      )),
    );
  }
}
