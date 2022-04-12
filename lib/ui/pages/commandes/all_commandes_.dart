import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/api.dart';
import 'package:menu_advisor/models/command.dart';
import 'package:menu_advisor/ui/widget/myDrawer.dart';
import 'package:menu_advisor/ui/widget/myAppBar.dart';
import 'package:menu_advisor/ui/widget/myFloatingActionButton.dart';
import 'package:menu_advisor/utils/constants.dart';
import 'package:menu_advisor/utils/uidata.dart';

import 'package:http/http.dart' as http;

class CommandesPage extends StatefulWidget {
  const CommandesPage({Key? key}) : super(key: key);

  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> {
  List<Command> coms = [];
  final List<Map> _commandes = [
    {
      // 'id': 1,
      'numero': '1',
      'date': '22-02-2022',
      'total': '20'
    }
  ];
  late int _currentSortColumn = 0;
  bool _isSortAsc = true;
  List<bool> _selected = [];
  int _radioDelai = 0;
  String aToken = "";
  String rToken = "";

  var url = Uri.parse(Api.commandes
      //  +
      //     '?type=takeaway&filter={"restaurant":"61e18c29669bbb405a3d2d8b"}'
      );
  Future<List<Command>> getCommandes() async {
    List<Command> commands = [];
    try {
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
          Command comand = Command.fromJson(i);
          // coms.add(comand);
          commands.add(comand);
        }
      });

      return commands;
    } catch (e) {
      debugPrint("$logTrace error $e");
      return [];
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
      getCommandes().then((value) {
        debugPrint("$logTrace val $value");
        setState(() {
          coms = value;
          _selected = List<bool>.generate(value.length, (int index) => false);
        });
      });
    });

    RefreshTokenData.loadToken().then((value) {
      debugPrint("$logTrace rtokenLoaded $value");
      setState(() {
        rToken = value;
      });
    });

    // _selected = List<bool>.generate(coms.length, (int index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 2),
        appBar: MyAppBar(
          selection: 1,
          callback: () {},
        ),
        body: ListView(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: UIData.btnAlert,
                  ),
                  onPressed: () {
                    debugPrint("$logTrace ${coms.length}");
                    // getCommandes().then((value) {
                    //   debugPrint("$logTrace val $value");
                    // });
                  },
                  icon: const Icon(Icons.download_for_offline_outlined),
                  label: const Text("Get")),
            ),
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
                        Icons.shopping_cart,
                        size: 50,
                        color: UIData.logoTitleColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      "Commandes",
                      style: TextData.titlePageStyle,
                    ),
                    Text("Liste de tous les commandes",
                        style: TextData.subtitlePageStyle)
                  ],
                )
              ],
            )),
            Card(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 40,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 85, 84, 84)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Center(
                            child: Text(
                                "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} à ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}")),
                      ),
                    ),
                    // const Icon(Icons.calendar_today_sharp),
                    IconButton(
                        onPressed: () {
                          print("sort commandes");
                        },
                        icon: const Icon(Icons.sort_sharp))
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        radioElement(0, "AUJOURD'HUI"),
                        radioElement(2, "7 DERNIERS JOURS"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        radioElement(1, "HIER"),
                        radioElement(3, "30 DERNIERS JOURS")
                      ],
                    )
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: coms.isNotEmpty
                          ? ListView.builder(
                              itemCount: coms.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(coms[index].id),
                                );
                              })
                          : const Text("no data")),
                ),
              ]),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
      ),
      onWillPop: () {
        throw showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Quiter"),
                content: const Text("Vous allez Quiter l'Application?"),
                actions: [
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: UIData.btnSuccess,
                      ),
                      onPressed: () {
                        print("oui");
                        Navigator.pop(context);
                        exit(0);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Oui")),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: UIData.btnAlert,
                      ),
                      onPressed: () {
                        print("non");
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.sledding_sharp),
                      label: const Text("Non")),
                ],
              );
            });
      },
    );
  }

  DataTable _createDataTable(List<Command> commands) {
    return DataTable(
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
      columns: _createColumns(),
      rows: _createRows(commands),
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
      //     tooltip: 'commandes id',
      //     onSort: (columnIndex, _) {
      //       setState(() {
      //         _currentSortColumn = columnIndex;
      //         if (_isSortAsc) {
      //           _commandes.sort((a, b) => b['id'].compareTo(a['id']));
      //         } else {
      //           _commandes.sort((a, b) => a['id'].compareTo(b['id']));
      //         }
      //         _isSortAsc = !_isSortAsc;
      //       });
      //     }
      //     ),
      const DataColumn(label: Text('numero')),
      const DataColumn(label: Text('Date')),
      const DataColumn(label: Text('Montant total'))
    ];
  }

  List<DataRow> _createRows(List<Command> commands) {
    return commands
        .asMap()
        .map((index, commande) => MapEntry(
            index,
            DataRow(
                cells: [
                  // DataCell(Text('#' + commandes['id'].toString(),
                  //     style: const TextStyle(fontWeight: FontWeight.bold))),
                  // DataCell(Text(commandes['numero'])),
                  // DataCell(Text(commandes['date'])),
                  // DataCell(Text(commandes['total']))
                  DataCell(Text(commande.code.toString())),
                  DataCell(Text(commande.createdAt)),
                  DataCell(Text(commande.totalPrice.toString())),
                ],
                selected: _selected[index],
                onSelectChanged: (bool? selected) {
                  setState(() {
                    _selected[index] = selected!;
                  });
                })))
        .values
        .toList();
  }

  Widget radioElement(int i, String s) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: UIData.colorPrincipal.shade500,
          borderRadius: const BorderRadius.all(Radius.circular(20.0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              maxRadius: 10,
              backgroundColor: Colors.white,
              child: Radio(
                value: i,
                groupValue: _radioDelai,
                onChanged: (int? value) {
                  setState(() => _radioDelai = value!);
                  print(_radioDelai);
                },
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            s,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
