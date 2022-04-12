import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/restaurant.dart';

import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

class AjoutTypePage extends StatefulWidget {
  const AjoutTypePage({Key? key}) : super(key: key);

  @override
  _AjoutTypePageState createState() => _AjoutTypePageState();
}

class _AjoutTypePageState extends State<AjoutTypePage> {
  final _formKey = GlobalKey<FormState>();
  var token = "";
  String nom = "";
  bool processing = false;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        token = ModalRoute.of(context)!.settings.arguments as String;
      });
    });
    super.initState();
  }

  Future<bool> ajouterType(String name, dynamic resto) async {
    debugPrint("$logTrace ajoutType");
    Map<String, dynamic> body = {
      "name": json.encode({"fr": name}),
      "restaurant": json.encode(resto)
    };
    setState(() {
      processing = true;
    });
    var url = Uri.parse(Api.foodTypes + "/");
    try {
      var response = await http.post(
        url,
        headers: {
          // 'Content-Type': 'application/json',
          // 'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      var jsonData = json.decode(response.body);
      debugPrint("$logTrace $jsonData");
      debugPrint("$logTrace ${body.runtimeType},${resto.runtimeType}");
      setState(() {
        processing = false;
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
      // return false; //
    } catch (e) {
      debugPrint("$logTrace erreur $e");
      setState(() {
        processing = false;
      });
      return false;
    }
  }

  // 6234258962dcf70012706352

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
        title: const Text("Ajouter un Type"),
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
                        onPressed: () => Navigator.pop(context),
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
                              ajouterType(nom, json.decode(value)[0])
                                  .then((value) {
                                if (value) {
                                  MyToast.showSuccess(
                                      "Type ajouté avec succès!");
                                  Navigator.popAndPushNamed(
                                      context, RoutePage.typePage);
                                } else {
                                  MyToast.showAlert(
                                      "Erreur pendant l'ajout du type");
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
