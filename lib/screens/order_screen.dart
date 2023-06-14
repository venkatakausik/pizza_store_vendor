import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pizza_store_vendor/providers/order_provider.dart';
import 'package:pizza_store_vendor/services/order_services.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../widgets/big_text.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/small_text.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int tag = 1;

  List<String> options = [
    'All Orders',
    'Ordered',
    'Accepted',
    'Picked up',
    'On the way',
    'Delivered'
  ];

  OrderServices _orderServices = OrderServices();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              choiceStyle: C2ChipStyle(
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    _orderProvider.status = null;
                  });
                }
                setState(() {
                  tag = val;
                  _orderProvider.status = options[val];
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.order
                  .where('orderStatus',
                      isEqualTo: tag > 0 ? _orderProvider.status : null)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: SmallText(text: "Something went wrong.."),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.size == 0) {
                  return Center(
                    child: SmallText(
                        text: tag > 0
                            ? "No ${options[tag]} orders"
                            : "No orders. Continue ordering"),
                  );
                }

                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return OrderSummaryCard(document: document);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
