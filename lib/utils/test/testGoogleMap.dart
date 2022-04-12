import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyGoogleMapApp());

class MyGoogleMapApp extends StatefulWidget {
  const MyGoogleMapApp({Key? key}) : super(key: key);

  @override
  _MyGoogleMapAppState createState() => _MyGoogleMapAppState();
}

class _MyGoogleMapAppState extends State<MyGoogleMapApp> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(-19.8653361, 47.0276761);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}
