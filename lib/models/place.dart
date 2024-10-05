import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  PlaceLocation(
      {required this.address, required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
  final String address;
}

class Place {
  Place(
      {required this.title,
      required this.image,
      required this.placeLocation,
      required this.capturedImage})
      : id = uuid.v4();
  final String title;
  final String id;
  final File image;
  final PlaceLocation placeLocation;
  final Uint8List capturedImage;
}
