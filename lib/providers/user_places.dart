import 'dart:io';
import 'dart:typed_data';

import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPlacesNotifire extends StateNotifier<List<Place>> {
  UserPlacesNotifire() : super(const []);

  void addPlace(String title, File image, PlaceLocation placeLocation,
      Uint8List capturesImage) {
    final newPlace = Place(
        title: title,
        image: image,
        placeLocation: placeLocation,
        capturedImage: capturesImage);
    state = [...state, newPlace];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifire, List<Place>>((ref) {
  return UserPlacesNotifire();
});
