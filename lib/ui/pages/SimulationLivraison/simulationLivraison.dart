import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as myPolyline;
import 'package:menu_advisor/ui/pages/SimulationLivraison/mapFullScreen.dart';
import 'package:menu_advisor/utils/dependences.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:menu_advisor/models/restaurant.dart';

import 'package:google_directions_api/google_directions_api.dart'
    as googleDirApi;

import 'package:http/http.dart' as http;

class SimulationLivraisonPage extends StatefulWidget {
  const SimulationLivraisonPage({Key? key}) : super(key: key);

  @override
  _SimulationLivraisonPageState createState() =>
      _SimulationLivraisonPageState();
}

class _SimulationLivraisonPageState extends State<SimulationLivraisonPage> {
  String googleApiKey = "AIzaSyCL8_ZHnuPxDiElzyy4CCZEbJBv4ankXVc";

  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  LatLng startLocation = const LatLng(48.866667, 2.333333);
  LatLng endLocation = const LatLng(48.866667, 2.333333);

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {};

  myPolyline.PolylinePoints polylinePoints = myPolyline.PolylinePoints();

  double distance = 0.0;

  String distanceText = "";

  double prix = 0.0;

  List<Restaurant> restos = [];
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  bool destinationSelected = false;

  bool calculProcessing = false;

  bool sansPrix = false;
  bool cm = false;
  int? resto;

  String aToken = "", rToken = "";

  String user_id = "";

  String selectedPlace = "";

