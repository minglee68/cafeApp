import 'dart:async';
import 'detail.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey = "AIzaSyCWiFLiauFZv-cMSqXX_f4mRTn9rYd6ssw";

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _mapController;
  String thisName;
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  Set<Marker> _markers = Set<Marker>();
  bool done = false;

  @override
  void initState(){
    _markers.add(
        Marker(
          markerId: MarkerId('marking location'),
          position: center,
        )
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    print(cafeName);
    print(cafeAddr);
    //_searchPlace();
    print("outside of if state");
    print(center.latitude);
    print(center.longitude);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon : Icon(Icons.arrow_back),
            onPressed: Navigator.of(context).pop
          ),
          title: Text('Maps'),
          backgroundColor: Colors.brown,
        ),
        body: GoogleMap(
          markers: _markers,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: center,
            zoom: 16.0,
          ),

          /*
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 17.0,
          ),
          */

        ),
      ),
    );
  }
}