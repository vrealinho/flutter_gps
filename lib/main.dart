import 'package:animated_rotation/animated_rotation.dart' as rotation;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bússola',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFFFFFFF)),
      home: const GeolocationExample(),
    );
  }
}

class GeolocationExample extends StatefulWidget {
  const GeolocationExample({Key? key}) : super(key: key);

  @override
  GeolocationExampleState createState() => GeolocationExampleState();
}

class GeolocationExampleState extends State {
  Position? _position;
  String? _location;

  @override
  void initState() {
    super.initState();

    Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high, distanceFilter: 1)
        .listen((Position position) async {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        _location = placemarks[0].locality;
      } else {
        _location = '';
      }
      setState(() {
        _position = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    LatLongConverter converter = LatLongConverter();

    String decimalToDms(double lat, double long) {
      var latDms = converter.getDegreeFromDecimal(lat);
      var longDms = converter.getDegreeFromDecimal(long);
      String l1 = 'N';
      String l2 = 'E';
      if (latDms[0] < 0) {
        latDms[0] = -latDms[0];
        l1 = 'S';
      }
      if (longDms[0] < 0) {
        longDms[0] = -longDms[0];
        l2 = 'W';
      }
      return "$l1 ${latDms[0]}° ${latDms[1]}' ${latDms[2].toStringAsPrecision(4)}\""
          "\n$l2 ${longDms[0]}° ${longDms[1]}' ${longDms[2].toStringAsPrecision(4)}\"";
    }

    String loc = decimalToDms(_position!.latitude, _position!.longitude);
    return Scaffold(
      body: Column(children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 60),
          child: Image(image: AssetImage('assets/seta.jpg'), height: 50),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 50),
          child: rotation.AnimatedRotation(
            angle: _position!.heading,
            child: const Image(image: AssetImage('assets/bussola1.jpg')),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(0.0),
            child: Text('${_position!.heading.toStringAsFixed(1)}º',
                style: const TextStyle(color: Colors.black54, fontSize: 20))),
        Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
            child: Text(loc,
                style: const TextStyle(color: Colors.black54, fontSize: 26))),
        Padding(
            padding: const EdgeInsets.all(0.0),
            child: Text('($_location)',
                style: const TextStyle(color: Colors.black54, fontSize: 20))),
        Expanded(
          child: Align(
            alignment: FractionalOffset.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.amber,
                    ),
                    width: MediaQuery.of(context).size.width * 0.42,
                    height: 95,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                              padding: EdgeInsets.fromLTRB(10.0, 10, 0, 0),
                              child: Text(
                                'Velocidade (m/s)',
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.white70),
                              )),
                          Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 10, 0, 0),
                              child: Text(
                                  '${_position?.speed.toStringAsFixed(1)}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 34))),
                        ]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.deepPurpleAccent,
                    ),
                    width: MediaQuery.of(context).size.width * 0.42,
                    height: 95,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                              padding: EdgeInsets.fromLTRB(10.0, 10, 0, 0),
                              child: Text(
                                'Precisão (m)',
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.white70),
                              )),
                          Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 10, 0, 0),
                              child: Text(
                                '${_position?.accuracy.toStringAsFixed(1)}',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 34),
                              )),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
