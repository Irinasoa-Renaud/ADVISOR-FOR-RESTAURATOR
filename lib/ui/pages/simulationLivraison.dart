import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:menu_advisor/utils/dependences.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:menu_advisor/models/restaurant.dart';

import 'package:http/http.dart' as http;

class SimulationLivraisonPage extends StatefulWidget {
  const SimulationLivraisonPage({Key? key}) : super(key: key);

  @override
  _SimulationLivraisonPageState createState() =>
      _SimulationLivraisonPageState();
}

class _SimulationLivraisonPageState extends State<SimulationLivraisonPage> {
  String googleApiKey = "AIzaSyCL8_ZHnuPxDiElzyy4CCZEbJBv4ankXVc";

  LatLng startLocation = const LatLng(27.6683619, 85.3101895);
  LatLng endLocation = const LatLng(27.6875436, 85.4);

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {};

  PolylinePoints polylinePoints = PolylinePoints();

  double distance = 0.0;

  double prix = 0.0;

  double prixLivraison = 0.0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<Restaurant> restos = [];
  late GoogleMapController mapController;

  LatLng _center = const LatLng(-19.8653361, 47.0276761);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  bool calculProcessing = false;

  bool sansPrix = false;
  bool cm = false;
  int? resto;
  int? destination;

  String aToken = "", rToken = "";

  String user_id = "";

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      debugPrint('$logTrace ${result.errorMessage}');
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    print(totalDistance);

