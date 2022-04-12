import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/recomandedPlat.dart';

import 'package:menu_advisor/utils/dependences.dart';
import 'package:http/http.dart' as http;

class PlatsRecommandedPage extends StatefulWidget {
  const PlatsRecommandedPage({Key? key}) : super(key: key);

  @override
  _PlatsRecommandedPageState createState() => _PlatsRecommandedPageState();
}

class _PlatsRecommandedPageState extends State<PlatsRecommandedPage> {
  final List<Map> _plats = [
    {
      // 'id': 1,
      'nom': 'Pomme Frite',
      'restaurant': 'gastro',
    },
  ];
  late int _currentSortColumn = 0;
  bool _isSortAsc = true;
  List<bool> _selected = [];
  String aToken = "", rToken = "";

  List<RecommandedPlat> rplats = [];

  bool processing = false;
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
      });
      RestoData.loadResto()
          .then((value) => getRecommandedFoods(json.decode(value)[0]['_id']));
    });
    _selected = List<bool>.generate(_plats.length, (int index) => false);
  }

  Future<void> getRecommandedFoods(String restoId) async {
    debugPrint("$logTrace getRecommandedFoods()");
    List<RecommandedPlat> rfoods = [];
    setState(() {
      processing = true;
    });
    var url = Uri.parse(Api.platRecommander +
        (restoId != "" ? '?filter={"restaurant":"$restoId"}' : '?filter={}'));
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
        RecommandedPlat rf = RecommandedPlat.fromJson(i);
        rfoods.add(rf);
      }
      rplats = rfoods;
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

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 10),
        appBar: MyAppBar(
            selection: 0,
            callback: () {
              debugPrint("$logTrace getPlatRecommander()");
              RestoData.loadResto().then(
                  (value) => getRecommandedFoods(json.decode(value)[0]['_id']));
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
                        Icons.card_giftcard,
                        size: 50,
                        color: UIData.logoTitleColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      "Plats Recommandés",
                      style: TextData.titlePageStyle,
                    ),
                    Text("Liste des plats recommandés",
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
                          Navigator.pushNamed(
                              context, RoutePage.recommanderPlatPage);
                        },
                        icon: const Icon(Icons.add_circle),
                        label: const Text("Recommander un plat")),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.sort_sharp))
                  ],
                ),
                // ElevatedButton.icon(
                //     style: ElevatedButton.styleFrom(primary: UIData.btnDefault),
                //     onPressed: () {},
                //     icon: const Icon(Icons.rotate_left),
                //     label: const Text("Reset")),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: rplats.isNotEmpty
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _createDataTable(rplats),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  Container(
                                      width: w - 20,
                                      child: _createDataTableVide()),
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
                              ),
                            )),
                ),
              ]),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.get_app),
        //   onPressed: () {
        //     RestoData.loadResto().then(
        //         (value) => getRecommandedFoods(json.decode(value)[0]['_id']));
        //     // getRecommandedFoods();
        //   },
        // ),
      ),
      onWillPop: () {
        throw Navigator.pushNamed(context, RoutePage.commandesPage);
      },
    );
  }

  DataTable _createDataTable(List<RecommandedPlat> foods) {
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

  List<DataColumn> _createColumns() {
    return [
      // DataColumn(
      //     label: const Text('ID'),
      //     tooltip: 'plat id',
      //     onSort: (columnIndex, _) {
      //       setState(() {
      //         _currentSortColumn = columnIndex;
      //         if (_isSortAsc) {
      //           _plats.sort((a, b) => b['id'].compareTo(a['id']));
      //         } else {
      //           _plats.sort((a, b) => a['id'].compareTo(b['id']));
      //         }
      //         _isSortAsc = !_isSortAsc;
      //       });
      //     }
      //     ),
      const DataColumn(label: Text('Nom')),
      const DataColumn(label: Text('Restaurant')),
    ];
  }

  List<DataRow> _createRows(List<RecommandedPlat> foods) {
    return foods
        .mapIndexed((index, food) => DataRow(
              cells: [
                DataCell(Text(food.food.name)),
                DataCell(Text(food.food.restaurant)),
              ],
            ))
        .toList();
  }

  // List<DataRow> _createRows() {
  //   return _plats
  //       .mapIndexed((index, plat) => DataRow(
  //             cells: [
  //               // DataCell(Text('#' + plat['id'].toString(),
  //               //     style: const TextStyle(fontWeight: FontWeight.bold))),
  //               DataCell(Text(plat['nom'])),
  //               DataCell(Text(plat['restaurant'])),
  //               // DataCell(Text(plat['image'])),
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
