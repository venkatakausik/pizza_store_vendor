import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:pizza_store_vendor/providers/product_provider.dart';
import 'package:pizza_store_vendor/services/firebase_services.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/category_list.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:provider/provider.dart';

class EditViewProduct extends StatefulWidget {
  final String productId;
  const EditViewProduct({super.key, required this.productId});

  @override
  State<EditViewProduct> createState() => _EditViewProductState();
}

class _EditViewProductState extends State<EditViewProduct> {
  FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  DocumentSnapshot? doc;
  var _skutext = TextEditingController();
  var _productNameText = TextEditingController();
  var _priceText = TextEditingController();
  var _comparedPriceText = TextEditingController();
  var _descriptionText = TextEditingController();
  var _taxText = TextEditingController();
  var _categoryTextController = TextEditingController();
  var _durationText = TextEditingController();
  double discount = double.nan;
  late String image;
  File? _image;
  String? dropDownValue;
  late String categoryImage;
  late String _itemType;

  List<TextEditingController> _nameControllers = [];
  List<TextFormField> _nameFields = [];
  List<TextEditingController> _priceControllers = [];
  List<TextFormField> _priceFields = [];

  List<TextEditingController> _toppingsNameControllers = [];
  List<TextFormField> _toppingsNameFields = [];
  List<TextEditingController> _toppingsPriceControllers = [];
  List<TextFormField> _toppingsPriceFields = [];

  List<TextEditingController> _toppingsExtraPriceControllers = [];
  List<TextFormField> _toppingsExtraPriceFields = [];

  bool isSizeSelectionEnabled = false;
  bool isToppingsSelectionEnabled = false;