    setState(() {
      distance = totalDistance;
      prix = distance * restos[resto!].deliveryPrice.amount;
      calculProcessing = false;
      if (distance > 0.0) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                    "Le restaurant ne peut pas faire de livraison à cette ville distance maximal est ${restos[resto!].distanceMax} Km"),
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
    });

    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: UIData.colorPrincipal,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _calculer() {
    setState(() {
      mapController;
      _center = startLocation;
      calculProcessing = true;
    });
    setState(() {
      if (resto != null) {
        _center = LatLng(restos[resto!].location.coordinates[0],
            restos[resto!].location.coordinates[1]);
      }
      markers.clear();
      markers.add(Marker(
        //add start location marker
        markerId: MarkerId(startLocation.toString()),
        position: startLocation, //position of marker
        infoWindow: const InfoWindow(
          //popup info
          title: 'Starting Point ',
          snippet: 'Start Marker',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker(
        //add distination location marker
        markerId: MarkerId(endLocation.toString()),
        position: endLocation, //position of marker
        infoWindow: const InfoWindow(
          //popup info
          title: 'Destination Point ',
          snippet: 'Destination Marker',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
    });
    getDirections();
  }

  _restoDropDown() {
    return DropdownButtonFormField(
        hint: Text(restos.isNotEmpty ? "Restaurant" : "Chargement..."),
        decoration: const InputDecoration(border: OutlineInputBorder()),
        value: resto,
        items: restos.isNotEmpty
            ? restos
                .asMap()
                .map((index, r) => MapEntry(
                      index,
                      DropdownMenuItem(
                        child: Text(
                          r.name_resto_code,
                          style: TextData.textStyle1,
                        ),
                        value: index,
                      ),
                    ))
                .values
                .toList()
            : null,
        onChanged: (value) {
          setState(() {
            resto = value as int?;
          });
          debugPrint("$logTrace $value");
        });
  }

  Future<List<Restaurant>> getRestaurants() async {
    debugPrint("$logTrace getResto()");
    List<Restaurant> restaurants = [];
    var url = Uri.parse(Api.restaurants + "?admin=$user_id");
    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      for (var i in jsonData) {
        Restaurant resto = Restaurant.fromJson(i);
        // debugPrint('$logTrace resto ${resto.minPriceIsDelivery.toString()}');
        restaurants.add(resto);
      }
      setState(() {
        restos = restaurants;
      });
      // debugPrint('$logTrace erreur ${restaurants.last.category}');
      return restaurants;
    } catch (e) {
      debugPrint('$logTrace erreur $e');
      return restaurants;
    }
  }

  @override
  void initState() {
    AccessTokenData.loadToken().then((value) {
      debugPrint("$logTrace tokenLoaded $value");
      setState(() {
        aToken = value;
      });

      RefreshTokenData.loadToken().then((value) {
        debugPrint("$logTrace tokenLoaded $value");
        setState(() {
          rToken = value;
        });
      });
    });

    UserData.loadUser().then((value) {
      User user = User.fromJson(json.decode(value)['user']);
      setState(() {
        user_id = user.id;
      });
      getRestaurants();
    });

    super.initState();
  }

  statee() {
    setState(() {
      endLocation = const LatLng(27.6575536, 85.30208500);
    });
  }

  @override
  Widget build(BuildContext context) {
    statee();
    return WillPopScope(
      onWillPop: () {
        throw Navigator.pushNamed(context, RoutePage.commandesPage);
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 9),
        appBar: MyAppBar(
            selection: 0,
            callback: () {
              getRestaurants();
            }),
        // ignore: unnecessary_const
        body: ListView(
          children: [
            Card(
                child: Row(
              children: [
                const SizedBox(
                  height: 100,
                  child: SizedBox(
                    width: 100,
                    child: Card(
                      margin: EdgeInsets.all(15),
                      elevation: 10,
                      child: Icon(
                        FontAwesomeIcons.truck,
                        size: 30,
                        color: UIData.logoTitleColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      "Simulation Livraison",
                      style: TextData.titlePageStyle,
                    ),
                    Text("Simulation de livraison",
                        style: TextData.subtitlePageStyle)
                  ],
                )
              ],
            )),
            Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Restaurant",
                      style: TextData.textStyle1,
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child:
                          // restos.isEmpty
                          //     ? TextFormField(
                          //         enabled: false,
                          //         initialValue: "Chargement...",
                          //         decoration: const InputDecoration(
                          //             border: OutlineInputBorder(),
                          //             suffixIcon: Icon(Icons.abc)),
                          //       )
                          //     :
                          _restoDropDown()),
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Destination",
                      style: TextData.textStyle1,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: GestureDetector(
                      onTap: () {
                        debugPrint("$logTrace dest");
                      },
                      child: DropdownButtonFormField(
                          hint: const Text("Destination"),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          value: destination,
                          items: null,
                          onChanged: (value) {
                            setState(() {
                              destination = value as int?;
                            });
                          }),
                    ),
                  ),
                  (resto != null
                      //  && destination != null
                      )
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: ElevatedButton(
                            child: const Text("CALCULER"),
                            style: ElevatedButton.styleFrom(
                                primary: UIData.btnAlert),
                            onPressed: () {
                              _calculer();
                            },
                          ),
                        )
                      : Container(),
                  if (calculProcessing)
                    Center(
                      child: Container(
                          margin: const EdgeInsets.all(10),
                          child: const CircularProgressIndicator()),
                    ),
                  !calculProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox.square(
                              dimension: 120,
                              child: Card(
                                  elevation: 10,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        const Icon(Icons.map),
                                        Text(
                                          distance.toStringAsFixed(2) + " KM",
                                          style: TextData.textStyle1,
                                        )
                                      ])),
                            ),
                            SizedBox.square(
                              dimension: 120,
                              child: Card(
                                  elevation: 10,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(Icons.euro),
                                        Text(
                                          prix.toString(),
                                          style: TextData.textStyle1,
                                        )
                                      ])),
                            ),
                          ],
                        )
                      : Container(),
                  !calculProcessing
                      ? Card(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          elevation: 5,
                          child: SizedBox(
                            height: 40,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: const [
                                  Icon(FontAwesomeIcons.stopwatch),
                                  Text("")
                                ]),
                          ),
                        )
                      : Container(),
                  SizedBox.square(
                    dimension: MediaQuery.of(context).size.width - 60,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                      child: Center(
                        child:
                            // Column(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: const [
                            //       Text(
                            //         "Map",
                            //         style: TextData.textStyle1,
                            //       ),
                            //       Icon(
                            //         Icons.map_outlined,
                            //         size: 50,
                            //       )
                            //     ])
                            GoogleMap(
                          mapToolbarEnabled: true,
                          trafficEnabled: true,
                          onMapCreated: _onMapCreated,
                          markers: markers,
                          polylines: Set<Polyline>.of(polylines.values),
                          initialCameraPosition: CameraPosition(
                            target: startLocation,
                            zoom: 11.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
      ),
    );
  }
}
