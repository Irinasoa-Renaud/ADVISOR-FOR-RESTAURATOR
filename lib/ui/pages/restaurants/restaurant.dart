import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/category.dart';

import 'package:menu_advisor/utils/dependences.dart';
import 'package:menu_advisor/models/restaurant.dart';
import 'package:http/http.dart' as http;

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({
    Key? key,
  }) : super(key: key);

  @override
  _RestaurantsPageState createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  final TextEditingController _nomRestoController = TextEditingController(),
      _villeController = TextEditingController(),
      _codePostalController = TextEditingController(),
      _mobileController = TextEditingController(),
      _telFixeController = TextEditingController(),
      _categorieController = TextEditingController();

  bool nomSearch = false,
      villeSearch = false,
      codePostalSearch = false,
      mobileSearch = false,
      fixeSearch = false,
      categorySearch = false,
      statutSearch = false,
      referencementSearch = false;

  bool status = false, referencement = false;

  List<Restaurant> filtreResto(
      String nom,
      String ville,
      String postalCode,
      String mobile,
      String fixe,
      String categorie,
      bool statuT,
      bool referencemenT,
      List<Restaurant> restosSource) {
    List<Restaurant> rests = [];
    if (nomSearch) {
      for (Restaurant i in restosSource) {
        if (i.name.toLowerCase().contains(nom.toLowerCase())) rests.add(i);
      }
    }

    if (villeSearch) {
      for (Restaurant i in restosSource) {
        if (i.city.toLowerCase().contains(ville.toLowerCase())) {
          rests.add(i);
        }
      }
    }

    if (codePostalSearch) {
      for (Restaurant i in restosSource) {
        if (i.postalCode.contains(postalCode)) rests.add(i);
      }
    }

    if (mobileSearch) {
      for (Restaurant i in restosSource) {
        if (i.phoneNumber.contains(mobile)) rests.add(i);
      }
    }

    if (fixeSearch) {
      for (Restaurant i in restosSource) {
        if (i.fixedLinePhoneNumber.contains(fixe)) rests.add(i);
      }
    }

    if (categorySearch) {
      for (Restaurant i in restosSource) {
        for (FoodCategory j in i.category) {
          if (j.id.toLowerCase().contains(categorie.toLowerCase())) {
            rests.add(i);
          }
        }
      }
    }

    if (statutSearch) {
      for (Restaurant i in restosSource) {
        if (i.status == statuT) rests.add(i);
        print("${i.status} $statuT");
      }
    }

    if (referencementSearch) {
      for (Restaurant i in restosSource) {
        if (i.referencement == referencemenT) rests.add(i);
      }
    }
    return rests;
  }

  Widget _createTable(List<Restaurant> r) {
    double w = MediaQuery.of(context).size.width;
    setState(() {
      r = (nomSearch ||
              referencementSearch ||
              villeSearch ||
              codePostalSearch ||
              mobileSearch ||
              fixeSearch ||
              categorySearch ||
              statutSearch ||
              referencementSearch)
          ? filtreResto(
              _nomRestoController.text,
              _villeController.text,
              _codePostalController.text,
              _mobileController.text,
              _telFixeController.text,
              _categorieController.text,
              status,
              referencement,
              r)
          : r;
    });
    return r.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: _createDataTable(restos))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Container(width: w - 20, child: _createDataTableVide()),
                SizedBox(
                  height: 200,
                  child: Center(
                    child: processing
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Aucune Restaurants",
                            style: TextData.subtitlePageStyle,
                          ),
                  ),
                )
              ],
            ));
  }

  List<Restaurant> restos = [];
  String aToken = "", rToken = "";
  bool processing = false;
  String user_id = "";

  Future<List<Restaurant>> getRestaurants() async {
    debugPrint("$logTrace getResto()");
    setState(() {
      processing = true;
    });
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
      restos = restaurants;
      // debugPrint('$logTrace erreur ${restaurants.last.category}');
      setState(() {
        processing = false;
      });
      return restaurants;
    } catch (e) {
      setState(() {
        processing = false;
      });
      debugPrint('$logTrace erreur $e');
      return restaurants;
    }
  }

  @override
  void initState() {
    super.initState();
    AccessTokenData.loadToken().then((value) {
      debugPrint("$logTrace tokenLoaded $value");
      setState(() {
        aToken = value;
      });
      RefreshTokenData.loadToken().then((value) {
        debugPrint("$logTrace rtokenLoaded $value");
        setState(() {
          rToken = value;
        });
        UserData.loadUser().then((value) {
          User user = User.fromJson(json.decode(value)['user']);
          setState(() {
            user_id = user.id;
          });
          getRestaurants();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 3),
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
                        Icons.restaurant,
                        size: 50,
                        color: UIData.logoTitleColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      "Restaurants",
                      style: TextData.titlePageStyle,
                    ),
                    Text("Liste des Restaurants",
                        style: TextData.subtitlePageStyle)
                  ],
                )
              ],
            )),
            Card(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton(
                      icon: const Icon(Icons.sort_sharp),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            child: const Text("Nom du restaurant"),
                            onTap: () {
                              setState(() {
                                nomSearch = true;

                                referencementSearch = false;
                                villeSearch = false;
                                codePostalSearch = false;
                                mobileSearch = false;
                                fixeSearch = false;
                                categorySearch = false;
                                statutSearch = false;
                                referencementSearch = false;
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text("Ville"),
                            onTap: () {
                              setState(() {
                                villeSearch = true;

                                nomSearch = false;

                                referencementSearch = false;
                                codePostalSearch = false;
                                mobileSearch = false;
                                fixeSearch = false;
                                categorySearch = false;
                                statutSearch = false;
                                referencementSearch = false;
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text("Code postal"),
                            onTap: () {
                              setState(() {
                                codePostalSearch = true;
                                villeSearch = false;

                                nomSearch = false;

                                referencementSearch = false;
                                mobileSearch = false;
                                fixeSearch = false;
                                categorySearch = false;
                                statutSearch = false;
                                referencementSearch = false;
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text("Mobile"),
                            onTap: () {
                              setState(() {
                                mobileSearch = true;

                                villeSearch = false;

                                nomSearch = false;

                                referencementSearch = false;
                                codePostalSearch = false;
                                fixeSearch = false;
                                categorySearch = false;
                                statutSearch = false;
                                referencementSearch = false;
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text("Telephone fixe"),
                            onTap: () {
                              setState(() {
                                fixeSearch = true;
                                villeSearch = true;

                                nomSearch = false;

                                referencementSearch = false;
                                codePostalSearch = false;
                                mobileSearch = false;
                                fixeSearch = false;
                                categorySearch = false;
                                statutSearch = false;
                                referencementSearch = false;

                                villeSearch = false;

                                nomSearch = false;

                                referencementSearch = false;
                                codePostalSearch = false;
                                mobileSearch = false;
                                categorySearch = false;
                                statutSearch = false;
                                referencementSearch = false;
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text("Categorie"),
                            onTap: () {
                              setState(() {
                                categorySearch = true;

                                villeSearch = false;

                                nomSearch = false;

                                referencementSearch = false;
                                codePostalSearch = false;
                                mobileSearch = false;
                                fixeSearch = false;
                                statutSearch = false;
                                referencementSearch = false;
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text("Etat"),
                            onTap: () {
                              setState(() {
                                statutSearch = true;

                                villeSearch = false;

                                nomSearch = false;

                                referencementSearch = false;
                                codePostalSearch = false;
                                mobileSearch = false;
                                fixeSearch = false;
                                categorySearch = false;
                                referencementSearch = false;
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text("Referencement"),
                            onTap: () {
                              setState(() {
                                referencementSearch = true;

                                villeSearch = false;

                                nomSearch = false;

                                codePostalSearch = false;
                                mobileSearch = false;
                                fixeSearch = false;
                                categorySearch = false;
                                statutSearch = false;
                                referencementSearch = false;
                              });
                            },
                          )
                        ];
                      },
                    ),
                  ],
                ),
                if (nomSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _nomRestoController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Nom du restaurant",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              nomSearch = false;
                              _nomRestoController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (villeSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _villeController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Ville",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              villeSearch = false;
                              _villeController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (codePostalSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _codePostalController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Code Postal",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              codePostalSearch = false;
                              _codePostalController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (mobileSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _mobileController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Mobile",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              mobileSearch = false;
                              _mobileController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (fixeSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _telFixeController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Numero fixe",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              fixeSearch = false;
                              _telFixeController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (categorySearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _categorieController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Categorie",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              categorySearch = false;
                              _categorieController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (statutSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 250,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Status"),
                            Switch(
                                value: status,
                                onChanged: (val) {
                                  setState(() {
                                    status = val;
                                  });
                                }),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    statutSearch = false;
                                  });
                                },
                                icon: const Icon(Icons.close))
                          ]),
                    ),
                  ),
                if (referencementSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 250,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Referencement"),
                            Switch(
                                value: referencement,
                                onChanged: (val) {
                                  setState(() {
                                    referencement = val;
                                  });
                                }),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    referencementSearch = false;
                                  });
                                },
                                icon: const Icon(Icons.close))
                          ]),
                    ),
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _createTable(restos)),
                ),
              ]),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
      ),
      onWillPop: () {
        throw Navigator.pushNamed(context, RoutePage.commandesPage);
      },
    );
  }

  DataTable _createDataTableVide() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Nom')),
        DataColumn(label: Text('Image')),
      ],
      rows: const [],
      dividerThickness: 5,
      dataRowHeight: 90,
      showBottomBorder: true,
      headingTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      headingRowColor:
          MaterialStateProperty.resolveWith((states) => UIData.colorPrincipal),
    );
  }

  DataTable _createDataTable(List<Restaurant> restos) {
    return DataTable(
      columns: _createColumns(),
      rows: _createRows(restos),
      dividerThickness: 5,
      dataRowHeight: 90,
      showBottomBorder: true,
      headingTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      headingRowColor:
          MaterialStateProperty.resolveWith((states) => UIData.colorPrincipal),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: Text('Nom')),
      const DataColumn(label: Text('Image'))
    ];
  }

  // List<DataRow> _createRows() {
  //   return _Restaurants.mapIndexed((index, Restaurant) => DataRow(
  //         cells: [
  //           // DataCell(Text('#' + Restaurant['id'].toString(),
  //           //     style: const TextStyle(fontWeight: FontWeight.bold))),
  //           DataCell(Text(Restaurant['nom'])),
  //           // DataCell(Text(Restaurant['image'])),
  //           DataCell(
  //               SizedBox(width: 100, child: Image.asset(UIData.logoGastro)))
  //         ],
  //       )).toList();
  // }

  List<DataRow> _createRows(List<Restaurant> restos) {
    return restos
        .asMap()
        .map((index, resto) => MapEntry(
            index,
            DataRow(
              cells: [
                DataCell(Text(resto.name_resto_code)),
                DataCell(SizedBox(
                    width: 100,
                    child: resto.logo.contains("https://api-advisor")
                        ? Image.network(resto.logo)
                        : !resto.logo.contains("data:image")
                            ? Image.asset(UIData.placeholder)
                            : Image.memory(Tools.stringToImg(resto.logo)))),
              ],
            )))
        // DataRow(
        //   cells: [
        //     DataCell(Text(resto.id)),
        //     DataCell(SizedBox(width: 100, child: Image.asset(UIData.logo))),
        //   ],
        // )))
        .values
        .toList();
  }
}
