import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:pizza_store_vendor/services/firebase_services.dart';
import 'package:pizza_store_vendor/services/order_services.dart';
import 'package:pizza_store_vendor/widgets/small_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/notification_services.dart';

class DeliveryPartnerList extends StatefulWidget {
  DocumentSnapshot document;
  DeliveryPartnerList({super.key, required this.document});

  @override
  State<DeliveryPartnerList> createState() => _DeliveryPartnerListState();
}

class _DeliveryPartnerListState extends State<DeliveryPartnerList> {
  FirebaseServices _firebaseServices = FirebaseServices();
  OrderServices _orderServices = OrderServices();
  NotificationServices _notificationServices = NotificationServices();
  late GeoPoint _shopLocation;

  @override
  void initState() {
    _firebaseServices.getShopDetails().then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            _shopLocation = value['location'];
          });
        }
      } else {
        print("No data");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: SmallText(
                text: "Select Delivery Partner",
                color: Colors.white,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            Container(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firebaseServices.deliveryPartners.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: SmallText(text: "Something went wrong.."),
                        );
                      }

                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          GeoPoint location = document['location'];
                          double distanceInKiloMeters = _shopLocation == null
                              ? 0.0
                              : Geolocator.distanceBetween(
                                      _shopLocation.latitude,
                                      _shopLocation.longitude,
                                      location.latitude,
                                      location.longitude) /
                                  1000;
                          if (distanceInKiloMeters > 10) {
                            return Container();
                          }
                          return Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  EasyLoading.show(
                                      status: "Assigning delivery partner");
                                  _firebaseServices
                                      .selectDeliveryPartners(
                                          widget.document.id,
                                          document['location'],
                                          document['name'],
                                          document['mobile'])
                                      .then((value) {
                                    _notificationServices.sendPushMessage(
                                        document['deviceToken'],
                                        "New order assigned",
                                        "Tap here to know more");
                                    EasyLoading.showSuccess(
                                        "Delivery partner assigned");
                                    Navigator.pop(context);
                                  });
                                },
                                leading: Icon(Icons.person_outlined),
                                title: SmallText(text: document['name']),
                                subtitle: SmallText(
                                    text:
                                        "${distanceInKiloMeters.toStringAsFixed(0)} Km"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          GeoPoint location =
                                              document['location'];
                                          _orderServices.launchMap(
                                              location, document['name']);
                                        },
                                        icon: Icon(
                                          Icons.map,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          _orderServices.launchCall(
                                              'tel:${document['mobile']}');
                                        },
                                        icon: Icon(Icons.phone,
                                            color:
                                                Theme.of(context).primaryColor))
                                  ],
                                ),
                              ),
                              Divider(
                                height: 2,
                                color: Colors.grey,
                              )
                            ],
                          );
                        }).toList(),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
