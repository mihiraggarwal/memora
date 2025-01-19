import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationBtn extends StatefulWidget {
  LocationBtn({Key? key}) : super(key: key);

  static final id = 'location';

  double lat = 0;
  double lon = 0;

  @override
  _LocationBtnState createState() => _LocationBtnState();
}

class _LocationBtnState extends State<LocationBtn> {

  final mapKey = dotenv.env["MAPS_KEY"];
  bool dataLoaded = false;

  @override
  Widget build(BuildContext context) {

    // int tilesize = 256;
    // int zoom = 15;

    if (!dataLoaded) {
      getLocation().then((location) {
        location.getLocation().then((currentLocation) {
          if (mounted) {
            setState(() {
              widget.lat = currentLocation.latitude!;
              widget.lon = currentLocation.longitude!;
              dataLoaded = true;
            });
          }
        });

        location.onLocationChanged.listen((LocationData newLocation) {
          if (mounted) {
            setState(() {
              widget.lat = newLocation.latitude!;
              widget.lon = newLocation.longitude!;
            });
          }
        });
      });
    }

    // double sinLatitude = sin(widget.lat * pi/180);
    // int x = (((widget.lon + 180) / 360) * tilesize * pow(2, zoom) / tilesize).floor();
    // int y = ((0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * pi)) * tilesize * pow(2, zoom) / tilesize).floor();

    if (dataLoaded) {
      return Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                  initialCenter: LatLng(widget.lat, widget.lon),
                  initialZoom: 15
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // urlTemplate: 'https://atlas.microsoft.com/map/tile?subscription-key=$mapKey&api-version=2024-04-01&tilesetId=microsoft.base.road&zoom=$zoom&x=$x&y=$y',
                  userAgentPackageName: 'com.example.app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                        point: LatLng(widget.lat, widget.lon),
                        radius: 30,
                        useRadiusInMeter: true
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      );
    } else {
      return const Scaffold(
        body: Center(
          child: Text(
            "Loading..."
          ),
        ),
      );
    }
  }
}

Future<Location> getLocation() async {
  Location location = Location();
  bool servicesEnabled = await location.serviceEnabled();

  if (!servicesEnabled) {
    servicesEnabled = await location.requestService();

    // if (!servicesEnabled) return;

  }

  var permissionGranted = await location.hasPermission();

  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();

    // if (permissionGranted != PermissionStatus.granted) return;

  }

  // await location.enableBackgroundMode(enable: true);
  //
  // bool bgEnabled = await location.isBackgroundModeEnabled();
  // if (!bgEnabled) {
  //   await location.enableBackgroundMode(enable: true);
  // }

  return location;
}