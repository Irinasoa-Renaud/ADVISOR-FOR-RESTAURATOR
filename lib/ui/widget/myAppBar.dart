import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/models/restaurant.dart';

import 'package:menu_advisor/utils/dependences.dart';
import 'package:http/http.dart' as http;

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int selection;
  final Function callback;

  const MyAppBar({Key? key, required this.selection, required this.callback})
      : super(key: key);

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _MyAppBarState extends State<MyAppBar> {
  String aToken = "", rToken = "";
  int _commandCount = 0;
  int _commandeSurPlace = 0;
  int _commandeAemporter = 0;
  int _commandeLivraison = 0;

  Future<int> getCommandesCount(int type, String restoId) async {
    var url;
    switch (type) {
      case 0:
        setState(() {
          // url = Uri.parse(Api.commandesCount);
          url = Uri.parse(Api.commandesCount +
              (restoId != ""
                  ? '?filter={"restaurant":"$restoId","validated":"false"}'
                  : '?filter={}'));
          // "?filter={}");
        });
        break;
      case 1:
        setState(() {
          // url = Uri.parse(Api.commandesCount +
          //     "?type=delivery");
          url = Uri.parse(Api.commandesCount +
              "?type=delivery" +
              (restoId != ""
                  ? '&filter={"restaurant":"$restoId","validated":"false"}'
                  : '&filter={}'));
        });
        break;
      case 2:
        setState(() {
          // url = Uri.parse(Api.commandesCount +
          //     "?type=takeaway");
          url = Uri.parse(Api.commandesCount +
              "?type=takeaway" +
              (restoId != ""
                  ? '&filter={"restaurant":"$restoId","validated":"false"}'
                  : '&filter={}'));
        });
        break;
      case 3:
        setState(() {
          // url = Uri.parse(Api.commandesCount +
          //     "?type=on_site");
          url = Uri.parse(Api.commandesCount +
              "?type=on_site" +
              (restoId != ""
                  ? '&filter={"restaurant":"$restoId","validated":"false"}'
                  : '&filter={}'));
        });
        break;
      default:
    }
    int count = 0;

    try {
      debugPrint("$logTrace $url");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data type:$type ${response.body.toString()}");
      setState(() {
        count = jsonData["count"];
        type == 0
            ? _commandCount = count
            : type == 1
                ? _commandeLivraison = count
                : type == 2
                    ? _commandeAemporter = count
                    : type == 3
                        ? _commandeSurPlace = count
                        : count = jsonData["count"];
      });

      return count;
    } catch (e) {
      debugPrint("$logTrace error $e");
      MyToast.showAlert("Erreur de chargement!");
      return 0;
    }
  }

  Future<void> _tryConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      setState(() {
        _isConnectionSuccessful = response.isNotEmpty;
      });
      debugPrint("$logTrace $response");
    } on SocketException catch (e) {
      debugPrint("$logTrace $e");
      setState(() {
        _isConnectionSuccessful = false;
      });
    }
  }

  ConnectivityResult? _connectivityResult;
  late StreamSubscription _connectivitySubscription;
  bool? _isConnectionSuccessful;
  String user_id = "";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // getter comandes couts quand l'utilisateur a reussi à se connecter
    AccessTokenData.loadToken().then((value) {
      UserData.loadUser().then((value) {
        User user = User.fromJson(json.decode(value)['user']);
        setState(() {
          user_id = user.id;
        });
        RestoData.loadResto().then((value) {
          Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
          getCommandesCount(0, resto.id).then((value) {
            int val = value;
            debugPrint("$logTrace commandes count: $value");
            setState(() {
              _commandCount = value;
            });
          });
          getCommandesCount(1, resto.id).then((value) {
            debugPrint("$logTrace commandes count: $value");
            setState(() {
              _commandeLivraison = value;
            });
          });
          getCommandesCount(2, resto.id).then((value) {
            debugPrint("$logTrace commandes count3: $value");
            setState(() {
              _commandeAemporter = value;
            });
          });
          getCommandesCount(3, resto.id).then((value) {
            debugPrint("$logTrace commandes count: $value");
            setState(() {
              _commandeSurPlace = value;
            });
          });
        });
      });
      debugPrint("$logTrace rtokenLoaded $value");
      setState(() {
        aToken = value;
      });
      RefreshTokenData.loadToken().then((value) {
        debugPrint("$logTrace rtokenLoaded $value");
        setState(() {
          rToken = value;
          // rToken = "";
        });
        // UserData.save("none");
        // Verifier validité token si l'utilisateur a reussi à entrer
        UserData.loadUser().then((value) {
          // if (value != "none") {
          if (value != "") {
            // verifier si l'utilisateur est connecté à internet
            _tryConnection().then((value) {
              // si connecté à internet
              if (_isConnectionSuccessful == true) {
                // verifier validité Token
                Auth.checkTokenFcn(aToken, rToken).then((value) {
                  if (!value) {
                    debugPrint("$logTrace not valid");
                    if (Auth.logOut()) {
                      debugPrint("$logTrace loged out");
                      debugPrint(
                          "$logTrace Session expirée. Veuillez vous reconnecter");
                      MyToast.showAlert(
                          "Session expirée. Veuillez vous reconnecter");
                      Navigator.popAndPushNamed(context, RoutePage.loginPage);
                    }
                  } else {
                    debugPrint("$logTrace valid");
                  }
                });
                // pas connecté à internet
              } else {
                debugPrint("$logTrace not connected");
                MyToast.showAlert(
                    "Problême de connexion,verifier votre connexion internet");
              }
            });
          }
        });
      });
    });
    if (mounted) super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Function callback = widget.callback;
    int selection = widget.selection;
    Widget _myAppBarButton(
        icon, adresse, int valeur, String route, bool selected) {
      return Badge(
        position: BadgePosition.topEnd(end: 0, top: 0),
        badgeContent: Text(
          (valeur) > 0 ? (valeur).toString().padLeft(2, "0") : "",
          style: const TextStyle(color: Colors.white),
        ),
        showBadge: (valeur).toString().padLeft(2, "0") == "00" ? false : true,
        badgeColor: UIData.colorPrincipal,
        child: GestureDetector(
          onTap: () {
            debugPrint("$logTrace gesture detected");
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 5, 5),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border.all(
                    color: selected ? UIData.colorPrincipal : Colors.black)),
            child: IconButton(
              icon: Icon(
                icon,
                size: 20,
                color: valeur != 0
                    ? selected
                        ? UIData.colorPrincipal
                        : UIData.colorPrincipal.shade200
                    : Colors.black,
              ),
              onPressed: () {
                debugPrint("$logTrace appBar");
                Navigator.popAndPushNamed(context, route);
              },
            ),
          ),
        ),
      );
    }

    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.black,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.refresh,
            color: Colors.black,
          ),
          onPressed: () {
            UserData.loadUser().then((value) {
              // if (value != "none") {
              if (value != "") {
                // verifier si l'utilisateur est connecté à internet
                _tryConnection().then((value) {
                  // si connecté à internet
                  if (_isConnectionSuccessful == true) {
                    // verifier validité Token
                    Auth.checkTokenFcn(aToken, rToken).then((value) {
                      if (!value) {
                        debugPrint("$logTrace not valid");
                        if (Auth.logOut()) {
                          debugPrint("$logTrace loged out");
                          debugPrint(
                              "$logTrace Session expirée. Veuillez vous reconnecter");
                          MyToast.showAlert(
                              "Session expirée. Veuillez vous reconnecter");
                          Navigator.popAndPushNamed(
                              context, RoutePage.loginPage);
                        }
                      } else {
                        debugPrint("$logTrace valid");
                        callback();
                        // debugPrint(
                        //     "$logTrace callback :${callback().toString()}");

                        RestoData.loadResto().then((value) {
                          Restaurant resto =
                              Restaurant.fromJson(json.decode(value)[0]);
                          for (var i = 0; i < 4; i++) {
                            getCommandesCount(i, resto.id);
                          }
                          // getCommandesCount(0, resto.id).then((value) =>
                          //     getCommandesCount(1, resto.id).then((value) =>
                          //         getCommandesCount(2, resto.id).then((value) =>
                          //             getCommandesCount(3, resto.id))));
                          // callback();
                        });
                      }
                    });
                    // pas connecté à internet
                  } else {
                    debugPrint("$logTrace not connected");
                    MyToast.showAlert(
                        "Problême de connexion,verifier votre connexion internet");
                  }
                });
              } else {
                MyToast.showAlert("Session expirée. Veuillez vous reconnecter");
              }
            });
            // MyToast.showSuccess("Refresh");
            // Navigator.pushNamed(context, RoutePage.modifPlatPage);
            // Navigator.pushNamed(context, RoutePage.detailCommandPage);
            // Navigator.pushNamed(context, RoutePage.modifMenuPage);
          },
        ),
        //Actualisation à chaque seconde
        // FutureBuilder(
        //   future: getCommandesCount(),
        //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        //     return _myAppBarButton(
        //         Icons.shopping_cart,
        //         "test",
        //         snapshot.hasData ? snapshot.data : 0,
        //         RoutePage.commandesPage,
        //         selection == 1 ? true : false);
        //   },
        // ),
        // FutureBuilder(
        //   future: getCommandesLivraisonCount(),
        //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        //     return _myAppBarButton(
        //         Icons.shopping_cart,
        //         "test",
        //         snapshot.hasData ? snapshot.data : 0,
        //         RoutePage.commandesPage,
        //         selection == 1 ? true : false);
        //   },
        // ),
        // FutureBuilder(
        //   future: getCommandesEmporteCount(),
        //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        //     return _myAppBarButton(
        //         Icons.shopping_cart,
        //         "test",
        //         snapshot.hasData ? snapshot.data : 0,
        //         RoutePage.commandesPage,
        //         selection == 1 ? true : false);
        //   },
        // ),
        // FutureBuilder(
        //   future: getCommandesSurPlaceCount(),
        //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        //     return _myAppBarButton(
        //         Icons.shopping_cart,
        //         "test",
        //         snapshot.hasData ? snapshot.data : 0,
        //         RoutePage.commandesPage,
        //         selection == 1 ? true : false);
        //   },
        // ),

        //Actualisation à chaque initState
        _myAppBarButton(Icons.shopping_cart, "test", _commandCount,
            RoutePage.commandesPage, selection == 1 ? true : false),
        _myAppBarButton(FontAwesomeIcons.truck, "test", _commandeLivraison,
            RoutePage.commandesLivraisonPage, selection == 2 ? true : false),
        _myAppBarButton(Icons.shopping_basket, "test", _commandeAemporter,
            RoutePage.emportedCommandePage, selection == 3 ? true : false),
        _myAppBarButton(Icons.place, "test", _commandeSurPlace,
            RoutePage.surPlaceCommandePage, selection == 4 ? true : false)
      ],
      // title: Text(widget.title),
    );
  }
}
