import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/models/food.dart';

import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

class AjoutMenuPage extends StatefulWidget {
  const AjoutMenuPage({Key? key}) : super(key: key);

  @override
  _AjoutMenuPageState createState() => _AjoutMenuPageState();
}

class _AjoutMenuPageState extends State<AjoutMenuPage> {
  final formKey = GlobalKey<FormState>();

  final dialogFormKey = GlobalKey<FormState>();
  // TextEditingController dialogTitre = TextEditingController(),
  //     dialogMaxOption = TextEditingController();

  String dialogTitre = "", dialogMaxOption = "";
  bool dialogObligatoire = false;

  int typeMenu = 0;
  List<Titre> titresMenu = [];

  List<String> noms = [];

  List<Food> plats = [];

  List<dynamic> source = [
    // {'value': 'var', 'display': 'Vary'}
  ];

  String titrePlat = "";
  int maxOption = 0;

  String selected(List<dynamic> selection) {
    String val = "";
    for (var i in selection) {
      val += i.toString() + ",";
    }
    debugPrint("$logTrace val:$val");
    return val;
  }

  List<Widget> titres(List<Titre> titres) {
    return titres
        .asMap()
        .map((index, t) => MapEntry(
            index,
            GestureDetector(
              onTap: () {
                setState(() {
                  dialogTitre = t.nom;
                  dialogMaxOption = t.maxOption.toString();
                  // dialogObligatoire = t.Obligatoire;
                });
                // Navigator.pushNamed(context, RoutePage.ajoutMenuTitlePage,
                //     arguments: MenuTitleArgs(t, source, _myMultiSelectVal));

                showDialog(
                  context: context,
                  builder: (ctx) => Form(
                    key: dialogFormKey,
                    child: AlertDialog(
                      title: const Text('Ajouter un titre'),
                      content: Column(
                        children: [
                          SizedBox(
                              width: 200,
                              child: TextFormField(
                                // controller: dialogTitre,
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'Entrer le titre';
                                //   }
                                //   return null;
                                // },
                                onChanged: (val) {
                                  setState(() {
                                    dialogTitre = val;
                                  });
                                },
                                initialValue: titresMenu[index].nom,
                                decoration: const InputDecoration(
                                    hintText: "Titre",
                                    border: OutlineInputBorder()),
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                              width: 200,
                              child: TextFormField(
                                // controller: dialogMaxOption,
                                initialValue:
                                    titresMenu[index].maxOption.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() {
                                    dialogMaxOption = val;
                                  });
                                },
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'Entrer une valeur';
                                //   }
                                //   return null;
                                // },
                                decoration: const InputDecoration(
                                    hintText: "Max Options",
                                    border: OutlineInputBorder()),
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: 200,
                            child: _multipleSelectLng(),
                          ),
                          SizedBox(
                              width: 200,
                              child: Row(
                                children: [
                                  const Text(
                                    "Obligatoire",
                                    style: TextData.textStyle1,
                                  ),
                                  Switch(
                                    value: dialogObligatoire,
                                    onChanged: (val) {
                                      setState(() {
                                        print(val);
                                        dialogObligatoire = val;
                                      });
                                    },
                                  ),
                                ],
                              ))
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            // if (dialogFormKey.currentState!.validate()) {
                            setState(() {
                              titresMenu[index] =
                                  // titresMenu.add(
                                  Titre(
                                      dialogTitre,
                                      int.tryParse(dialogMaxOption)!,
                                      selected(_myMultiSelectVal),
                                      dialogObligatoire
                                      // )
                                      );
                              print(titresMenu[index].nom);
                            });
                            Navigator.of(ctx).pop();
                            // }
                          },
                          child: const Text('Enregistrer'),
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                child: Row(children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      width: 60,
                      child: Text(
                        t.nom,
                        style: const TextStyle(overflow: TextOverflow.fade),
                      )),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      width: 50,
                      child: Text(
                        t.maxOption.toString(),
                        style: const TextStyle(overflow: TextOverflow.fade),
                      )),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      width: 110,
                      child: Text(
                        t.plat,
                        style: const TextStyle(overflow: TextOverflow.fade),
                      )),
                  if (index == titresMenu.length - 1)
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            print(index);
                            print(titres.toString());
                            titres.removeAt(index);
                            print(titres.toString());
                          });
                        })
                ]),
              ),
            )))
        .values
        .toList();
  }

  List _myMultiSelectVal = [];

  String token = "";
  Future<void> getFoods(String restoId) async {
    debugPrint("$logTrace getFoods()");
    List<Food> foodS = [];
    // ${id}?lang=fr
    var url = Uri.parse(Api.foods +
        "?lang=fr" +
        (restoId != "" ? '&filter={"restaurant":"$restoId"}' : '&filter={}'));
    try {
      debugPrint("$logTrace url food $url");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
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
        plats = foodS;
      });
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {});
    }
  }

  MultiSelectFormField _multipleSelectLng() {
    return MultiSelectFormField(
      autovalidate: AutovalidateMode.disabled,
      chipBackGroundColor: UIData.colorPrincipal,
      chipLabelStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      dialogTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      checkBoxActiveColor: UIData.colorPrincipal,
      checkBoxCheckColor: Colors.white,
      dialogShapeBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      title: const Text(
        " Plats",
        style: TextData.textButtonStyle1,
      ),
      validator: (value) {
        if (value == null || value.length == 0) {
          return 'Selectionner au moins une langue SVP';
        }
        return null;
      },
      dataSource: source,
      textField: 'display',
      valueField: 'value',
      okButtonLabel: 'VALIDER',
      cancelButtonLabel: 'ANNULER',
      hintWidget: const Text('Selectionner un ou plusieurs'),
      initialValue: _myMultiSelectVal,
      onSaved: (value) {
        if (value == null) return;
        setState(() {
          _myMultiSelectVal = value;
          debugPrint("$logTrace selected:${_myMultiSelectVal.toString()}");
        });
      },
    );
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        token = ModalRoute.of(context)!.settings.arguments as String;
      });
    });
    RestoData.loadResto()
        .then((value) => getFoods(json.decode(value)[0]['_id']).then((value) {
              for (Food i in plats) {
                source
                    .add({'value': i.name.substring(0, 2), 'display': i.name});
              }
              debugPrint("$logTrace source $source");
            }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Ajouter un menu"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: ListView(children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nom",
                  style: TextData.textStyle1,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: "Nom", border: OutlineInputBorder()),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Type",
                  style: TextData.textStyle1,
                ),
                DropdownButtonFormField(
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    value: 1,
                    items: const [
                      DropdownMenuItem(
                        child: Text(
                          'Par plat',
                          style: TextData.textStyle1,
                        ),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text('Prix fixe', style: TextData.textStyle1),
                        value: 2,
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        typeMenu = (value as int?)!;
                      });
                      // print(value);
                    }),
              ],
            ),
          ),
          Container(
              child: typeMenu == 2
                  ? Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Prix",
                            style: TextData.textStyle1,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.euro),
                                hintText: "Prix",
                                border: OutlineInputBorder()),
                          )
                        ],
                      ),
                    )
                  : null),
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: UIData.btnDefault,
              ),
              icon: const Icon(Icons.add_circle),
              label: const Text("AJOUTER DES TITRES"),
              onPressed: () {
                String val = Random().nextInt(5).toString();
                setState(() {
                  debugPrint("$logTrace noms: $noms");
                  // noms.add(val);
                  titresMenu.add(Titre('Nom', 0, "", false));
                });
              },
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width - 5,
              child: Column(children: titres(titresMenu))),
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Description",
                  style: TextData.textStyle1,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(primary: UIData.btnAlert),
                    icon: const Icon(Icons.cancel),
                    label: const Text("ANNULER")),
                ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(primary: UIData.btnSuccess),
                    icon: const Icon(Icons.save),
                    label: const Text("ENREGISTRER")),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class Titre {
  final String nom;
  final int maxOption;
  final String plat;
  final bool Obligatoire;
  // final Food plat;
  Titre(
    this.nom,
    this.maxOption,
    this.plat,
    this.Obligatoire,
    //  this.plat
  );
}
