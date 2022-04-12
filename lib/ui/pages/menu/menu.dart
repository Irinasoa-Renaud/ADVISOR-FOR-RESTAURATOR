import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/foodTypes.dart';
import 'package:menu_advisor/models/menu.dart';

import 'package:menu_advisor/utils/dependences.dart';
import 'package:http/http.dart' as http;

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _nomSearchController = TextEditingController(),
      _prioritySearchController = TextEditingController();

  bool nomSearch = false, restoSearch = false, prioritySearch = false;

  List<Menu> filtreMenu(
      String nom, String resto, String priority, List<Menu> menusSources) {
    List<Menu> menus = [];
    if (nomSearch) {
      for (Menu i in menusSources) {
        if (i.name.toLowerCase().contains(nom.toLowerCase())) {
          menus.add(i);
        }
      }
    }
    if (prioritySearch) {
      if (int.tryParse(priority) != null) {
        for (Menu i in menusSources) {
          if (i.priority == int.tryParse(priority)!) {
            menus.add(i);
          }
        }
      }
    }
    if (prioritySearch && nomSearch) {
      if (int.tryParse(priority) != null) {
        for (Menu i in menusSources) {
          if ((i.priority == int.tryParse(priority)!) &&
              (i.name.toLowerCase().contains(nom.toLowerCase()))) {
            menus.add(i);
          }
        }
      }
    }
    return menus;
  }

  String aToken = "", rToken = "";
  List<Menu> menus = [];
  final List<Map> _accompagnements = [
    {
      // 'id': 1,
      'nom': 'Test Menu',
      'restaurant': 'GASTRO',
    },
    {
      // 'id': 2,
      'nom': 'Salade de patte',
      'restaurant': 'Pizza\'in',
    },
  ];
  bool processing = false;
  late int _currentSortColumn = 0;
  bool _isSortAsc = true;
  List<bool> _selected = [];

  @override
  void dispose() {
    _nomSearchController.dispose();
    _prioritySearchController.dispose();
    super.dispose();
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
        RestoData.loadResto().then((value) {
          getMenus(json.decode(value)[0]['_id']).then((value) {
            _selected = List<bool>.generate(menus.length, (int index) => false);
          });
        });
      });
    });
  }

  Future<void> getMenus(String restoId) async {
    debugPrint("$logTrace getMenus()");
    List<Menu> menuS = [];
    setState(() {
      processing = true;
    });
    var url = Uri.parse(Api.menus +
        "?lang=fr" +
        (restoId != "" ? '&filter={"restaurant":"$restoId"}' : '&filter={}'));
    try {
      setState(() {
        processing = true;
      });
      // debugPrint("$logTrace $url");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data ${response.body.toString()}");
      for (var i in jsonData) {
        Menu menu = Menu.fromJson(i);
        menuS.add(menu);
      }
      menus = menuS;
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

  static Map<String, String> filter = {
    'name': 'Nom',
    'priority': 'Priorité',
    'restaurant': 'Restaurant'
  };

  static List<DropdownMenuItem<String>> dropdownFilterItems = filter
      .map((value, display) {
        return MapEntry(
            display,
            DropdownMenuItem<String>(
              value: value,
              child: Text(display),
            ));
      })
      .values
      .toList();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 5),
        appBar: MyAppBar(
            selection: 0,
            callback: () {
              RestoData.loadResto().then((value) {
                getMenus(json.decode(value)[0]['_id']);
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
                        Icons.menu_book,
                        size: 50,
                        color: UIData.logoTitleColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      "Menu",
                      style: TextData.titlePageStyle,
                    ),
                    Text("Liste des menus", style: TextData.subtitlePageStyle)
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
                          Navigator.pushNamed(context, RoutePage.ajoutMenuPage);
                        },
                        icon: const Icon(Icons.add_circle),
                        label: const Text("Ajouter un menu")),
                    PopupMenuButton(
                      icon: const Icon(Icons.sort_sharp),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                              child: const Text('Nom'),
                              onTap: () {
                                setState(() {
                                  nomSearch = true;
                                  prioritySearch = false;
                                  print(nomSearch);
                                });
                              }),
                          PopupMenuItem(
                              child: const Text('Priorité'),
                              onTap: () {
                                setState(() {
                                  prioritySearch = true;
                                  nomSearch = false;
                                });
                              }),
                          // PopupMenuItem(
                          //     child: const Text('Restaurant'),
                          //     onTap: () {
                          //       print("Resto");
                          //     }),
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
                if (prioritySearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _prioritySearchController,
                          showCursor: true,
                          decoration: const InputDecoration(
                              hintText: "Priorité",
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              prioritySearch = false;
                              _prioritySearchController.clear();
                            });
                          },
                          icon: const Icon(Icons.close))
                    ]),
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _createTable(menus),
                  ),
                ),
              ]),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.get_app),
        //   onPressed: () {
        //     RestoData.loadResto()
        //         .then((value) => getMenus(json.decode(value)[0]['_id']));
        //     // getMenus();
        //   },
        // ),
      ),
      onWillPop: () {
        throw Navigator.pushNamed(context, RoutePage.commandesPage);
      },
    );
  }

  Widget _createTable(List<Menu> m) {
    double w = MediaQuery.of(context).size.width;
    setState(() {
      m = (nomSearch || restoSearch || prioritySearch)
          ? filtreMenu(_nomSearchController.text, 'resto',
              _prioritySearchController.text, m)
          : m;
    });
    return m.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: w - 20, child: _createDataTable(m)))
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
                            "Aucun Menu",
                            style: TextData.subtitlePageStyle,
                          ),
                  ),
                )
              ],
            ));
  }

  DataTable _createDataTableVide() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Nom')),
        DataColumn(label: Text('Restaurant')),
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

  DataTable _createDataTable(List<Menu> m) {
    return DataTable(
      columns: _createColumns(),
      rows: _createRows(m),
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
      const DataColumn(label: Text('Restaurant'))
    ];
  }

  List<DataRow> _createRows(List<Menu> ms) {
    return ms
        .asMap()
        .map((index, m) => MapEntry(
            index,
            DataRow(
              onLongPress: () {
                Navigator.pushNamed(context, RoutePage.modifMenuPage,
                    arguments: ModifTypeArgs(aToken, m.id, m.name, m.priority));
              },
              cells: [
                DataCell(Text(m.name)),
                // Text(m.id)),
                DataCell(Text(m.restaurant.name)),
                // Text(m.id))
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
