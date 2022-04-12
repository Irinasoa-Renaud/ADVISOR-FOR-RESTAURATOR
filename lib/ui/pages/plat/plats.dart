import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/food.dart';
import 'package:menu_advisor/models/foodTypes.dart';

import 'package:menu_advisor/utils/dependences.dart';
import 'package:http/http.dart' as http;

class PlatsPage extends StatefulWidget {
  const PlatsPage({Key? key}) : super(key: key);

  @override
  _PlatsPageState createState() => _PlatsPageState();
}

class _PlatsPageState extends State<PlatsPage> {
  final TextEditingController _nomSearchController = TextEditingController(),
      _attributeSearchController = TextEditingController(),
      _allergeneSearchController = TextEditingController();

  bool nomSearch = false,
      restoSearch = false,
      statusSearch = false,
      attributSearch = false,
      allergeneSearch = false;

  bool status = false;

  List<Food> filtrePlats(String resto, String nom, bool statut, String attribut,
      String allergene, List<Food> foodsSource) {
    List<Food> foods = [];

    if (nomSearch) {
      for (Food i in foodsSource) {
        if (i.name.toLowerCase().contains(nom.toLowerCase())) {
          foods.add(i);
        }
      }
      debugPrint("$logTrace taille:${foods.length}");
    }

    if (statusSearch) {
      for (Food i in foodsSource) {
        if (i.statut == status) {
          foods.add(i);
        }
      }
    }

    if (attributSearch) {
      for (Food i in foodsSource) {
        for (var j in i.attributs) {
          if (j.nom.fr.contains(attribut)) foods.add(i);
          debugPrint("$logTrace ${j.nom.fr}");
          debugPrint("$logTrace $attribut");
        }
      }
    }

    if (allergeneSearch) {
      for (Food i in foodsSource) {
        for (var j in i.allergene) {
          if (j.nom.fr.contains(allergene)) foods.add(i);
          debugPrint("$logTrace ${j.nom.fr}");
          debugPrint("$logTrace $allergene");
        }
      }
    }

    if (statusSearch) {
      for (Food i in foodsSource) {
        if (i.statut == statut) foods.add(i);
        debugPrint("$logTrace ${i.statut}");
        debugPrint("$logTrace $statut");
      }
    }
    debugPrint("$logTrace ${foods.length}");
    debugPrint("$logTrace ${foodsSource.length}");
    return foods;
  }

  String aToken = "", rToken = "";
  bool processing = false;

  String restoId = "";

  final List<Map> _plats = [
    {
      // 'id': 1,
      'nom': 'Pomme Frite',
      'prix': '50',
      'image': 'http://192.168.43.208/ImagesBank/images/ftmtk.jpg'
    },
    {
      // 'id': 2,
      'nom': 'Salade de patte',
      'prix': '20',
      'image': 'http://192.168.43.208/ImagesBank/images/acer.jpg'
    },
  ];
  late int _currentSortColumn = 0;
  bool _isSortAsc = true;
  List<bool> _selected = [];

