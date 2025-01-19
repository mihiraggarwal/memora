import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import "package:http/http.dart" as http;

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

  double home_lat = 0;
  double home_lon = 0;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List> getHome() async {
    final uid = auth.currentUser?.uid;
    String address = '';

    await firestore.collection("users").where("uid", isEqualTo: uid).limit(1).get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        address = doc["address"];
      }
    });

    final url = 'https://atlas.microsoft.com/geocode?api-version=2023-06-01&query=$address&top=1&subscription-key=$mapKey';
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

    return data["features"][0]["geometry"]["coordinates"];
  }

  @override
  Widget build(BuildContext context) {

    if (!dataLoaded) {
      getLocation().then((location) {
        location.getLocation().then((currentLocation) {
          if (mounted) {
            setState(() {
              widget.lat = currentLocation.latitude!;
              widget.lon = currentLocation.longitude!;

              getHome().then((location) {
                if (mounted) {
                  setState(() {
                    home_lon = location[0]!;
                    home_lat = location[1]!;
                    dataLoaded = true;

                  });
                }
              });
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
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(home_lat, home_lon),
                      child: Icon(Icons.home),
                      height: 60,
                      width: 60
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