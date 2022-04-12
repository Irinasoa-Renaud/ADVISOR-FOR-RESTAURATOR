import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/message.dart';

import 'package:menu_advisor/utils/dependences.dart';
import 'package:http/http.dart' as http;

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late int _currentSortColumn = 0;
  bool _isSortAsc = true;
  List<bool> _selected = [];
  List<Message> messages = [];
  String aToken = "";
  String rToken = "";
  bool processing = false;
  bool readProcessing = false;

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
          User user = User.fromJson(json.decode(value)['user']);
          getMessages(user.id).then((value) => _selected =
              List<bool>.generate(messages.length, (int index) => false));
        });
      });
    });
  }

  Future<bool> getMessages(String userId) async {
    List<Message> mess = [];
    setState(() {
      // userId = "";
      processing = true;
    });
    var url = Uri.parse(Api.messages +
        (userId != "" ? '?filter={"target":"$userId"}' : '?filter={}'));
    try {
      // debugPrint("$logTrace $url");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data ${jsonData.toString()}");
      for (var i in jsonData) {
        Message m = Message.fromJson(i);
        setState(() {
          mess.add(m);
        });
      }
      setState(() {
        processing = false;
        messages = mess;
      });
      return true;
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        processing = false;
      });
      return false;
    }
  }

  Future<bool> readMessages(String messageId) async {
    setState(() {
      // userId = "";
      readProcessing = true;
    });
    var url = Uri.parse(Api.messages + "/$messageId/read");
    try {
      // debugPrint("$logTrace $url");
      var response = await http.put(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data ${jsonData.toString()}");
      setState(() {
        readProcessing = false;
      });
      return true;
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        readProcessing = false;
      });
      return false;
    }
  }

  Future<bool> readAllMessages() async {
    setState(() {
      // userId = "";
      readProcessing = true;
    });
    var url = Uri.parse(Api.messages + "/readAll");
    try {
      // debugPrint("$logTrace $url");
      var response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data ${jsonData.toString()}");
      setState(() {
        readProcessing = false;
      });
      return true;
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        readProcessing = false;
      });
      return false;
    }
  }

  Future<bool> deleteMessages(String messageId) async {
    setState(() {
      // userId = "";
      readProcessing = true;
    });
    var url = Uri.parse(Api.messages + "/$messageId");
    try {
      // debugPrint("$logTrace $url");
      var response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data ${jsonData.toString()}");
      setState(() {
        readProcessing = false;
      });
      return true;
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        readProcessing = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: UIData.pageBG,
      drawer: const MyDrawer(selection: 0),
      appBar: MyAppBar(
          selection: 0,
          callback: () {
            debugPrint("$logTrace getMessage");
            UserData.loadUser().then((value) {
              User user = User.fromJson(json.decode(value)['user']);
              getMessages(user.id);
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
                      child: Hero(
                        tag: "mess",
                        child: Card(
                          margin: EdgeInsets.all(15),
                          elevation: 10,
                          child: Icon(
                            Icons.markunread,
                            size: 50,
                            color: UIData.logoTitleColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: const [
                      Text(
                        "Messages",
                        style: TextData.titlePageStyle,
                      ),
                      Text("Liste des messages recu",
                          style: TextData.subtitlePageStyle)
                    ],
                  )
                ],
              )),
              Card(
                  child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: messages.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _createDataTable(messages))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                SizedBox(
                                    width: w - 20,
                                    child: _createDataTableVide()),
                                SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: processing
                                        ? const CircularProgressIndicator()
                                        : const Text(
                                            "Aucune Message",
                                            style: TextData.subtitlePageStyle,
                                          ),
                                  ),
                                )
                              ],
                            ),
                          )),
              ))
            ],
          ),
          readProcessing
              ? SizedBox.expand(
                  child: Container(color: const Color.fromARGB(132, 0, 0, 0)),
                )
              : Container(),
          readProcessing
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
        ],
      ),
    );
  }

  DataTable _createDataTableVide() {
    return DataTable(
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
      columns: _createColumns([]),
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

  Widget _createDataTable(List<Message> m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(right: 10),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(primary: UIData.btnSuccess),
            onPressed: () {
              readAllMessages().then((value) => value
                  ? MyToast.showSuccess("Messages lus")
                  : MyToast.showAlert("Une erreur est survenue!"));
            },
            icon: Icon(Icons.visibility),
            label: const Text("Marquer tous comme lus"),
          ),
        ),
        DataTable(
          sortColumnIndex: _currentSortColumn,
          sortAscending: _isSortAsc,
          columns: _createColumns(m),
          rows: _createRows(m),
          dividerThickness: 5,
          dataRowHeight: 90,
          showBottomBorder: true,
          headingTextStyle:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          headingRowColor: MaterialStateProperty.resolveWith(
              (states) => UIData.colorPrincipal),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns(List<Message> _m) {
    return [
      DataColumn(
          label: Text('Nom'),
          onSort: (columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isSortAsc) {
                _m.sort((a, b) => b.name.compareTo(a.name));
              } else {
                _m.sort((a, b) => a.name.compareTo(b.name));
              }
              _isSortAsc = !_isSortAsc;
            });
          }),
      DataColumn(
          label: Text("Message"),
          onSort: (columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isSortAsc) {
                _m.sort((a, b) => b.message.compareTo(a.message));
              } else {
                _m.sort((a, b) => a.message.compareTo(b.message));
              }
              _isSortAsc = !_isSortAsc;
            });
          }),
      const DataColumn(label: Text("Actions"))
    ];
  }

  List<DataRow> _createRows(List<Message> mess) {
    return mess
        .mapIndexed(
          (index, m) => DataRow(
              cells: [
                // DataCell(Text('#' + types['id'].toString(),
                //     style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(
                  m.name,
                  style: TextStyle(
                    fontWeight: !m.read ? FontWeight.bold : FontWeight.normal,
                  ),
                )),
                DataCell(Text(
                  m.message,
                  style: TextStyle(
                      fontWeight:
                          !m.read ? FontWeight.bold : FontWeight.normal),
                )),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: UIData.btnDefault),
                        child: const Icon(
                          Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Message de ${m.name}"),
                                  content: Text(m.message),
                                  actions: [
                                    ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          primary: UIData.btnSuccess,
                                        ),
                                        onPressed: () {
                                          debugPrint("$logTrace oui");
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.check),
                                        label: const Text("OK")),
                                    ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          primary: UIData.btnAlert,
                                        ),
                                        onPressed: () {
                                          readMessages(m.id).then((value) => value
                                              ? MyToast.showSuccess(
                                                  "Message lu")
                                              : MyToast.showAlert(
                                                  "Une erreur est survenue!"));
                                          debugPrint("$logTrace non");
                                          Navigator.popAndPushNamed(
                                              context, RoutePage.messagesPage);
                                        },
                                        icon: const Icon(
                                          Icons.mark_email_read,
                                        ),
                                        label: const Text("Marquer comme lu")),
                                  ],
                                );
                              });
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(primary: UIData.btnAlert),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Supprimer?"),
                                  content: const Text(
                                      "Êtes vous sûr de supprimer ce message"),
                                  actions: [
                                    ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          primary: UIData.btnAlert,
                                        ),
                                        onPressed: () {
                                          debugPrint("$logTrace oui");
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.cancel),
                                        label: const Text("Annuler")),
                                    ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          primary: UIData.btnSuccess,
                                        ),
                                        onPressed: () {
                                          deleteMessages(m.id).then((value) => value
                                              ? MyToast.showSuccess(
                                                  "Message supprimé avec succès")
                                              : MyToast.showAlert(
                                                  "Erreur lors du suppression"));
                                          debugPrint("$logTrace non");
                                          Navigator.popAndPushNamed(
                                              context, RoutePage.messagesPage);
                                        },
                                        icon: const Icon(
                                          Icons.check,
                                        ),
                                        label: const Text("Oui")),
                                  ],
                                );
                              });
                        },
                      ),
                    ],
                  ),
                )
              ],
              //  selected: _selected[index],
              //onSelectChanged: (bool? selected) {
              // setState(() {
              //   _selected[index] = selected!;
              //    print(_selected);
              //  });
              //},
              onLongPress: () {
                MyToast.showAlert(m.message);
              }),
        )
        .toList();
  }
}