  List<Food> foods = [];
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
        RestoData.loadResto().then((value) {
          restoId = json.decode(value)[0]['_id'];
          getFoods(json.decode(value)[0]['_id']);
        });
        // RestoData.loadResto()
        //     .then((value) => getFoods(json.decode(value)[0]['_id']));
      });
    });
    _selected = List<bool>.generate(_plats.length, (int index) => false);
  }

  Future<void> getFoods(String restoId) async {
    debugPrint("$logTrace getFoods()");
    setState(() {
      processing = true;
    });
    List<Food> foodS = [];
    // ${id}?lang=fr
    var url = Uri.parse(Api.foods +
        "?lang=fr" +
        (restoId != "" ? '&filter={"restaurant":"$restoId"}' : '&filter={}'));
    try {
      setState(() {
        processing = true;
      });
      debugPrint("$logTrace url food $url");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data ${response.body.toString()}");
      for (var i in jsonData) {
        Food food = Food.fromJson(i);
        debugPrint("$logTrace _id ${food.name}");
        // if (i['restaurant']) foodS.add(food);
        foodS.add(food);
      }
      setState(() {
        foods = foodS;
        processing = false;
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
    double w = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 4),
        appBar: MyAppBar(
            selection: 0,
            callback: () {
              RestoData.loadResto()
                  .then((value) => getFoods(json.decode(value)[0]['_id']));
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
                        Icons.fastfood,
                        size: 50,
                        color: UIData.logoTitleColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      "Plats",
                      style: TextData.titlePageStyle,
                    ),
                    Text("Liste des plats", style: TextData.subtitlePageStyle)
                  ],
                )
              ],
            )),
            Card(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(primary: UIData.btnAlert),
                        onPressed: () {
                          Navigator.pushNamed(context, RoutePage.ajoutPlatPage,
                              arguments: NewFoodArgs(aToken, restoId));
                        },
                        icon: const Icon(Icons.add_circle),
                        label: const Text("Ajouter un plat")),
                    PopupMenuButton(
                        icon: const Icon(Icons.sort_sharp),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                                child: const Text('Restaurant'),
                                onTap: () {
                                  setState(() {
                                    // restoSearch = true;
                                  });
                                }),
                            PopupMenuItem(
                                child: const Text('Nom'),
                                onTap: () {
                                  setState(() {
                                    nomSearch = true;
                                  });
                                }),
                            PopupMenuItem(
                                child: const Text('Status'),
                                onTap: () {
                                  setState(() {
                                    statusSearch = true;
                                  });
                                }),
                            PopupMenuItem(
                                child: const Text('Attributs'),
                                onTap: () {
                                  setState(() {
                                    attributSearch = true;
                                  });
                                }),
                            PopupMenuItem(
                                child: const Text('Allergène'),
                                onTap: () {
                                  setState(() {
                                    allergeneSearch = true;
                                  });
                                }),
                          ];
                        })
                  ],
                ),
                if (nomSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _nomSearchController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Nom", border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              nomSearch = false;
                              _nomSearchController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (attributSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _attributeSearchController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Attribut",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              attributSearch = false;
                              _attributeSearchController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (allergeneSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _allergeneSearchController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Allergene",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              allergeneSearch = false;
                              _allergeneSearchController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                if (statusSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 200,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Valide"),
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
                                    statusSearch = false;
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
                      child: _createTabe(foods)),
                ),
              ]),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
        // floatingActionButton: FloatingActionButton(
        //     backgroundColor: Colors.white,
        //     child: processing
        //         ? const CircularProgressIndicator()
        //         : const Icon(
        //             Icons.get_app,
        //             color: UIData.colorPrincipal,
        //           ),
        //     onPressed: () {
        //       RestoData.loadResto()
        //           .then((value) => getFoods(json.decode(value)[0]['_id']));
        //     }),
      ),
      onWillPop: () {
        throw Navigator.pushNamed(context, RoutePage.commandesPage);
      },
    );
  }

  Widget _createTabe(List<Food> f) {
    double w = MediaQuery.of(context).size.width;
    setState(() {
      f = (nomSearch ||
              restoSearch ||
              statusSearch ||
              allergeneSearch ||
              attributSearch)
          ? filtrePlats(
              "",
              _nomSearchController.text,
              status,
              _attributeSearchController.text,
              _allergeneSearchController.text,
              f)
          : f;
    });
    return f.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: _createDataTable(foods))
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
                            "Aucun Plat",
                            style: TextData.subtitlePageStyle,
                          ),
                  ),
                )
              ],
            ));
  }

  DataTable _createDataTable(List<Food> foods) {
    return DataTable(
      columns: _createColumns(),
      rows: _createRows(foods),
      dividerThickness: 5,
      dataRowHeight: 90,
      showBottomBorder: true,
      headingTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      headingRowColor:
          MaterialStateProperty.resolveWith((states) => UIData.colorPrincipal),
    );
  }

  DataTable _createDataTableVide() {
    return DataTable(
      columns: _createColumns(),
      rows: [],
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
      const DataColumn(label: Text('Prix')),
      const DataColumn(label: Text('Image'))
    ];
  }

  List<DataRow> _createRows(List<Food> foods) {
    return foods
        .mapIndexed((index, food) => DataRow(
              cells: [
                DataCell(Text(
                  food.name,
                )),
                DataCell(Text((food.price.amount / 100).toString() + " €")),
                // DataCell(Text(plat['image'])),
                DataCell(SizedBox(
                    width: 100,
                    child: food.imageURL.contains("https://api-advisor")
                        ? Image.network(food.imageURL)
                        : !food.imageURL.contains("data:image")
                            ? Image.asset(UIData.placeholder)
                            : Image.memory(Tools.stringToImg(food.imageURL))))
              ],
            ))
        .toList();
  }
}
