import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:menu_advisor/utils/dependences.dart';

import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:path/path.dart';

class AjoutPlatPage extends StatefulWidget {
  const AjoutPlatPage({Key? key}) : super(key: key);

  @override
  _AjoutPlatPageState createState() => _AjoutPlatPageState();
}

class _AjoutPlatPageState extends State<AjoutPlatPage> {
  bool phtNonContractuel = true;
  bool statut = true;
  bool dispo = true;

  File? _imageFile;
  final _picker = ImagePicker();

  String aToken = "", rToken = "";

  NewFoodArgs args = NewFoodArgs.vide();

  Future<void> _pickImageFromCamera() async {
    final dir = await path_provider.getTemporaryDirectory();
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final dir = await path_provider.getTemporaryDirectory();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(this.context)!.settings.arguments as NewFoodArgs;
        aToken = args.token;
      });
    });
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
        title: const Text("Ajouter un plat"),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Nom",
                style: TextData.textStyle1,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.text_fields),
                    border: OutlineInputBorder()),
              )
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Type",
                style: TextData.textStyle1,
              ),
              DropdownButtonFormField(
                  value: 1,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(
                      child: Text(
                        'Francais',
                        style: TextData.textStyle1,
                      ),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text('Anglais', style: TextData.textStyle1),
                      value: 2,
                    ),
                    DropdownMenuItem(
                      child: Text('Espagnol', style: TextData.textStyle1),
                      value: 3,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      // langue = value as int?;
                    });
                    print(value);
                  }),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Prix",
                style: TextData.textStyle1,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.euro), border: OutlineInputBorder()),
              )
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Selectionner une image'),
                                content: SizedBox.square(
                                  dimension: 150,
                                  child: Column(
                                    children: [
                                      ListTile(
                                          leading: const Icon(Icons.camera),
                                          title: const Text("Camera"),
                                          onTap: () async =>
                                              _pickImageFromCamera().then(
                                                  (value) =>
                                                      Navigator.pop(context))),
                                      ListTile(
                                          leading: const Icon(Icons.image),
                                          title: const Text("Galerie"),
                                          onTap: () async =>
                                              _pickImageFromGallery().then(
                                                  (value) =>
                                                      Navigator.pop(context)))
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Annuler'),
                                  )
                                ],
                              ),
                            );
                          },
                          // onPressed: () async => _pickImageFromCamera(),
                        ),
                        Card(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 100,
                            child: _imageFile != null
                                ? Image.file(_imageFile!)
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
              children: [
                Switch(
                    value: phtNonContractuel,
                    onChanged: (val) {
                      print(val);
                      setState(() {
                        phtNonContractuel = val;
                      });
                    }),
                const Text(
                  "Photo non Contractuel",
                  style: TextData.textStyle1,
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                Switch(
                    value: statut,
                    onChanged: (val) {
                      print(val);
                      setState(() {
                        statut = val;
                      });
                    }),
                const Text(
                  "Statut",
                  style: TextData.textStyle1,
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Attribut",
                style: TextData.textStyle1,
              ),
              DropdownButtonFormField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  value: 1,
                  items: const [
                    DropdownMenuItem(
                      child: Text(
                        'Francais',
                        style: TextData.textStyle1,
                      ),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text('Anglais', style: TextData.textStyle1),
                      value: 2,
                    ),
                    DropdownMenuItem(
                      child: Text('Espagnol', style: TextData.textStyle1),
                      value: 3,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      // langue = value as int?;
                    });
                    print(value);
                  }),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Allergene",
                style: TextData.textStyle1,
              ),
              DropdownButtonFormField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  value: 1,
                  items: const [
                    DropdownMenuItem(
                      child: Text(
                        'Francais',
                        style: TextData.textStyle1,
                      ),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text('Anglais', style: TextData.textStyle1),
                      value: 2,
                    ),
                    DropdownMenuItem(
                      child: Text('Espagnol', style: TextData.textStyle1),
                      value: 3,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      // langue = value as int?;
                    });
                    print(value);
                  }),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child:
                ExpansionTile(title: const Text("Accompagnement"), children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle),
                    label: const Text("Ajouter"),
                    style: ElevatedButton.styleFrom(primary: UIData.btnDefault),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, RoutePage.ajoutAccompagnementPage,
                          arguments: NewAccompagnementArgs(args.token,
                              args.restoId, RoutePage.ajoutPlatPage));
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text(
                      "AJOUTER UN \n ACCOMPAGNEMENT",
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width - 30, 40),
                        primary: UIData.colorPrincipal),
                  ),
                ],
              )
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                Switch(
                    value: dispo,
                    onChanged: (val) {
                      print(val);
                      setState(() {
                        dispo = val;
                      });
                    }),
                const Text(
                  "Disponible",
                  style: TextData.textStyle1,
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Description",
                style: TextData.textStyle1,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(icon: Icon(Icons.description)),
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
                      style: ElevatedButton.styleFrom(primary: UIData.btnAlert),
                      onPressed: () {},
                      icon: const Icon(Icons.cancel),
                      label: const Text("Annuler")),
                  ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(primary: UIData.btnSuccess),
                      onPressed: () {},
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"))
                ]),
          )
        ],
      ),
    );
  }
}

class NewFoodArgs {
  final String token;
  final String restoId;
  NewFoodArgs(this.token, this.restoId);
  factory NewFoodArgs.vide() {
    return NewFoodArgs("", "");
  }
}
