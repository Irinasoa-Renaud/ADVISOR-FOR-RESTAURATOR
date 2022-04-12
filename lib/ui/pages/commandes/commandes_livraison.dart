import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/restaurant.dart';
import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

class CommandesLivraisonPage extends StatefulWidget {
  const CommandesLivraisonPage({Key? key}) : super(key: key);

  @override
  _CommandesLivraisonPageState createState() => _CommandesLivraisonPageState();
}

class _CommandesLivraisonPageState extends State<CommandesLivraisonPage> {
  final TextEditingController _codeSearchController = TextEditingController(),
      _maxPrixSearchController = TextEditingController(),
      _minSearchController = TextEditingController();

  bool valide = false;

  String type = "";

  static Map<String, String> typeChoices = {
    'takeaway': 'À emporter',
    'on_site': 'Sur place',
    'delivery': 'Livraison',
  };

  List<DropdownMenuItem<String>> dropdownTypeChoices = typeChoices
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

  bool codeSearch = false,
      restoSearch = false,
      prixRangeSearch = false,
      valideSearch = false,
      typeSearch = false;

  List<Command> commandeFiltre(
      String code,
      String resto,
      List<String> prixRange,
      bool valide,
      String type,
      List<Command> commandesSource) {
    List<Command> commandes = [];

    if (codeSearch) {
      for (Command i in commandesSource) {
        if (i.code.toString().contains(code)) {
          commandes.add(i);
          // code != "" ? print(i.code) : null;
          print(i.type);
        }
      }
      print(commandes.length);
    } else if (prixRangeSearch) {
      if ((int.tryParse(prixRange[0]) != null) &&
          (int.tryParse(prixRange[1]) != null)) {
        for (Command i in commandesSource) {
          if (((int.tryParse(prixRange[0])!) < i.totalPrice / 100) &&
              ((int.tryParse(prixRange[1])!) > i.totalPrice / 100)) {
            commandes.add(i);
          }
        }
        print("taille:${commandes.length}");
      }
      // else {
      //   MyToast.showAlert("Entrer les valeurs SVP");
      // }
    } else if (typeSearch) {
      debugPrint("$logTrace selected_type:$type");
      for (Command i in commandesSource) {
        if (i.type == type) {
          commandes.add(i);
        }
      }
    } else if (valideSearch) {
      for (Command i in commandesSource) {
        if (i.validated == valide) {
          commandes.add(i);
          print("type:${i.type}");
        }
      }
    }

    return commandes;
  }

  List<Command> comsNow = [];
  List<Command> comsHier = [];
  List<Command> coms7jrs = [];
  List<Command> coms30jrs = [];
  List<Command> comsRange = [];
  List<Command> coms = [];

  String dateRange = "";
  void setdateRange(DateTime start, DateTime end) {
    setState(() {
      dateRange =
          "De ${start.day.toString().padLeft(2, "0")}-${start.month.toString().padLeft(2, "0")}-${start.year} à ${end.day.toString().padLeft(2, "0")}-${end.month.toString().padLeft(2, "0")}-${end.year}";
    });
  }

  DateTime now = DateTime.now();
  DateTime hier = DateTime.now().subtract(const Duration(days: 1));
  DateTime semaine = DateTime.now().subtract(const Duration(days: 7));
  DateTime mois = DateTime.now().subtract(const Duration(days: 50));

  late int _currentSortColumn = 0;
  bool _isSortAsc = true;
  List<bool> _selected = [];
  int _radioDelai = 5;
  String aToken = "";
  String rToken = "";

  bool processing = false;