  String travelTime = "";

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getDirections(LatLng start, LatLng end) async {
    List<LatLng> polylineCoordinates = [];

    myPolyline.PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
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

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    debugPrint("$logTrace TotalDistance:$totalDistance");
    debugPrint(
        "$logTrace DistanceMax:${double.parse(restos[resto!].distanceMax)}");

    setState(() {
      distance = totalDistance;
      // prix = distance * restos[resto!].priceByMiles;
      calculProcessing = false;
      debugPrint(
          "$logTrace comparaison: ${distance > double.parse(restos[resto!].distanceMax)}");
      if (distance > double.parse(restos[resto!].distanceMax)) {
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
      color: Color.fromARGB(150, 68, 137, 255),
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _calculer(LatLng origin, LatLng destination) {
    _calculTime(origin, destination);
    setState(() {
      calculProcessing = true;
      mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 270.0,
            target: origin,
            tilt: 30.0,
            zoom: 11.0,
          ),
        ),
      );
    });

    setState(() {
      markers.clear();
      markers.add(Marker(
        //add start location marker
        markerId: MarkerId(origin.toString()),
        position: origin, //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: restos[resto!].name_resto_code,
          snippet: 'A',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker(
        //add distination location marker
        markerId: MarkerId(endLocation.toString()),
        position: destination, //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: selectedPlace,
          snippet: 'B',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
    });
    getDirections(origin, destination);
  }

  void onError(PlacesAutocompleteResponse response) {
    MyToast.showAlert(response.errorMessage.toString());
  }

  Future<void> _getDestination() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: googleApiKey,
      onError: onError,
      mode: Mode.overlay,
      language: "fr",
      types: [],
      strictbounds: false,
      // region: "fr",
      radius: 1000,
      offset: 0,
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      // components: [Component(Component.country, "fr")],
      components: [],
    );

    displayPrediction(p, homeScaffoldKey.currentState!);
  }

  Future<Null> displayPrediction(Prediction? p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: googleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      MyToast.showSuccess("${p.description}");
      //  - $lat/$lng");
      setState(() {
        selectedPlace = "${p.description}";

        if (selectedPlace.length > 24) {
          setState(() {
            String val = "";
            for (var i = 0; i < 24; i++) {
              val += selectedPlace.characters.elementAt(i);
            }
            selectedPlace = val + "...";
          });
        }

        distanceText = "";
        prix = 0;
        travelTime = "";

        endLocation = LatLng(lat, lng);
        destinationSelected = true;
      });
    } else {
      MyToast.showAlert("Aucune Adresse selectionné");
    }
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

  _calculTime(LatLng start, LatLng end) {
    googleDirApi.DirectionsService.init(googleApiKey);

    final directionsService = googleDirApi.DirectionsService();

    var request = googleDirApi.DirectionsRequest(
      origin: googleDirApi.GeoCoord(start.latitude, start.longitude),
      destination: googleDirApi.GeoCoord(end.latitude, end.longitude),
      travelMode: googleDirApi.TravelMode.driving,
    );

    directionsService.route(request, (googleDirApi.DirectionsResult response,
        googleDirApi.DirectionsStatus? status) {
      if (status == googleDirApi.DirectionsStatus.ok) {
        // do something with successful response
        debugPrint(
            "$logTrace success: ${response.routes![0].legs![0].duration!.text}");
        setState(() {
          travelTime = response.routes![0].legs![0].duration!.text ?? "";
          prix = ((response.routes![0].legs![0].distance!.value!) / 1000) *
              double.parse(restos[resto!].priceByMiles.toString());
          debugPrint(
              "$logTrace ${response.routes![0].legs![0].distance!.value}-${restos[resto!].distanceMax}");
          distanceText = response.routes![0].legs![0].distance!.text ?? "";
        });

        if (((response.routes![0].legs![0].distance!.value!) / 1000) >
            double.parse(restos[resto!].distanceMax)) {
          setState(() {
            prix = 0.0;
            travelTime = "0";
          });
        }
      } else {
        // do something with error response
        debugPrint("$logTrace error");
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        throw Navigator.pushNamed(context, RoutePage.commandesPage);
      },
      child: Scaffold(
        key: homeScaffoldKey,
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 9),
        appBar: MyAppBar(
            selection: 0,
            callback: () {
              getRestaurants();
            }),
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
                        _getDestination().then((value) {
                          // if (selectedPlace.length > 20) {
                          //   setState(() {
                          //     String val = "";
                          //     for (var i = 0; i < 20; i++) {
                          //       val += selectedPlace.characters.elementAt(i);
                          //     }
                          //     selectedPlace = val + "...";
                          //   });
                          // }
                        });
                        debugPrint("$logTrace dest");
                      },
                      child: DropdownButtonFormField(
                          hint: Text(
                            selectedPlace != "" ? selectedPlace : "Adresse",
                          ),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          value: 0,
                          items: null,
                          onChanged: (value) {
                            //   setState(() {
                            //     destination = value as int?;
                            //   });
                          }),
                    ),
                  ),
                  (resto != null && destinationSelected)
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: ElevatedButton(
                            child: const Text("CALCULER"),
                            style: ElevatedButton.styleFrom(
                                primary: UIData.btnAlert),
                            onPressed: () {
                              setState(() {
                                if (restos[resto!] != null) {
                                  double restoLat =
                                      restos[resto!].location.coordinates[1];
                                  double restoLng =
                                      restos[resto!].location.coordinates[0];
                                  debugPrint(
                                      "$logTrace resto:($restoLat,:$restoLng)-dest:($endLocation)");
                                  LatLng restoLoc = LatLng(restoLat, restoLng);
                                  startLocation = restoLoc;
                                }
                              });
                              _calculer(startLocation, endLocation);
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
                                          // distance.toStringAsFixed(2) + " KM",
                                          distanceText,
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
                                          prix.toStringAsFixed(2),
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
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(FontAwesomeIcons.stopwatch),
                                  Text(travelTime)
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
                        child: Stack(
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
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
                            Positioned(
                              top: 10,
                              right: 10,
                              child: SizedBox.square(
                                dimension: 60,
                                child: Card(
                                    color: const Color.fromARGB(
                                        216, 255, 254, 254),
                                    child: GestureDetector(
                                      child: const Icon(
                                        Icons.fullscreen,
                                        color: Colors.grey,
                                        size: 50,
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            RoutePage.mapFullScreenPage,
                                            arguments: MapArgs(
                                                startLocation,
                                                startLocation,
                                                endLocation,
                                                restos[resto!].name_resto_code,
                                                selectedPlace,
                                                googleApiKey));
                                      },
                                    )),
                              ),
                            ),
                          ],
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
        // floatingActionButton: const MyFloatingActionButton(),
      ),
    );
  }
}
