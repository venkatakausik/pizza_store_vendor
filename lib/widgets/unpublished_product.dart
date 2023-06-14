import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store_vendor/screens/edit_view_product.dart';
import 'package:pizza_store_vendor/services/firebase_services.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';

class UnPublishedProduct extends StatelessWidget {
  const UnPublishedProduct({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return Container(
      child: StreamBuilder(
          stream: _services.products
              .where('published', isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SmallText(text: "Something went wrong...");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              child: FittedBox(
                child: DataTable(
                    showBottomBorder: true,
                    dataRowHeight: 60,
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey[200]),
                    columns: <DataColumn>[
                      DataColumn(
                          label:
                              Expanded(child: SmallText(text: "Product Name"))),
                      DataColumn(label: SmallText(text: "Image")),
                      DataColumn(label: SmallText(text: "Info")),
                      DataColumn(label: SmallText(text: "Actions")),
                    ],
                    rows: _productDetails(snapshot.data!, context)),
              ),
            );
          }),
    );
  }

  List<DataRow> _productDetails(QuerySnapshot snapshot, context) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      return DataRow(cells: [
        DataCell(Container(
          child: ListTile(
              subtitle: Row(
                children: [
                  SmallText(
                    text: "Code: ",
                    weight: FontWeight.bold,
                  ),
                  SmallText(text: document['sku']),
                ],
              ),
              title: Row(
                children: [
                  Expanded(child: SmallText(text: document['productName'])),
                ],
              )),
        )),
        DataCell(Container(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              children: [
                Image.network(
                  document['productImage'],
                  width: 50,
                ),
              ],
            ),
          ),
        )),
        DataCell(IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditViewProduct(productId: document['productId'])));
            },
            icon: Icon(Icons.info_outline))),
        DataCell(popUpButton(document.data(), context: context))
      ]);
    }).toList();
    return newList;
  }

  Widget popUpButton(data, {required BuildContext context}) {
    FirebaseServices _services = FirebaseServices();
    return PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'publish') {
            _services.publishProducts(id: data['productId']);
          }
          if (value == 'delete') {
            _services.deleteProducts(id: data['productId']);
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                  value: 'publish',
                  child: ListTile(
                    leading: Icon(Icons.check),
                    title: SmallText(
                      text: 'Publish',
                    ),
                  )),
              PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outlined),
                    title: SmallText(
                      text: 'Delete product',
                    ),
                  ))
            ]);
  }
}
