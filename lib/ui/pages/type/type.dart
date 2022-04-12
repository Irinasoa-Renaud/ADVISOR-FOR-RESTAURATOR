import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:menu_advisor/utils/dependences.dart';
import 'package:menu_advisor/models/foodTypes.dart';
import 'package:http/http.dart' as http;

class TypePage extends StatefulWidget {
  const TypePage({Key? key}) : super(key: key);

  @override
  _TypePageState createState() => _TypePageState();
}

class _TypePageState extends State<TypePage> {
  final TextEditingController _nomSearchController = TextEditingController();

  bool nomSearch = false, restoSearch = false;

  List<FoodType> filtreType(
      String nom, String resto, List<FoodType> typesSources) {
    List<FoodType> types = [];
    if (nomSearch) {
      for (FoodType i in typesSources) {
        if (i.name.fr.toLowerCase().contains(nom.toLowerCase())) {
          types.add(i);
        }
      }
    }
    return types;
  }

  List<FoodType> types = [];
  final List<Map> _types = [
    {
      // 'id': 1,
      'nom': 'entré',
      'restaurant': 'GASTRO',
    },
  ];
  late int _currentSortColumn = 0;
  bool _isSortAsc = true;
  List<bool> _selected = [];
  String aToken = "", rToken = "";

  bool processing = false;
  bool processingDelete = false;

  var url = Uri.parse(Api.foodTypes + '?filter={}');

