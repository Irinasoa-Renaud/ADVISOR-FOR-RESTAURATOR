// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/dashboardData.dart';
import 'package:menu_advisor/models/foodTypes.dart';

import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({Key? key}) : super(key: key);

  @override
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  String aToken = "";
  String rToken = "";
  String id = "";
  DashboardData dashboardData = DashboardData.vide();
  bool processing = false;
  String resto = "";
  @override
  void initState() {
    super.initState();
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
        UserData.loadUser().then((value) {
          setState(() {
            // debugPrint("$logTrace before decode ${value.toString()}");
            // debugPrint(
            //     "$logTrace user_data.txt-> ${json.decode(value)['user']['name']['first']}");
            User user = User.fromJson(json.decode(value)['user']);
            setState(() {
              id = user.id;
            });
            // getdashboard(user.id);
            debugPrint("$logTrace id: ${user.id}");
            RestoData.loadResto().then((value) {
              Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
              getdashboard(value != "" ? resto.id : "admin");
            });
            // ROLE_RESTAURANT_ADMIN
          });
        });
      });
    });
    UserData.loadUser().then((value) {
      User user = User.fromJson(json.decode(value)['user']);
      id = user.id;
      debugPrint("$logTrace id:$id");
      debugPrint("$logTrace resto:${user.favoriteRestaurants}");
    });
  }

  Future<dynamic> getRestaurantbyAdmin(String id) async {
    setState(() {
      processing = true;
    });
    var url = Uri.parse(Api.restaurants + "?admin=$id");
    debugPrint("$logTrace url:$url");
    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      // debugPrint("$logTrace data ${response.body}");
      setState(() {
        debugPrint("$logTrace data $jsonData");
        setState(() {
          processing = false;
        });
      });
      return jsonData;
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        processing = false;
      });
    }
  }

  Future<void> getdashboard(String id) async {
    setState(() {
      processing = true;
    });
    DashboardData d;
    var url = Uri.parse(Api.dashboard + "/${id.toString()}");
    debugPrint("$logTrace url:$url");
    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      // debugPrint("$logTrace data ${response.body}");
      setState(() {
        d = DashboardData.fromJson(jsonData);
        dashboardData = d;
        debugPrint("$logTrace data $d");
        setState(() {
          processing = false;
        });
      });
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _dashboardElementA(String title, valInt) {
      String val = valInt.toString();
      return SizedBox.square(
        dimension: 100,
        child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      val,
                      textAlign: TextAlign.center,
                    )
                  ]),
            )),
      );
    }

    Widget dashboardElementB(title, valInt) {
      String val = valInt.toString();
      return SizedBox.square(
        dimension: 100,
        child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                    ),
                    const Icon(
                      Icons.euro,
                      size: 15,
                    ),
                    Text(
                      // val + "\u{A3}",
                      val,
                      textAlign: TextAlign.center,
                    )
                  ]),
            )),
      );
    }

    return WillPopScope(
      onWillPop: () {
        throw Navigator.popAndPushNamed(context, RoutePage.commandesPage);
      },
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 1),
        appBar: MyAppBar(
            selection: 0,
            callback: () {
              RestoData.loadResto().then((value) {
                Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
                getdashboard(value != "" ? resto.id : "admin");
              });
            }),
        body: Stack(children: [
          ListView(
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
                          Icons.dashboard,
                          size: 50,
                          color: UIData.logoTitleColor,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: const [
                      Text(
                        "Dashboard",
                        style: TextData.titlePageStyle,
                      ),
                      Text("Commande|Chiffre d'Affaire",
                          style: TextData.subtitlePageStyle)
                    ],
                  )
                ],
              )),
              Card(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: Center(
                        child: Text(
                          "Nombre de Commande",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _dashboardElementA("Aujourd'hui", dashboardData.day),
                        _dashboardElementA("Cette Semaine", dashboardData.week),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _dashboardElementA("Cet Mois", dashboardData.month),
                        _dashboardElementA("Cette Année", dashboardData.year),
                      ],
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: Center(
                        child: Text(
                          "Chiffre d'Affaire",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        dashboardElementB(
                            "Aujourd'hui", dashboardData.affaireDay / 100),
                        dashboardElementB(
                            "Cette Semaine", dashboardData.affaireWeek / 100),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        dashboardElementB(
                            "Cet Mois", dashboardData.affaireMonth / 100),
                        dashboardElementB(
                            "Cette Année", dashboardData.affaireYear / 100),
                      ],
                    ),
                    const Divider()
                  ],
                ),
              )
            ],
          ),
          processing
              ? Center(
                  child: SizedBox.square(
                    dimension: 100,
                    child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(118, 158, 158, 158),
                            boxShadow: [
                              BoxShadow(color: Color.fromARGB(120, 0, 0, 0))
                            ]),
                        padding: const EdgeInsets.all(30),
                        child: const CircularProgressIndicator()),
                  ),
                )
              : Container(),
          processing
              ? SizedBox.expand(
                  child: Container(color: const Color.fromARGB(132, 0, 0, 0)),
                )
              : Container(),
        ]),
        floatingActionButton: const MyFloatingActionButton(),
      ),
    );
  }
}
