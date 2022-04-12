import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:menu_advisor/models/restaurant.dart';
import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

import 'package:path/path.dart';

class AjoutAccompagnementPage extends StatefulWidget {
  const AjoutAccompagnementPage({Key? key}) : super(key: key);

  @override
  _AjoutAccompagnementPageState createState() =>
      _AjoutAccompagnementPageState();
}

class _AjoutAccompagnementPageState extends State<AjoutAccompagnementPage> {
  final _formKey = GlobalKey<FormState>();
  bool phtNonContractuel = true;
  bool statut = true;
  bool dispo = true;

  NewAccompagnementArgs args = NewAccompagnementArgs.vide();

  String token = "";

  String nom = "";
  String prix = "";
  bool processing = false;

  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(this.context)!.settings.arguments
            as NewAccompagnementArgs;
        token = args.token;
      });
    });

    super.initState();
  }

  Future<bool> ajouterAccompagnement(
      String nom, String prix, String idResto, String imageURL) async {
    setState(() {
      processing = true;
    });
    debugPrint("$logTrace nom:$nom,prix:$prix,image:$imageURL");
    Map<String, dynamic> body = {
      "name": nom,
      "restaurant": idResto,
      "field": json.encode([]),
      "valueField": json.encode({}),
      "livraison": json.encode({}),
      "imageURL": imageURL,
      "price": json.encode({"amount": prix, "currency": "eur"}),
    };
    var url = Uri.parse(Api.acompagnement);
    try {
      var response = await http.post(url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body);
      debugPrint("$logTrace data :${response.body} token:$token");
      setState(() {
        processing = false;
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
      // return false;
    } catch (e) {
      debugPrint("$logTrace erreur $e");
      setState(() {
        processing = false;
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Ajouter un accompagnement",
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: Form(
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
                          icon: Icon(Icons.euro), border: OutlineInputBorder()),
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
                                onPressed: () async => _pickImageFromGallery(),
                              ),
                              Card(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  height: 100,
                                  child: _imageFile != null
                                      ? Image.file(_imageFile!)
                                      : Image.asset(UIData.placeholder),
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
                        style:
                            ElevatedButton.styleFrom(primary: UIData.btnAlert),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text("ANNULER")),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: UIData.btnSuccess),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _imageFile != null) {
                            String imageData =
                                "data:image/${_imageFile!.path.split(".").last};base64,${Tools.imgToString(_imageFile!)}";

                            RestoData.loadResto().then((value) {
                              ajouterAccompagnement(nom, prix,
                                      json.decode(value)[0]['_id'], imageData)
                                  .then((value) {
                                if (value) {
                                  MyToast.showSuccess(
                                      "Accompagnement ajouté avec succès!");
                                  print(args.returnPage + "00");
                                  if (args.returnPage ==
                                      RoutePage.ajoutPlatPage) {
                                    // Navigator.popAndPushNamed(
                                    //     context, args.returnPage);
                                    Navigator.pop(context);
                                    print(args.returnPage);
                                  } else if (args.returnPage ==
                                      RoutePage.accompagnementPage) {
                                    Navigator.popAndPushNamed(
                                        context, RoutePage.accompagnementPage);
                                  }
                                } else {
                                  MyToast.showAlert(
                                      "Erreur lors de l'ajout de l'accompagnement!");
                                }
                              });
                            });
                          } else if (_imageFile == null) {
                            MyToast.showAlert(
                                "Veillez selectionner une image SVP");
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: processing
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
    );
  }
}

class NewAccompagnementArgs {
  final String returnPage;
  final String token;
  final String restoId;
  NewAccompagnementArgs(this.token, this.restoId, this.returnPage);
  factory NewAccompagnementArgs.vide() {
    return NewAccompagnementArgs("", "", RoutePage.accompagnementPage);
  }
}
