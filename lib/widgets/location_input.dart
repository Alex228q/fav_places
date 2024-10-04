import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  final MapController _mapController = MapController();
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
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
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
    if (_isMapInitialized) {
      _mapController.move(LatLng(_lat!, _lng!), 16);
    }
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
      previewContent = FlutterMap(
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
