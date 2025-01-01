import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationBtn extends StatefulWidget {
  LocationBtn({Key? key}) : super(key: key);

  double lat = 0;
  double lon = 0;

  @override
  _LocationBtnState createState() => _LocationBtnState();
}

class _LocationBtnState extends State<LocationBtn> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 50.0),
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                )
            ),
            onPressed: () async {
              var location = await getLocation();
              var currentLocation = await location.getLocation();
              setState(() {
                widget.lat = currentLocation.latitude!;
                widget.lon = currentLocation.longitude!;
              });

              location.onLocationChanged.listen((LocationData newLocation) {
                setState(() {
                  widget.lat = newLocation.latitude!;
                  widget.lon = newLocation.longitude!;
                });
              });
            },
            child: const Text(
                "Get Location"
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.lat.toString()),
            Text(widget.lon.toString())
          ],
        )
      ],
    );
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

  location.enableBackgroundMode(enable: true);

  return location;
}