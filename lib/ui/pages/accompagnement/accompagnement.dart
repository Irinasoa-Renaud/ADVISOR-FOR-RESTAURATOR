import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/accompagnement.dart';
import 'package:menu_advisor/models/restaurant.dart';
import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

class AccompagnementsPage extends StatefulWidget {
  const AccompagnementsPage({Key? key}) : super(key: key);

  @override
  _AccompagnementsPageState createState() => _AccompagnementsPageState();
}

class _AccompagnementsPageState extends State<AccompagnementsPage> {
  final TextEditingController _nomSearchController = TextEditingController();

  bool nomSearch = false, restoSearch = false;

  List<Accompagnement> filtreAcc(
      String nom, String resto, List<Accompagnement> accsSources) {
    List<Accompagnement> accs = [];
    if (nomSearch) {
      for (Accompagnement i in accsSources) {
        if (i.name.toLowerCase().contains(nom.toLowerCase())) {
          accs.add(i);
        }
      }
      print(accs.length);
    }
    return accs;
  }

  List<Accompagnement> accompagnements = [];
  late int _currentSortColumn = 0;
  bool _isSortAsc = true;
  List<bool> _selected = [];
  String aToken = "", rToken = "";
  bool processing = false;
  bool processingDelete = false;
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
        RestoData.loadResto().then((value) {
          Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
          getAccompagenement(resto.id).then((value) {
            _selected = List<bool>.generate(
                accompagnements.length, (int index) => false);
          });
        });
      });
    });
    // _selected = List<bool>.generate(accompagnements.length, (int index) => false);
  }

  Future<void> getAccompagenement(String restoId) async {
    List<Accompagnement> accomps = [];
    debugPrint("$logTrace getAccompagnements($restoId)");
    setState(() {
      processing = true;
      // restoId = ""; //debug
    });
    var url = Uri.parse(Api.acompagnement +
        (restoId != "" ? '?filter={"restaurant":"$restoId"}' : '?filter={}'));
    try {
      setState(() {
        processing = true;
      });
      debugPrint("$logTrace $url");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data ${response.body.toString()}");
      for (var i in jsonData) {
        Accompagnement accomp = Accompagnement.fromJson(i);
        accomps.add(accomp);
      }
      accompagnements = accomps;
      setState(() {
        processing = false;
      });
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        processing = false;
      });
    }
  }

  Future<void> deleteAccompagnement(String id, String token) async {
// 623432b162dcf70012706696
    setState(() {
      processingDelete = true;
    });
    var url = Uri.parse(Api.acompagnement + "/$id");
    try {
      var response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      setState(() {
        processingDelete = false;
      });
    } catch (e) {
      setState(() {
        processingDelete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 7),
        appBar: MyAppBar(
            selection: 0,
            callback: () {
              RestoData.loadResto().then((value) {
                Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
                getAccompagenement(resto.id);
              });
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
                        Icons.view_module,
                        size: 50,
                        color: UIData.logoTitleColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      "Accompagnements",
                      style: TextData.titlePageStyle,
                    ),
                    Text("Liste des accompagnements",
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
                    ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(primary: UIData.btnAlert),
                        onPressed: () {
                          RestoData.loadResto().then((value) {
                            Restaurant resto =
                                Restaurant.fromJson(json.decode(value)[0]);
                            Navigator.pushNamed(
                                context, RoutePage.ajoutAccompagnementPage,
                                arguments: NewAccompagnementArgs(aToken,
                                    resto.id, RoutePage.accompagnementPage));
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                        label: const Text("Ajouter un accompagnement")),
                    PopupMenuButton(
                      icon: const Icon(Icons.sort_sharp),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                              child: const Text('Nom'),
                              onTap: () {
                                setState(() {
                                  nomSearch = true;
                                  restoSearch = false;
                                  print(nomSearch);
                                });
                              }),
                          PopupMenuItem(
                              child: const Text('Restaurant'),
                              onTap: () {
                                print("Resto");
                                restoSearch = true;
                                nomSearch = false;
                              }),
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
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _createTable(accompagnements)),
                ),
              ]),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.get_app),
        //   onPressed: () {
        //     // deleteAccompagnement("623432b162dcf70012706696", aToken);
        //     RestoData.loadResto().then((value) {
        //       Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
        //       getAccompagenement(resto.id);
        //     });
        //   },
        // ),
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
        DataColumn(label: Text('Prix')),
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

  DataTable _createDataTable(List<Accompagnement> a) {
    return DataTable(
      // sortColumnIndex: _currentSortColumn,
      // sortAscending: _isSortAsc,
      columns: _createColumns(),
      rows: _createRows(a),
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
      // DataColumn(
      //     label: const Text('ID'),
      //     tooltip: 'accompagnement id',
      //     onSort: (columnIndex, _) {
      //       setState(() {
      //         _currentSortColumn = columnIndex;
      //         if (_isSortAsc) {
      //           _accompagnements.sort((a, b) => b['id'].compareTo(a['id']));
      //         } else {
      //           _accompagnements.sort((a, b) => a['id'].compareTo(b['id']));
      //         }
      //         _isSortAsc = !_isSortAsc;
      //       });
      //     }
      //     ),
      const DataColumn(label: Text('Nom')),
      // const DataColumn(label: Text('Restaurant')),
      const DataColumn(label: Text('Prix')),
      const DataColumn(label: Text('Image')),
      const DataColumn(
          label: Text(
        'Actions',
        style: TextStyle(color: Colors.white60),
      )),
    ];
  }

  List<DataRow> _createRows(List<Accompagnement> as) {
    return as
        .asMap()
        .map((index, m) => MapEntry(
              index,
              DataRow(
                onLongPress: () {
                  RestoData.loadResto().then((value) {
                    Restaurant resto =
                        Restaurant.fromJson(json.decode(value)[0]);
                    Navigator.pushNamed(
                        context, RoutePage.modifAccompagnementPage,
                        arguments: UpdateAccompagnementArgs(aToken, resto.id,
                            m.id, m.imageURL, m.price, m.name));
                  });
                },
                cells: [
                  DataCell(Text(m.name)),
                  DataCell(Text((m.price.amount/100).toString()+" €")),
                  DataCell(Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: 70,
                      child: m.imageURL.contains("https://api-advisor")
                          ? Image.network(m.imageURL)
                          : !m.imageURL.contains("data:image")
                              ? Image.asset(UIData.placeholder)
                              : Image.memory(Tools.stringToImg(m.imageURL)))),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        RestoData.loadResto().then((value) {
                          Restaurant resto =
                              Restaurant.fromJson(json.decode(value)[0]);
                          Navigator.pushNamed(
                              context, RoutePage.modifAccompagnementPage,
                              arguments: UpdateAccompagnementArgs(aToken,
                                  resto.id, m.id, m.imageURL, m.price, m.name));
                        });
                      },
                      child: const Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                        primary: UIData.btnSuccess,
                      ),
                    ),
                  )
                ],
              ),
            ))
        .values
        .toList();
  }

  Widget _createTable(List<Accompagnement> accs) {
    double w = MediaQuery.of(context).size.width;
    setState(() {
      accs = (nomSearch || restoSearch)
          ? filtreAcc(_nomSearchController.text, "", accs)
          : accs;
    });
    return accs.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: _createDataTable(accs))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                SizedBox(width: w - 20, child: _createDataTableVide()),
                SizedBox(
                  height: 200,
                  child: Center(
                    child: processing
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Aucun Accompagenement",
                            style: TextData.subtitlePageStyle,
                          ),
                  ),
                )
              ],
            ));
  }
}
