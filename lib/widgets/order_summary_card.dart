import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:pizza_store_vendor/services/firebase_services.dart';
import 'package:pizza_store_vendor/services/order_services.dart';
import 'package:pizza_store_vendor/utils/dimensions.dart';
import 'package:pizza_store_vendor/widgets/delivery_partner_list.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';

import '../services/notification_services.dart';

class OrderSummaryCard extends StatefulWidget {
  const OrderSummaryCard({super.key, required this.document});

  final DocumentSnapshot document;

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  OrderServices _orderServices = OrderServices();
  FirebaseServices _firebaseServices = FirebaseServices();
  NotificationServices _notificationServices = NotificationServices();
  showMyDialog(title, status, documentId, context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: SmallText(text: title),
            content: SmallText(text: "Are you sure ?"),
            actions: [
              TextButton(
                  onPressed: () {
                    EasyLoading.show(status: "Updating status");
                    status == 'Accepted'
                        ? _orderServices
                            .updateOrderStatus(documentId, status)
                            .then((value) {
                            _notificationServices.sendPushMessage(
                                _customer['deviceToken'],
                                "Your order is $status",
                                "Tap here to know more");
                            EasyLoading.showSuccess("Updated successfully");
                          })
                        : _orderServices
                            .updateOrderStatus(documentId, status)
                            .then((value) {
                            _notificationServices.sendPushMessage(
                                _customer['deviceToken'],
                                "Your order is $status",
                                "Tap here to know more");
                            EasyLoading.showSuccess("Updated successfully");
                          });
                    Navigator.pop(context);
                  },
                  child: SmallText(
                    text: "OK",
                    color: Theme.of(context).primaryColor,
                    weight: FontWeight.bold,
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: SmallText(
                      text: "Cancel",
                      color: Theme.of(context).primaryColor,
                      weight: FontWeight.bold))
            ],
          );
        });
  }

  Icon? statusIcon(DocumentSnapshot document) {
    if (document['orderStatus'] == 'Accepted') {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(document),
      );
    }

    if (document['orderStatus'] == 'Picked Up') {
      return Icon(
        Icons.cases,
        color: statusColor(document),
      );
    }

    if (document['orderStatus'] == 'On the Way') {
      return Icon(
        Icons.delivery_dining,
        color: statusColor(document),
      );
    }

    if (document['orderStatus'] == 'Delivered') {
      return Icon(
        Icons.shopping_bag_outlined,
        color: statusColor(document),
      );
    }

    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColor(document),
    );
  }

  Widget statusContainer(DocumentSnapshot document, context) {
    if (document['deliveryPartner']['name'].length > 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          leading: Icon(Icons.person_outlined),
          title: SmallText(text: document['deliveryPartner']['name']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  GeoPoint location = document['deliveryPartner']['location'];
                  _orderServices.launchMap(
                      location, document['deliveryPartner']['name']);
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8, top: 2, bottom: 2),
                      child: Icon(
                        Icons.map,
                        color: Colors.white,
                      ),
                    )),
              ),
              SizedBox(
                width: Dimensions.width10,
              ),
              InkWell(
                onTap: () {
                  _orderServices.launchCall(
                      'tel:${document['deliveryPartner']['phone']}');
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8, top: 2, bottom: 2),
                      child: Icon(
                        Icons.phone_in_talk,
                        color: Colors.white,
                      ),
                    )),
              ),
            ],
          ),
        ),
      );
    }
    if (document['orderStatus'] == 'Accepted') {
      return Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[500],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8.0, 40, 8),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeliveryPartnerList(
                        document: document,
                      );
                    });
              },
              child: SmallText(
                text: "Select Delivery Boy",
                color: Colors.white,
              )),
        ),
      );
    }

    return Container(
      height: 50,
      color: Colors.grey[500],
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                  onPressed: () {
                    showMyDialog(
                        "Accept Order", "Accepted", document.id, context);
                  },
                  child: SmallText(
                    text: "Accept",
                    color: Colors.white,
                  )),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AbsorbPointer(
                absorbing: document['orderStatus'] == 'Rejected' ? true : false,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: document['orderStatus'] == 'Rejected'
                            ? Colors.grey
                            : Colors.red),
                    onPressed: () {
                      showMyDialog(
                          "Reject Order", "Rejected", document.id, context);
                    },
                    child: SmallText(
                      text: "Reject",
                      color: Colors.white,
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  late DocumentSnapshot _customer;

  @override
  void initState() {
    _firebaseServices
        .getCustomerDetails(widget.document['userId'])
        .then((value) {
      if (value != null) {
        setState(() {
          this._customer = value;
        });
      } else {}
    });
    super.initState();
  }

  Color? statusColor(DocumentSnapshot document) {
    if (document['orderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    }

    if (document['orderStatus'] == 'Rejected') {
      return Colors.red;
    }

    if (document['orderStatus'] == 'Picked Up') {
      return Colors.pink[900];
    }

    if (document['orderStatus'] == 'On the Way') {
      return Colors.deepPurpleAccent;
    }

    if (document['orderStatus'] == 'Delivered') {
      return Colors.green;
    }

    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Container(
        color: Colors.white,
        child: Column(children: [
          ListTile(
            horizontalTitleGap: 0,
            leading:
                CircleAvatar(radius: 14, child: statusIcon(widget.document)),
            title: SmallText(
              text: widget.document['orderStatus'],
              weight: FontWeight.bold,
              color: statusColor(widget.document),
            ),
            trailing: SmallText(
                weight: FontWeight.bold,
                text:
                    "Amount : \$${widget.document['total'].toStringAsFixed(0)}"),
            subtitle: SmallText(
                text:
                    "On ${DateFormat.yMMMd().format(widget.document['timestamp'])}"),
          ),
          _customer != null
              ? ListTile(
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  title: Row(
                    children: [
                      SmallText(text: "Customer : "),
                      SmallText(
                        text: '${_customer['name']}',
                        maxLines: 1,
                        overFlow: TextOverflow.ellipsis,
                        weight: FontWeight.bold,
                      ),
                    ],
                  ),
                  subtitle: SmallText(
                    text: _customer['address'],
                    maxLines: 1,
                  ),
                  trailing: InkWell(
                    onTap: () {
                      _orderServices.launchCall('tel:${_customer['number']}');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8, top: 2, bottom: 2),
                          child: Icon(
                            Icons.phone_in_talk,
                            color: Colors.white,
                          ),
                        )),
                  ),
                )
              : Container(),
          ExpansionTile(
            title: SmallText(
              text: "Order details",
              size: 10,
              color: Colors.black,
            ),
            subtitle: SmallText(
              text: "View Order details",
              color: Colors.grey,
            ),
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.document['products'].length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.network(
                            widget.document['products'][index]['productImage']),
                      ),
                      title: Column(
                        children: [
                          SmallText(
                              text: widget.document['products'][index]
                                  ['productName']),
                          SizedBox(height: Dimensions.height10),
                          if (widget.document['products'][index]['itemSize'] !=
                              null)
                            SmallText(
                                text: widget.document['products'][index]
                                    ['itemSize']),
                          if ((widget.document['products'][index]['toppings']
                                  as List)
                              .isNotEmpty)
                            Column(
                              children: widget.document['products'][index]
                                      ['toppings']
                                  .map((context, topping) {
                                return SmallText(text: topping['name']);
                              }).toList(),
                            )
                        ],
                      ),
                      subtitle: SmallText(
                          color: Colors.grey,
                          text:
                              '${widget.document['products'][index]['qty']} x \$${widget.document['products'][index]['price'].toStringAsFixed(0)} = \$${widget.document['products'][index]['total'].toStringAsFixed(0)}'),
                    );
                  }),
            ],
          ),
          Divider(
            height: 3,
            color: Colors.grey,
          ),
          statusContainer(widget.document, context),
          Divider(
            height: 3,
            color: Colors.grey,
          )
        ]),
      ),
    );
    ;
  }
}