  Future<List<FoodType>> getTypes(String restoId) async {
    setState(() {
      processing = true;
    });
    List<FoodType> ftypes = [];
    var url = Uri.parse(Api.foodTypes +
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
      // debugPrint("$logTrace data ${response.body.toString()}");
      setState(() {
        for (var i in jsonData) {
          // debugPrint("$logTrace _id${i.runtimeType} ${jsonData['_id']}");
          FoodType type = FoodType.fromJson(i);
          ftypes.add(type);
        }
        types = ftypes;
      });
      setState(() {
        processing = false;
      });
      return ftypes;
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        processing = false;
      });
      return [];
    }
  }

  Future<bool> deleteType(String id) async {
    setState(() {
      processingDelete = true;
    });
    debugPrint("$logTrace  deleteType:$id");
    var url = Uri.parse(Api.url + "/foodTypes" + "/$id");
    try {
      var response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data deleteType:${response.body}");
      setState(() {
        processingDelete = false;
      });
      return response.statusCode == 200 ? true : false;
    } catch (e) {
      debugPrint("$logTrace erreur deleteType:$e");
      setState(() {
        processingDelete = false;
      });
      return false;
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
        debugPrint("$logTrace tokenLoaded $value");
        setState(() {
          rToken = value;
        });
      });
      RestoData.loadResto().then((value) {
        Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
        getTypes(resto.id).then((value) {
          // getTypes("").then((value) {
          debugPrint("$logTrace val $value");
          setState(() {
            types = value;
          });
        });
      });
    });
    // _selected = List<bool>.generate(_types.length, (int index) => false);
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

  List<DataRow> _createRows(List<FoodType> types) {
    return types
        .asMap()
        .map((index, type) => MapEntry(
            index,
            DataRow(
              onLongPress: () {
                // deleteType(type.id);
                // Navigator.pushNamed(context, RoutePage.modifTypePage,
                //     arguments: ModifTypeArgs(
                //         aToken, type.id, type.name.fr, type.priority));
              },
              cells: [
                DataCell(Text(type.name.fr)),
                DataCell(Text(type.restaurant.name)),
                // DataCell(Text(type.name.fr)),
                DataCell(Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RoutePage.modifTypePage,
                            arguments: ModifTypeArgs(
                                aToken, type.id, type.name.fr, type.priority));
                      },
                      child: const Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                        primary: UIData.btnSuccess,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Supprimer un type"),
                                content: Text(
                                    "Vous allez supprimer le type '${type.name.fr}'?"),
                                actions: [
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        primary: UIData.btnSuccess,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      icon: const Icon(Icons.check),
                                      label: const Text("Oui")),
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        primary: UIData.btnAlert,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      icon: const Icon(Icons.cancel),
                                      label: const Text("Non")),
                                ],
                              );
                            }).then((value) {
                          print("val delete:$value");
                          if (value == true) {
                            deleteType(type.id).then((valueDelete) {
                              if (valueDelete) {
                                MyToast.showSuccess(
                                    "type supprimé avec succès");
                                Navigator.popAndPushNamed(
                                    context, RoutePage.typePage);
                              } else {
                                MyToast.showAlert(
                                    "Erreur lors de la suppression");
                                Navigator.pop(context);
                              }
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        });
                      },
                      child: const Icon(Icons.delete),
                      style: ElevatedButton.styleFrom(
                        primary: UIData.btnAlert,
                      ),
                    ),
                  ],
                )),
              ],
            )))
        .values
        .toList();
  }

  Widget _createTable(List<FoodType> types) {
    double w = MediaQuery.of(context).size.width;
    setState(() {
      types = (nomSearch || restoSearch)
          ? filtreType(_nomSearchController.text, "", types)
          : types;
    });
    return types.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: _createDataTable(types))
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
                            "Aucune Type disponible",
                            style: TextData.subtitlePageStyle,
                          ),
                  ),
                )
              ],
            ));
  }

  DataTable _createDataTable(List<FoodType> types) {
    return DataTable(
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
      columns: const [
        DataColumn(label: Text('Nom')),
        DataColumn(label: Text('Restaurant')),
        DataColumn(label: Text('Actions')),
      ],
      rows: _createRows(types),
      dividerThickness: 5,
      dataRowHeight: 100,
      showBottomBorder: true,
      headingTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      headingRowColor:
          MaterialStateProperty.resolveWith((states) => UIData.colorPrincipal),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 6),
        appBar: MyAppBar(
            selection: 0,
            callback: () {
              RestoData.loadResto().then((value) {
                Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
                getTypes(resto.id).then((value) {
                  // getTypes("").then((value) {
                  debugPrint("$logTrace val $value");
                  setState(() {
                    types = value;
                  });
                });
              });
            }),
        body: Stack(
          children: [
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
                            Icons.list,
                            size: 50,
                            color: UIData.logoTitleColor,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: const [
                        Text(
                          "Type",
                          style: TextData.titlePageStyle,
                        ),
                        Text("Liste des types",
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
                            style: ElevatedButton.styleFrom(
                                primary: UIData.btnAlert),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, RoutePage.ajoutTypePage,
                                  arguments: aToken);
                            },
                            icon: const Icon(Icons.add_circle),
                            label: const Text("Ajouter un type")),
                        PopupMenuButton(
                          icon: const Icon(Icons.sort_sharp),
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                  child: const Text('Nom'),
                                  onTap: () {
                                    setState(() {
                                      nomSearch = true;
                                      print(nomSearch);
                                    });
                                  }),
                              PopupMenuItem(
                                  child: const Text('Restaurant'),
                                  onTap: () {
                                    print("Resto");
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
                                  hintText: "Nom",
                                  border: UnderlineInputBorder()),
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
                        child: _createTable(types)),
                  ]),
                )
              ],
            ),
            processingDelete
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 100,
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(118, 158, 158, 158),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromARGB(120, 0, 0, 0))
                                  ]),
                              padding: const EdgeInsets.all(30),
                              child: const CircularProgressIndicator()),
                        ),
                        const Text(
                          "Suppression en cours...",
                          style: TextData.textStyle1,
                        )
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
        // FloatingActionButton(
        //   backgroundColor: Colors.white,
        //   onPressed: () {
        //     RestoData.loadResto().then((value) {
        //       Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
        //       getTypes(resto.id).then((value) {
        //         debugPrint("$logTrace val $value");
        //         setState(() {
        //           types = value;
        //         });
        //       });
        //     });
        //   },
        //   child: const Icon(Icons.download, color: UIData.colorPrincipal),
        // )
      ),
      onWillPop: () {
        throw Navigator.pushNamed(context, RoutePage.commandesPage);
      },
    );
  }

  // DataTable _createDataTable() {
  //   return DataTable(
  //     sortColumnIndex: _currentSortColumn,
  //     sortAscending: _isSortAsc,
  //     columns: _createColumns(),
  //     rows: _createRows(),
  //     dividerThickness: 5,
  //     dataRowHeight: 90,
  //     showBottomBorder: true,
  //     headingTextStyle:
  //         const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
  //     headingRowColor:
  //         MaterialStateProperty.resolveWith((states) => UIData.colorPrincipal),
  //   );
  // }

  // List<DataColumn> _createColumns() {
  //   return [
  //     // DataColumn(
  //     //     label: const Text('ID'),
  //     //     tooltip: 'types id',
  //     //     onSort: (columnIndex, _) {
  //     //       setState(() {
  //     //         _currentSortColumn = columnIndex;
  //     //         if (_isSortAsc) {
  //     //           _types.sort((a, b) => b['id'].compareTo(a['id']));
  //     //         } else {
  //     //           _types.sort((a, b) => a['id'].compareTo(b['id']));
  //     //         }
  //     //         _isSortAsc = !_isSortAsc;
  //     //       });
  //     //     }
  //     //     ),
  //     const DataColumn(label: Text('Nom')),
  //     const DataColumn(label: Text('Restaurant'))
  //   ];
  // }

  // List<DataRow> _createRows() {
  //   return _types
  //       .mapIndexed((index, types) => DataRow(
  //             cells: [
  //               // DataCell(Text('#' + types['id'].toString(),
  //               //     style: const TextStyle(fontWeight: FontWeight.bold))),
  //               DataCell(Text(types['nom'])),
  //               DataCell(Text(types['restaurant'])),
  //             ],
  //             // selected: _selected[index],
  //             // onSelectChanged: (bool? selected) {
  //             //   setState(() {
  //             //     _selected[index] = selected!;
  //             //   });
  //             // }
  //           ))
  //       .toList();
  // }
}
