import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  PlaceLocation(this.address,
      {required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
  final String address;
}

class Place {
  Place({required this.title, required this.image}) : id = uuid.v4();
  final String title;
  final String id;
  final File image;
}