  var url = Uri.parse(Api.commandes
      //  +
      //     '?type=takeaway&filter={"restaurant":"61e18c29669bbb405a3d2d8b"}'
      );
  Future<List<Command>> getCommandes(String restoId) async {
    setState(() {
      _radioDelai = 5;
      processing = true;
    });
    List<Command> commands = [];
    var url = Uri.parse(Api.commandes +
        "?type=delivery" +
        // (restoId != "" ? "&filter={restaurant:$restoId}" : "&filter={}"));
        (restoId != "" ? '&filter={"restaurant":"$restoId"}' : '&filter={}'));
    try {
      setState(() {
        processing = true;
      });
      debugPrint("$logTrace url:$url");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      // debugPrint("$logTrace data ${response.body.toString()}");
      setState(() {
        for (var i in jsonData) {
          debugPrint("$logTrace _id${i.runtimeType} ${['_id'].toString()}");
          Command comand = Command.fromJson(i);
          commands.add(comand);
        }
        coms = commands;
      });
      setState(() {
        processing = false;
      });
      return commands;
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        processing = false;
      });
      return [];
    }
  }

  @override
  void dispose() {
    _codeSearchController.dispose();
    _maxPrixSearchController.dispose();
    _minSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setdateRange(now, now);
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
      RestoData.loadResto().then((value) {
        Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
        getCommandes(resto.id).then((value) {
          // getCommandes("").then((value) {
          // debugPrint("$logTrace val $value");
          setState(() {
            coms = value;
            _selected = List<bool>.generate(value.length, (int index) => false);
          });
        });
      });
    });

    // _selected = List<bool>.generate(coms.length, (int index) => false);
  }

  List<Command> updateComsRange(
      List<Command> initial, DateTime start, DateTime end) {
    List<Command> coms = [];
    if (start.isAtSameMomentAs(end)) {
      for (Command c in initial) {
        // DateTime dateRetrait = DateTime.parse(c.createdAt.split("T").first);
        DateTime dateLivraison = DateTime.parse(c.dateRetrait.split("T").first);
        if ((dateLivraison.isAtSameMomentAs(start))) {
          coms.add(c);
        }
      }
    } else {
      for (Command c in initial) {
        // DateTime dateRetrait = DateTime.parse(c.createdAt.split("T").first);
        DateTime dateLivraison = DateTime.parse(c.dateRetrait.split("T").first);
        if ((dateLivraison.isAfter(start)) && (dateLivraison.isBefore(end))) {
          coms.add(c);
        }
      }
    }
    return coms;
  }

  List<DataRow> _createRows(List<Command> commands) {
    return commands
        .asMap()
        .map((index, commande) => MapEntry(
            index,
            DataRow(
                onLongPress: () {
                  Navigator.pushNamed(context, RoutePage.detailCommandPage,
                      arguments: DetailCommandArgs(
                          aToken, commande.id, commande.type));
                },
                cells: [
                  DataCell(Text(
                    commande.code.toString(),
                    style: TextStyle(
                        fontWeight: (commande.validated ||
                                commande.hasDelivery ||
                                commande.revoked)
                            ? FontWeight.normal
                            : FontWeight.bold),
                  )),
                  DataCell(Text(
                    "${Tools.dateTimeToStrFr(DateTime.parse(commande.createdAt))} ${commande.createdAt.split("T").last.split(".").first}",
                    style: TextStyle(
                        fontWeight: (commande.validated ||
                                commande.hasDelivery ||
                                commande.revoked)
                            ? FontWeight.normal
                            : FontWeight.bold),
                  )),
                  DataCell(Text(
                    "${commande.totalPrice / 100} €",
                    style: TextStyle(
                        fontWeight: (commande.validated ||
                                commande.hasDelivery ||
                                commande.revoked)
                            ? FontWeight.normal
                            : FontWeight.bold),
                  )),
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

  DataTable _createDataTableVide() {
    return DataTable(
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
      columns: const [
        DataColumn(label: Text('Numéro de\ncommande')),
        DataColumn(label: Text('Date de\nLivraison')),
        DataColumn(label: Text('Montant \ntotal'))
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

  Widget _createTable(List<Command> listCommands) {
    setState(() {
      listCommands = (codeSearch ||
              restoSearch ||
              prixRangeSearch ||
              valideSearch ||
              typeSearch)
          ? commandeFiltre(
              _codeSearchController.text,
              "resto",
              [
                _minSearchController.text,
                _maxPrixSearchController.text,
              ],
              valide,
              type,
              listCommands)
          : listCommands;
    });
    return listCommands.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _createDataTable(listCommands))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                _createDataTableVide(),
                SizedBox(
                  height: 200,
                  child: Center(
                    child: processing
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Aucune commande",
                            style: TextData.subtitlePageStyle,
                          ),
                  ),
                )
              ],
            ));
  }

  DataTable _createDataTable(List<Command> commands) {
    return DataTable(
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
      columns: const [
        DataColumn(label: Text('Numéro de\ncommande')),
        DataColumn(label: Text('Date de\nLivraison')),
        DataColumn(label: Text('Montant \ntotal'))
      ],
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: processing ? null : const MyDrawer(selection: 2),
        appBar: MyAppBar(
            selection: 2,
            callback: () {
              processing
                  ? null
                  // :
                  : RestoData.loadResto().then((value) {
                      Restaurant resto =
                          Restaurant.fromJson(json.decode(value)[0]);
                      getCommandes(resto.id).then((value) {
                        // getCommandes("").then((value) {
                        // debugPrint("$logTrace val $value");
                        setState(() {
                          coms = value;
                          _selected = List<bool>.generate(
                              value.length, (int index) => false);
                        });
                      });
                    });
            }
            // fonction: getCommandesfcn(),
            ),
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
                        FontAwesomeIcons.truck,
                        size: 40,
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
                    Text("Liste des commandes livraison",
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
                        child: Center(child: Text(dateRange)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          disabledColor: Colors.black45,
                          icon: const Icon(
                            FontAwesomeIcons.calendarAlt,
                          ),
                          onPressed: () {
                            processing
                                ? null
                                : showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime(2018),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)))
                                    .then((DateTimeRange? value) {
                                    if (value != null) {
                                      setdateRange(value.start, value.end);
                                      setState(() {
                                        comsRange = updateComsRange(
                                            coms, value.start, value.end);
                                        _radioDelai = 4;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            backgroundColor:
                                                UIData.colorPrincipal,
                                            content: Text("resultat pour " +
                                                value.duration.inDays
                                                    .toString() +
                                                " jours")),
                                      );
                                    }
                                  });
                          },
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.sort_sharp),
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                  child: const Text('Numero de commande'),
                                  onTap: () {
                                    setState(() {
                                      codeSearch = true;
                                      prixRangeSearch = false;
                                      valideSearch = false;
                                      typeSearch = false;
                                      print(codeSearch);
                                    });
                                  }),
                              // PopupMenuItem(
                              //     child: const Text('Restaurant'),
                              //     onTap: () {
                              //       print("Resto");
                              //     }),
                              PopupMenuItem(
                                child: Text('Prix'),
                                onTap: () {
                                  setState(() {
                                    prixRangeSearch = true;
                                    codeSearch = true;
                                    valideSearch = false;
                                    typeSearch = false;
                                  });
                                },
                              ),
                              PopupMenuItem(
                                child: Text('Validé'),
                                onTap: () {
                                  setState(() {
                                    valideSearch = true;

                                    codeSearch = false;
                                    prixRangeSearch = false;
                                    typeSearch = false;
                                  });
                                },
                              ),
                              PopupMenuItem(
                                child: Text('Type'),
                                onTap: () {
                                  setState(() {
                                    typeSearch = true;
                                    codeSearch = false;
                                    prixRangeSearch = false;
                                    valideSearch = false;
                                  });
                                },
                              )
                            ];
                          },
                        )
                      ],
                    )
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
                    ),
                  ],
                ),
                if (codeSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _codeSearchController,
                            showCursor: true,
                            decoration: const InputDecoration(
                                hintText: "Numero de commande",
                                border: UnderlineInputBorder()),
                            // onChanged: (value) {
                            // setState(() {
                            //   comsResut = commandeFiltre(
                            //       value, "resto", ["0", "0"], false, "type");
                            // });
                            // },
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                codeSearch = false;
                                _codeSearchController.clear();
                              });
                            },
                            icon: const Icon(Icons.close))
                      ],
                    ),
                  ),
                if (prixRangeSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 50,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _minSearchController,
                            showCursor: true,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.euro),
                                hintText: "Min Prix",
                                border: UnderlineInputBorder()),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 50,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _maxPrixSearchController,
                            showCursor: true,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.euro),
                                hintText: "Max Prix",
                                border: UnderlineInputBorder()),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                prixRangeSearch = false;
                                _maxPrixSearchController.clear();
                                _minSearchController.clear();
                              });
                            },
                            icon: const Icon(Icons.close))
                      ],
                    ),
                  ),
                if (valideSearch)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 200,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Valide"),
                            Switch(
                                value: valide,
                                onChanged: (val) {
                                  setState(() {
                                    valide = val;
                                  });
                                }),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    valideSearch = false;
                                  });
                                },
                                icon: const Icon(Icons.close))
                          ]),
                    ),
                  ),
                if (typeSearch)
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150,
                            child: DropdownButtonFormField(
                                hint: Text("data"),
                                value: 'takeaway',
                                items: dropdownTypeChoices,
                                onChanged: (value) {
                                  setState(() {
                                    type = value.toString();
                                  });
                                }),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  typeSearch = false;
                                });
                              },
                              icon: const Icon(Icons.close))
                        ],
                      ),
                    ),
                  ),
                _radioDelai == 0
                    ? _createTable(comsNow)
                    : _radioDelai == 1
                        ? _createTable(comsHier)
                        : _radioDelai == 2
                            ? _createTable(coms7jrs)
                            : _radioDelai == 3
                                ? _createTable(coms30jrs)
                                : _radioDelai == 4
                                    ? _createTable(comsRange)
                                    : _radioDelai == 5
                                        ? _createTable(coms)
                                        : _createDataTableVide()
              ]),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.get_app),
        //   onPressed: () => RestoData.loadResto()
        //       .then((value) => getCommandes(json.decode(value)[0]['_id'])),
        // ),
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
                  switch (value) {
                    case 0:
                      setdateRange(now, now);
                      setState(() {
                        comsNow = updateComsRange(coms, now, now);
                      });
                      break;
                    case 1:
                      setdateRange(hier, now);
                      setState(() {
                        comsHier = updateComsRange(coms, hier, now);
                      });
                      break;
                    case 2:
                      setdateRange(semaine, now);
                      setState(() {
                        coms7jrs = updateComsRange(coms, semaine, now);
                      });
                      break;
                    case 3:
                      setdateRange(mois, now);
                      setState(() {
                        coms30jrs = updateComsRange(coms, mois, now);
                      });
                      debugPrint(
                          "$logTrace 29:${updateComsRange(coms, mois, now).length}");
                      debugPrint("$logTrace 30:${coms30jrs.length}");
                      break;
                    default:
                  }
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
