import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:menu_advisor/models/price.dart';
import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

import 'package:path/path.dart';

class ModifAccompagnementPage extends StatefulWidget {
  const ModifAccompagnementPage({Key? key}) : super(key: key);

  @override
  _ModifAccompagnementPageState createState() =>
      _ModifAccompagnementPageState();
}

class _ModifAccompagnementPageState extends State<ModifAccompagnementPage> {
  final _formKey = GlobalKey<FormState>();
  bool phtNonContractuel = true;
  bool statut = true;
  bool dispo = true;

  UpdateAccompagnementArgs args = UpdateAccompagnementArgs.vide();

  String token = "";

  String nom = "";
  String prix = "";
  bool processing = false;

  File? _imageFile;
  final _picker = ImagePicker();

  UpdateAccompagnementFields accompagnementFields =
      UpdateAccompagnementFields.vide();

  bool updateProcessing = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(this.context)!.settings.arguments
            as UpdateAccompagnementArgs;
        token = args.token;
        getAccompagnementById(args.accompagnementId, args.token);
      });
    });

    super.initState();
  }

  Future<void> getAccompagnementById(String id, String token) async {
    setState(() {
      processing = true;
    });
    var url = Uri.parse(Api.acompagnement + "/$id");
    try {
      var response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      var jsonData = json.decode(response.body);
      setState(() {
        processing = false;
        accompagnementFields = UpdateAccompagnementFields.fromJson(jsonData);
      });
    } catch (e) {
      debugPrint("$logTrace erreur $e");
      setState(() {
        processing = false;
      });
    }
  }

  Future<bool> modifierAccompagnement(String nom, String prix, String restoId,
      String imageURL, String id, bool obligatory) async {
    Map<String, dynamic> body = {
      "_id": id,
      "name": json.encode(nom),
      // "isObligatory": json.encode(obligatory),
      // "priority": json.encode(0),
      "price": json.encode({"amount": prix, "currency": "eur"}),
      "imageURL": imageURL,
      // "restaurant": restoId,
      // "field": json.encode([]),
      // "livraison": json.encode({}),
    };

    setState(() {
      updateProcessing = true;
    });

    var url = Uri.parse(Api.acompagnement + "/$id");
    try {
      var response = await http.put(url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${args.token}',
          },
          body: body);
      setState(() {
        updateProcessing = false;
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("$logTrace erreur:$e");
      setState(() {
        updateProcessing = false;
      });
      return false;
    }
  }

  // Future getImageGalerie() async {
  //   final ImagePicker _picker = ImagePicker();
  //   final dir = await path_provider.getTemporaryDirectory();
  //   var imageFile = await _picker.pickImage(source: ImageSource.gallery);
  //   final targetPath = dir.absolute.path + "/temp-" + basename(imageFile!.path);
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     imageFile.absolute.path,
  //     targetPath,
  //     minWidth: 2300,
  //     minHeight: 1500,
  //     quality: 80,
  //   );
  //   setState(() {
  //     // _image=imageFile;
  //     _imageFile = result;
  //   });
  // }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // Future getImageCamera() async {
  //   final ImagePicker _picker = ImagePicker();
  //   final dir = await path_provider.getTemporaryDirectory();
  //   var imageFile = await _picker.pickImage(source: ImageSource.camera);
  //   final targetPath = dir.absolute.path + "/temp-" + basename(imageFile.path);
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     imageFile.absolute.path,
  //     targetPath,
  //     minWidth: 2300,
  //     minHeight: 1500,
  //     quality: 90,
  //   );
  //   setState(() {
  //     // _image=imageFile;
  //     _imageFile = result;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    args =
        ModalRoute.of(context)!.settings.arguments as UpdateAccompagnementArgs;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Modifier un accompagnement",
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
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
                          initialValue: args.nom,
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
                              icon: Icon(Icons.text_fields),
                              border: OutlineInputBorder()),
                        )
                      ]),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Prix",
                          style: TextData.textStyle1,
                        ),
                        TextFormField(
                          initialValue: "${args.prix.amount}",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entrer le prix SVP';
                            } else {
                              setState(() {
                                prix = value;
                              });
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.euro),
                              border: OutlineInputBorder()),
                        )
                      ]),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Image",
                          style: TextData.textStyle1,
                        ),
                        Center(
                          child: SizedBox.square(
                            dimension: 200,
                            child: DottedBorder(
                                child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Image",
                                    style: TextData.textStyle1,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.cloud_upload,
                                      size: 50,
                                    ),
                                    onPressed: () async =>
                                        _pickImageFromGallery(),
                                  ),
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 100,
                                      child: _imageFile != null
                                          ? Image.file(_imageFile!)
                                          : accompagnementFields.imageURL != ""
                                              ? Image.memory(
                                                  Tools.stringToImg(
                                                      args.imageURL),
                                                )
                                              : Image.asset(
                                                  UIData.placeholder,
                                                ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ),
                        ),
                      ]),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: UIData.btnAlert),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text("ANNULER")),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: UIData.btnSuccess),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                String imageData = _imageFile != null
                                    ? "data:image/${_imageFile!.path.split(".").last};base64,${Tools.imgToString(_imageFile!)}"
                                    : args.imageURL;

                                RestoData.loadResto().then((value) {
                                  modifierAccompagnement(
                                          nom,
                                          prix,
                                          json.decode(value)[0]['_id'],
                                          imageData,
                                          args.accompagnementId,
                                          false)
                                      .then((value) {
                                    if (value) {
                                      MyToast.showSuccess(
                                          "Accompagnement modifié avec succès");
                                      Navigator.popAndPushNamed(context,
                                          RoutePage.accompagnementPage);
                                    } else {
                                      MyToast.showAlert(
                                          "Erreur lors du modification");
                                    }
                                  });
                                });
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: updateProcessing
                                ? Container(
                                    padding: const EdgeInsets.all(5),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ))
                                : const Text("ENREGISTRER")),
                      ]),
                )
              ],
            ),
          ),
          processing
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
}

class UpdateAccompagnementArgs {
  final String token;
  final String restoId;
  final String accompagnementId;
  final String imageURL;
  final Price prix;
  final String nom;
  UpdateAccompagnementArgs(this.token, this.restoId, this.accompagnementId,
      this.imageURL, this.prix, this.nom);
  factory UpdateAccompagnementArgs.fromJson(dynamic json) {
    return UpdateAccompagnementArgs(json['token'], json['restoId'],
        json['accompagnementId'], json['imageURL'], json['prix'], json['nom']);
  }
  factory UpdateAccompagnementArgs.vide() {
    return UpdateAccompagnementArgs("", "", "", "", Price(0, "eur"), "");
  }
}

class UpdateAccompagnementFields {
  final String nom;
  final Price prix;
  final String imageURL;
  final bool isObligatory;
  UpdateAccompagnementFields(
      this.nom, this.prix, this.imageURL, this.isObligatory);

  factory UpdateAccompagnementFields.fromJson(dynamic json) {
    return UpdateAccompagnementFields(
        json['name'] ?? "",
        Price.fromJson(json['price']),
        json['imageURL'] ?? "",
        json['isObligatory'] ?? false);
  }

  factory UpdateAccompagnementFields.vide() {
    return UpdateAccompagnementFields("", Price(0, "eur"), "", false);
  }
}
