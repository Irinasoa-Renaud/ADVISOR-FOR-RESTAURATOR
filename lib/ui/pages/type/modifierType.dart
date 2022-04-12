import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/foodTypes.dart';
import 'package:menu_advisor/models/menu.dart';
import 'package:menu_advisor/models/restaurant.dart';

import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

class ModifTypePage extends StatefulWidget {
  const ModifTypePage({Key? key}) : super(key: key);

  @override
  _ModifTypePageState createState() => _ModifTypePageState();
}

class _ModifTypePageState extends State<ModifTypePage> {
  final _formKey = GlobalKey<FormState>();
  ModifTypeArgs args = ModifTypeArgs("token", "", "", 0);
  String nom = "";
  bool processing = false;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(context)!.settings.arguments as ModifTypeArgs;
      });
    });
    super.initState();
  }

  Future<bool> modifierType(String name) async {
    name = name == "" ? args.name : name;
    Map<String, dynamic> body = {
      "name": json.encode({"fr": name}),
      "priority": args.priority.toString()
    };

    debugPrint("$logTrace ajoutType $name,${args.id},$name");
    setState(() {
      processing = true;
    });
    var url = Uri.parse(Api.foodTypes + "/${args.id}");
    try {
      var response = await http.put(
        url,
        headers: {
          // 'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${args.token}',
        },
        body: body,
      );
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace $jsonData");
      setState(() {
        processing = false;
      });
      if (jsonData["message"] == "Food type successfully updated") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("$logTrace erreur $e");
      MyToast.showAlert("Une erreur est survenu!");
      setState(() {
        processing = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as ModifTypeArgs;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Modifier un Type"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: ListView(
            children: [
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
                      initialValue: args.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrer le nom SVP';
                        } else {
                          setState(() {
                            nom = value;
                          });
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          hintText: "Nom", border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style:
                            ElevatedButton.styleFrom(primary: UIData.btnAlert),
                        icon: const Icon(Icons.cancel),
                        label: const Text("ANNULER")),
                    ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            RestoData.loadResto().then((value) {
                              debugPrint(
                                  "$logTrace value ${json.decode(value)[0]}");
                              modifierType(nom).then((value) {
                                if (value == true) {
                                  MyToast.showSuccess(
                                      "Type modifié avec succes");
                                  Navigator.popAndPushNamed(
                                      context, RoutePage.typePage);
                                } else {
                                  MyToast.showAlert(
                                      "Une erreur est survenu,\nVeuillez reessayer plus tard!");
                                }
                              });
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: UIData.btnSuccess),
                        icon: const Icon(Icons.save),
                        label: processing
                            ? Container(
                                padding: const EdgeInsets.all(5),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                            : const Text("ENREGISTRER")),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ModifTypeArgs {
  String token;
  String id;
  String name;
  int priority;
  ModifTypeArgs(this.token, this.id, this.name, this.priority);
}
