import 'dart:typed_data';
import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location_package;
import 'package:screenshot/screenshot.dart';

class LocationInput extends StatefulWidget {
  const LocationInput(
      {super.key, required this.onPickLocation, required this.onCaptureImage});

  final void Function(PlaceLocation placeLocation) onPickLocation;
  final void Function(Uint8List capturedImage) onCaptureImage;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? placeLocation;
  Uint8List? image;
  final MapController _mapController = MapController();
  final ScreenshotController _screenshotController = ScreenshotController();

  var _isGettingLocation = false;
  double? _lat;
  double? _lng;
  bool _isMapInitialized = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    location_package.Location location = location_package.Location();
    bool serviceEnabled;
    location_package.PermissionStatus permissionGranted;
    location_package.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == location_package.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != location_package.PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();

    setState(() {
      _isGettingLocation = false;
    });
    _lat = locationData.latitude;
    _lng = locationData.longitude;
    List<Placemark> placemarks = await placemarkFromCoordinates(_lat!, _lng!);
    placeLocation = PlaceLocation(
      address: "${placemarks[0].street}${placemarks[0].name}",
      latitude: _lat!,
      longitude: _lng!,
    );
    if (_isMapInitialized) {
      _mapController.move(LatLng(_lat!, _lng!), 16);
    }
    widget.onPickLocation(placeLocation!);

    Future.delayed(const Duration(milliseconds: 3000), () {
      _saveCapturedImage();
    });
  }

  void _saveCapturedImage() async {
    image = await _screenshotController.capture();
    widget.onCaptureImage(image!);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No Location chosen',
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onSurface),
    );

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }
    if (_lat != null && _lng != null) {
      previewContent = Screenshot(
        controller: _screenshotController,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
            initialCenter: LatLng(_lat!, _lng!),
            initialZoom: 16,
            onMapReady: () {
              _isMapInitialized = true;
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(_lat!, _lng!),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 30,
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              label: const Text('Get Current Location'),
              icon: const Icon(Icons.location_on),
            ),
            TextButton.icon(
              onPressed: () {},
              label: const Text('Select On Map'),
              icon: const Icon(Icons.map),
            ),
          ],
        ),
      ],
    );
  }
}
