import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as myPolyline;
import 'package:menu_advisor/ui/pages.dart';

class MapFullScreen extends StatefulWidget {
  const MapFullScreen({Key? key}) : super(key: key);

  @override
  State<MapFullScreen> createState() => _MapFullScreenState();
}

class _MapFullScreenState extends State<MapFullScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {};

  myPolyline.PolylinePoints polylinePoints = myPolyline.PolylinePoints();

  LatLng start = const LatLng(48.866667, 2.333333);
  LatLng end = const LatLng(48.866667, 2.333333);

  String originAddres = "";
  String destinationAddres = "";
  MapType _mapType = MapType.normal;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        MapArgs args = ModalRoute.of(context)!.settings.arguments as MapArgs;
        start = args._origin;
        end = args._destination;

        originAddres = args._originAddres;
        destinationAddres = args._destinationAddres;

        markers.add(Marker(
          //add start location marker
          markerId: MarkerId(start.toString()),
          position: start, //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: originAddres,
            snippet: 'A',
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));

        markers.add(Marker(
          //add distination location marker
          markerId: MarkerId(end.toString()),
          position: end, //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: destinationAddres,
            snippet: 'B',
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));

        getDirections(start, end, args.googleApiKey);
      });
    });
    super.initState();
  }

  getDirections(LatLng start, LatLng end, String apiKey) async {
    List<LatLng> polylineCoordinates = [];

    myPolyline.PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      myPolyline.PointLatLng(start.latitude, start.longitude),
      myPolyline.PointLatLng(end.latitude, end.longitude),
      travelMode: myPolyline.TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((myPolyline.PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      debugPrint('$logTrace ${result.errorMessage}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("Une erreur est survenue",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          });
    }

    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromARGB(150, 68, 137, 255),
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {
      mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 270.0,
            target: start,
            tilt: 30.0,
            zoom: 17.0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        GoogleMap(
          mapType: _mapType,
          compassEnabled: true,
          mapToolbarEnabled: true,
          trafficEnabled: true,
          onMapCreated: _onMapCreated,
          markers: markers,
          polylines: Set<Polyline>.of(polylines.values),
          initialCameraPosition: CameraPosition(
            target: start,
            zoom: 11.0,
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: SizedBox.square(
            dimension: 60,
            child: Card(
                color: const Color.fromARGB(216, 255, 254, 254),
                child: GestureDetector(
                  child: const Icon(
                    Icons.fullscreen_exit,
                    color: Colors.grey,
                    size: 50,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )),
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: SizedBox(
            height: 60,
            width: 120,
            child: Card(
                color: const Color.fromARGB(216, 255, 254, 254),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map,
                      color: Colors.grey,
                    ),
                    const Text(
                      "Type",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    PopupMenuButton(
                        icon: const Icon(
                          Icons.sort,
                          color: Colors.grey,
                        ),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  _mapType = MapType.normal;
                                });
                              },
                              child: const Text('Normal'),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  _mapType = MapType.satellite;
                                });
                              },
                              child: const Text('Satellite'),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  _mapType = MapType.terrain;
                                });
                              },
                              child: const Text('Terrain'),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  _mapType = MapType.hybrid;
                                });
                              },
                              child: const Text('Hybrid'),
                            ),
                          ];
                        })
                  ],
                )),
          ),
        ),
      ]),
    );
  }
}

class MapArgs {
  final LatLng _center;
  final LatLng _origin;
  final LatLng _destination;
  final String _originAddres;

  final String _destinationAddres;
  final String googleApiKey;
  MapArgs(this._center, this._origin, this._destination, this._originAddres,
      this._destinationAddres, this.googleApiKey);
}
