import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderServices {
  CollectionReference order = FirebaseFirestore.instance.collection('orders');

  Future<void> updateOrderStatus(docId, status) {
    var result = order.doc(docId).update({"orderStatus": status});
    return result;
  }

  void launchCall(number) async {
    await canLaunchUrl(number)
        ? await launchUrl(number)
        : throw "Could not launch $number";
  }

  void launchMap(GeoPoint location, name) async {
    final availableMaps = await MapLauncher.installedMaps;
    print(
        availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

    await availableMaps.first.showMarker(
      coords: Coords(location.latitude, location.longitude),
      title: name,
    );
  }
}