  final _itemTypes = ["Veg", "Non Veg"];
  bool _editing = true;
  List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added'
  ];
  @override
  void initState() {
    getProductDetails();
    super.initState();
  }

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
                    child: SmallText(
                      text: "Cancel",
                      color: Colors.white,
                    ))
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
                SizedBox(
                  height: Dimensions.height10,
                ),
                _toppingsExtraPriceFields[i],
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    onPressed: () {
                      setState(() {
                        _toppingsNameFields.removeAt(i);
                        _toppingsPriceFields.removeAt(i);
                        _toppingsExtraPriceFields.removeAt(i);
                        _toppingsNameControllers.removeAt(i);
                        _toppingsPriceControllers.removeAt(i);
                        _toppingsExtraPriceControllers.removeAt(i);
                      });
                    },
                    child: SmallText(
                      text: "Cancel",
                      color: Colors.white,
                    ))
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

  generateToppingsTile(name, price, extraPrice) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final extraPriceController = TextEditingController();

    if (name != null) {
      nameController.text = name;
    }

    if (price != null) {
      priceController.text = price.toString();
    }

    if (extraPrice != null) {
      extraPriceController.text = price.toString();
    }

    final nameField = _generateTextField(nameController, "Topping");
    final telField = _generateTextField(priceController, "Price");

    setState(() {
      _toppingsNameControllers.add(nameController);
      _toppingsPriceControllers.add(priceController);
      _toppingsNameFields.add(nameField);
      _toppingsPriceFields.add(telField);
    });
  }

  generateSizeTile(name, price) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    if (name != null) {
      nameController.text = name;
    }

    if (price != null) {
      priceController.text = price.toString();
    }

    final nameField = _generateTextField(nameController, "Size");
    final telField = _generateTextField(priceController, "Price");

    setState(() {
      _nameControllers.add(nameController);
      _priceControllers.add(priceController);
      _nameFields.add(nameField);
      _priceFields.add(telField);
    });
  }

  Widget _addToppingsTile() {
    return ListTile(
      title: Icon(Icons.add),
      onTap: () {
        final nameController = TextEditingController();
        final priceController = TextEditingController();
        final extraPriceController = TextEditingController();

        final nameField = _generateTextField(nameController, "Topping");
        final regularPriceField =
            _generateTextField(priceController, "Price ( Regular )");
        final extraPriceField =
            _generateTextField(extraPriceController, "Price ( Extra )");

        setState(() {
          _toppingsNameControllers.add(nameController);
          _toppingsPriceControllers.add(priceController);
          _toppingsExtraPriceControllers.add(extraPriceController);
          _toppingsNameFields.add(nameField);
          _toppingsPriceFields.add(regularPriceField);
          _toppingsExtraPriceFields.add(extraPriceField);
        });
      },
    );
  }

  Widget _addSizeTile() {
    return ListTile(
      title: Icon(Icons.add),
      onTap: () {
        final nameController = TextEditingController();
        final priceController = TextEditingController();

        final nameField = _generateTextField(nameController, "Size");
        final telField = _generateTextField(priceController, "Price");

        setState(() {
          _nameControllers.add(nameController);
          _priceControllers.add(priceController);
          _nameFields.add(nameField);
          _priceFields.add(telField);
        });
      },
    );
  }

  Future<void> getProductDetails() async {
    _services.products
        .doc(widget.productId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          doc = document;
          _skutext.text = document['sku'];
          _productNameText.text = document['productName'];
          _priceText.text = document['price'].toString();
          if (!(document['comparedPrice'] as double).isNaN) {
            _comparedPriceText.text = document['comparedPrice'].toString();
            var difference = double.parse(_comparedPriceText.text) -
                double.parse(_priceText.text);
            discount =
                (difference / double.parse(_comparedPriceText.text) * 100);
          }

          image = document['productImage'];
          _descriptionText.text = document['description'];
          _categoryTextController.text = document['category']['mainCategory'];
          dropDownValue = document['collection'];
          _itemType = document['itemType'];
          // _itemSize = document['itemSize'];
          _taxText.text =
              document['tax'] != null ? document['tax'].toString() : '';
          _durationText.text = document['cookingTime'].toString();
          if ((document['itemSize'] as List) != null &&
              (document['itemSize'] as List).isNotEmpty) {
            isSizeSelectionEnabled = true;
            for (int i = 0; i < (document['itemSize'] as List).length; i++) {
              generateSizeTile(document['itemSize'][i]['name'],
                  document['itemSize'][i]['price']);
            }
          }

          if ((document['toppings'] as List) != null &&
              (document['toppings'] as List).isNotEmpty) {
            isToppingsSelectionEnabled = true;
            for (int i = 0; i < (document['toppings'] as List).length; i++) {
              generateToppingsTile(
                  document['toppings'][i]['name'],
                  document['toppings'][i]['price']['regular'],
                  document['toppings'][i]['price']['extra']);
            }
          }
          categoryImage = document['category']['categoryImage'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  _editing = false;
                });
              },
              child: SmallText(
                text: "Edit",
                color: Colors.white,
              ))
        ],
      ),
      bottomSheet: Container(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: SmallText(
                        text: "Cancel",
                        color: Colors.white,
                      ),
                    )),
              ),
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: _editing,
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      var sizePrice = [];
                      var toppingsPrice = [];
                      if ((isSizeSelectionEnabled == true &&
                              _nameControllers.isNotEmpty) ||
                          (isSizeSelectionEnabled == false &&
                              _nameControllers.isEmpty)) {
                        if ((isToppingsSelectionEnabled == true &&
                                _toppingsNameControllers.isNotEmpty) ||
                            (isToppingsSelectionEnabled == false &&
                                _toppingsNameControllers.isEmpty)) {
                          if (isSizeSelectionEnabled == true &&
                              _nameControllers.isNotEmpty) {
                            for (int i = 0; i < _nameControllers.length; i++) {
                              sizePrice.add({
                                "name": _nameControllers[i].text,
                                "price": double.parse(_priceControllers[i].text)
                              });
                            }
                          }

                          if (isToppingsSelectionEnabled == true &&
                              _toppingsNameControllers.isNotEmpty) {
                            for (int i = 0;
                                i < _toppingsNameControllers.length;
                                i++) {
                              toppingsPrice.add({
                                "name": _toppingsNameControllers[i].text,
                                "price": {
                                  "regular": double.parse(
                                      _toppingsPriceControllers[i].text),
                                  'extra': double.parse(
                                      _toppingsExtraPriceControllers[i].text)
                                }
                              });
                            }
                          }

                          EasyLoading.show(status: "Saving...");

                          if (_image != null) {
                            _provider
                                .uploadProductImage(
                                    _image!.path, _productNameText.text)
                                .then((url) {
                              if (url != null) {
                                EasyLoading.dismiss();
                                _provider.updateProduct(
                                    context: context,
                                    productName: _productNameText.text,
                                    tax: _taxText.text != null
                                        ? double.parse(_taxText.text)
                                        : null,
                                    price: double.parse(_priceText.text),
                                    comparedPrice:
                                        double.parse(_comparedPriceText.text),
                                    collection: dropDownValue,
                                    sku: _skutext.text,
                                    description: _descriptionText.text,
                                    productId: widget.productId,
                                    image: image,
                                    category: _categoryTextController.text,
                                    categoryImage: categoryImage,
                                    itemSize: sizePrice,
                                    toppings: toppingsPrice,
                                    itemType: _itemType,
                                    cookingTime: _durationText.text != null
                                        ? int.parse(_durationText.text)
                                        : null);
                              }
                            });
                          } else {
                            _provider.updateProduct(
                                context: context,
                                productName: _productNameText.text,
                                tax: _taxText.text != null &&
                                        _taxText.text.isNotEmpty
                                    ? double.parse(_taxText.text)
                                    : null,
                                price: double.parse(_priceText.text),
                                comparedPrice:
                                    double.parse(_comparedPriceText.text),
                                collection: dropDownValue,
                                sku: _skutext.text,
                                description: _descriptionText.text,
                                productId: widget.productId,
                                image: image,
                                category: _categoryTextController.text,
                                categoryImage: categoryImage,
                                itemType: _itemType,
                                itemSize: sizePrice,
                                toppings: toppingsPrice,
                                cookingTime: _durationText.text != null &&
                                        _durationText.text.isNotEmpty
                                    ? int.parse(_durationText.text)
                                    : null);
                            EasyLoading.dismiss();
                          }
                          _provider.resetProvider();
                        } else {
                          _provider.alertDialog(
                              context: context,
                              title: 'Toppings selection',
                              content: 'No toppings info added');
                        }
                      } else {
                        _provider.alertDialog(
                            context: context,
                            title: 'Size selection',
                            content: 'No size info');
                      }
                    }
                  },
                  child: Container(
                      color: Colors.deepOrangeAccent,
                      child: Center(
                        child: SmallText(
                          text: "Save",
                          color: Colors.white,
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
      body: doc == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: [
                    AbsorbPointer(
                      absorbing: _editing,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SmallText(text: "Product code: "),
                                  Container(
                                    width:
                                        Dimensions.width30 + Dimensions.width30,
                                    height: Dimensions.height30 +
                                        Dimensions.height10,
                                    child: TextFormField(
                                      controller: _skutext,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(left: 10),
                                          border: _editing
                                              ? InputBorder.none
                                              : OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor))),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Dimensions.height30,
                            child: TextFormField(
                              controller: _productNameText,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
                                  border: _editing
                                      ? InputBorder.none
                                      : OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                            ),
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                child: TextFormField(
                                  controller: _priceText,
                                  style: TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 5),
                                      prefixText: '\$',
                                      border: _editing
                                          ? InputBorder.none
                                          : OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor))),
                                ),
                              ),
                              SizedBox(
                                width: Dimensions.width5,
                              ),
                              Container(
                                width: 80,
                                child: TextFormField(
                                  controller: _comparedPriceText,
                                  style: TextStyle(
                                      fontSize: 15,
                                      decoration: TextDecoration.lineThrough),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 5),
                                      prefixText: '\$',
                                      border: _editing
                                          ? InputBorder.none
                                          : OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor))),
                                ),
                              ),
                              SizedBox(
                                width: Dimensions.width5,
                              ),
                              if (!discount.isNaN)
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: Colors.red),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8),
                                    child: SmallText(
                                        color: Colors.white,
                                        text:
                                            '${discount.toStringAsFixed(0)}% OFF'),
                                  ),
                                ),
                            ],
                          ),
                          SmallText(
                            text: "Inclusive of all Taxes",
                            color: Colors.grey,
                          ),
                          InkWell(
                            onTap: () {
                              _provider.getProductImage().then((image) {
                                setState(() {
                                  _image = image;
                                });
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _image != null
                                  ? Image.file(
                                      _image!,
                                      height: 300,
                                    )
                                  : Image.network(image, height: 300),
                            ),
                          ),
                          SmallText(
                            text: "About this product",
                            size: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: TextFormField(
                              maxLines: 5,
                              maxLength: 500,
                              controller: _descriptionText,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(color: Colors.grey),
                              decoration: InputDecoration(
                                  border: _editing
                                      ? InputBorder.none
                                      : OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                            ),
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
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      Colors.grey.shade100))),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _editing ? false : true,
                                  child: IconButton(
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
                                      icon: Icon(Icons.edit_outlined)),
                                )
                              ],
                            ),
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
                          SizedBox(
                            height: 70.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SmallText(text: "Product type"),
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
                                    fontSize: 15,
                                    color: Colors.black,
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
                                    activeColor: Theme.of(context).primaryColor,
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
                            ],
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          Row(
                            children: [
                              SmallText(
                                text: "Tax %:",
                              ),
                              SizedBox(
                                width: Dimensions.width5,
                              ),
                              Container(
                                width:
                                    Dimensions.width30 * 2 + Dimensions.width20,
                                child: TextFormField(
                                  controller: _taxText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: _editing
                                          ? InputBorder.none
                                          : OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor))),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SmallText(
                                text: "Duration in minutes (approx.):",
                              ),
                              SizedBox(
                                width: Dimensions.width5,
                              ),
                              Container(
                                width:
                                    Dimensions.width30 * 2 + Dimensions.width20,
                                child: TextFormField(
                                  controller: _durationText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: _editing
                                          ? InputBorder.none
                                          : OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor))),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 60,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
