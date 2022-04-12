import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/models/foodTypes.dart';

import 'package:menu_advisor/utils/dependences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QrPage extends StatefulWidget {
  const QrPage({Key? key}) : super(key: key);

  @override
  _QrPageState createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  final formKey = GlobalKey<FormState>();
  String restoId = "";
  List _myLanguages = [];
  late String _myLanguagesResult;
  bool priceless = false;
  bool cm = false, all = false;
  String langue = "fr";
  String aToken = "", rToken = "";
  Uint8List? img;
  bool processing = false;
  static List<dynamic> languagesSource = [
    {'value': 'fr', 'display': 'Français'},
    {'value': 'en', 'display': 'Anglais'},
    {'value': 'ja', 'display': 'Japonais'},
    {'value': 'zh-CN', 'display': 'Chinois'},
    {'value': 'it', 'display': 'Italien'},
    {'value': 'es', 'display': 'Espagnol'},
    {'value': 'ru', 'display': 'Russe'},
    {'value': 'ko', 'display': 'Coréen'},
    {'value': 'nl', 'display': 'Néerlandais'},
    {'value': 'de', 'display': 'Allemand'},
    {'value': 'pt', 'display': 'Portugais'},
    {'value': 'hi', 'display': 'Indien'},
    {'value': 'ar', 'display': 'Arabe'},
  ];

  static Map<String, String> menuItems = {
    'fr': 'Français',
    'en': 'Anglais',
    'ja': 'Japonais',
    'zh-CN': 'Chinois',
    'it': 'Italien',
    'es': 'Espagnol',
    'ru': 'Russe',
    'ko': 'Coréen',
    'nl': 'Néerlandais',
    'de': 'Allemand',
    'pt': 'Portugais',
    'hi': 'Indien',
    'ar': 'Arabe',
  };

  List<DropdownMenuItem<String>> dropdownItems = menuItems
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

  @override
  void initState() {
    super.initState();
    _myLanguagesResult = '';

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
      });
      RestoData.loadResto().then((value) {
        setState(() {
          restoId = json.decode(value)[0]['_id'];
        });
      });
    });
  }

  Future<void> genereQR() async {
    debugPrint('$logTrace qr $priceless,$langue,$_myLanguages,$cm');
    setState(() {
      processing = true;
    });
    // restaurants/61d838c2ccd9b20031d8a743?option=priceless&language=ja&multiple:["en","it","fr"]
    var url = !cm
        ? Uri.parse(Api.qrcode +
            "?language=$langue&restaurant=$restoId&priceless=$priceless&multipleLanguage=[]")
        : Uri.parse(Api.qrcode +
            "?language=$langue&restaurant=$restoId&priceless=$priceless&multipleLanguage=$_myLanguagesResult");
    // ? Uri.parse(Api.qrcode +
    //     "?language=$langue&restaurant=620e80ccee7cce0960305c87&priceless=$priceless&multipleLanguage=[]")
    // : Uri.parse(Api.qrcode +
    //     "?language=$langue&restaurant=620e80ccee7cce0960305c87&priceless=$priceless&multipleLanguage=$_myLanguagesResult");
    debugPrint("$logTrace url: $url");
    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $aToken',
        },
      );
      debugPrint(
          "$logTrace response: ${response.body},code:${response.statusCode},ReasonPhrase:${response.reasonPhrase}");
      String uri = response.body;
      Uint8List _bytes = base64.decode(uri.split(',').last);
      setState(() {
        img = _bytes;
        processing = false;
      });
      // return _bytes;
    } catch (e) {
      setState(() {
        processing = false;
      });
      debugPrint("$logTrace erreur $e");
      MyToast.showAlert("Une erreur est survenu!");
      // return ;
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
        " Languages",
        style: TextData.textButtonStyle1,
      ),
      validator: (value) {
        if (value == null || value.length == 0) {
          return 'Selectionner au moins une langue SVP';
        }
        return null;
      },
      dataSource: languagesSource,
      textField: 'display',
      valueField: 'value',
      okButtonLabel: 'VALIDER',
      cancelButtonLabel: 'ANNULER',
      hintWidget: const Text('Selectionner un ou plusieurs'),
      initialValue: _myLanguages,
      onSaved: (value) {
        if (value == null) return;
        setState(() {
          _myLanguages = value;
          _myLanguagesResult = _myLanguages.toString();
          debugPrint("$_myLanguages __ $_myLanguagesResult");
          all = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        throw Navigator.pushNamed(context, RoutePage.commandesPage);
      },
      child: Scaffold(
        backgroundColor: UIData.pageBG,
        drawer: const MyDrawer(selection: 8),
        appBar: MyAppBar(
            selection: 0,
            callback: () async {
              _myLanguagesResult = '';

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
                });
                RestoData.loadResto().then((value) {
                  setState(() {
                    restoId = json.decode(value)[0]['_id'];
                  });
                });
              });
            }),
        // ignore: unnecessary_const
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
                        Icons.qr_code_scanner,
                        size: 50,
                        color: UIData.logoTitleColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      "Code QR",
                      style: TextData.titlePageStyle,
                    ),
                    Text("Generateur de code QR",
                        style: TextData.subtitlePageStyle)
                  ],
                )
              ],
            )),
            Card(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: const [
                        Icon(
                          FontAwesomeIcons.language,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Langue",
                          style: TextData.textStyle1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: DropdownButtonFormField(
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        value: 'fr',
                        items: dropdownItems,
                        onChanged: (value) {
                          setState(() {
                            langue = value.toString();
                          });
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: priceless,
                          onChanged: (val) {
                            print(val);
                            setState(() {
                              priceless = val;
                            });
                          }),
                      const Text(
                        "Sans Prix",
                        style: TextData.textStyle1,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                        value: cm,
                        onChanged: (val) {
                          print(val);
                          setState(() {
                            cm = val;
                          });
                        },
                      ),
                      const Text(
                        "Choix de langue multiple",
                        style: TextData.textStyle1,
                      ),
                    ],
                  ),
                  if (cm == true)
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Langues multiples",
                            style: TextData.textStyle1,
                          ),
                          Form(key: formKey, child: _multipleSelectLng()),
                          // Text("data"),
                          Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    List<dynamic> langues = [];
                                    for (var lng in languagesSource) {
                                      langues.add(lng["value"]);
                                    }
                                    // langues.add(languagesSource[1]["value"]);
                                    _myLanguages = langues;

                                    _myLanguagesResult =
                                        _myLanguages.toString();
                                    debugPrint("$_myLanguagesResult _ ");
                                    all = true;
                                    MyToast.showSuccess(
                                        "Vous avez selectionner tous les langues");
                                  });
                                },
                                child: const Text(
                                    "SELECTIONNER TOUT LES LANGUES")),
                          ),
                        ],
                      ),
                    ),
                  SizedBox.square(
                    dimension: 200,
                    child: DottedBorder(
                      strokeWidth: 1,
                      color: Colors.black,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10.0),
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Center(
                          child: processing
                              ? const CircularProgressIndicator()
                              : img != null
                                  ? Stack(
                                      children: [
                                        Image.memory(img!),
                                        Center(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            child: ClipOval(
                                                child: Stack(
                                              children: [
                                                Container(
                                                  color: Colors.white,
                                                ),
                                                Center(
                                                  child: Image.asset(
                                                    UIData.logo,
                                                    width: 25,
                                                    height: 25,
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                          Text(
                                            "Apercu",
                                            style: TextData.textStyle1,
                                          ),
                                          Icon(Icons.image),
                                        ]),
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              primary: UIData.btnSuccess),
                          onPressed: () {
                            genereQR();
                          },
                          icon: const Icon(Icons.screen_share_outlined),
                          label: const Text(
                            "Generer",
                            style: TextData.textButtonStyle1,
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              primary: processing
                                  ? Colors.grey
                                  : img == null
                                      ? Colors.grey
                                      : UIData.colorPrincipal),
                          onPressed: () async {
                            if (img != null && !processing) {
                              final dir = await getExternalStorageDirectory();
                              final myImagePathData =
                                  dir!.path + "/$restoId.png";
                              File imageFileData = File(myImagePathData);
                              if (!await imageFileData.exists()) {
                                imageFileData.create(recursive: true);
                              }
                              try {
                                imageFileData
                                    .writeAsBytes(img!,
                                        mode: FileMode.write, flush: true)
                                    .then((value) {
                                  debugPrint("$logTrace Telechargé $value");
                                  MyToast.showSuccess(
                                      "Fichier enregistré sous le nom de $value");
                                });
                              } catch (e) {
                                debugPrint("$logTrace $e");
                              }

                              // print("Telecharger");
                              // img != null
                              //     ? File('QrCode.jpg').writeAsBytes(img!)
                              //     : null;
                            }
                          },
                          icon: const Icon(Icons.download),
                          label: const Text(
                            "Telecharger",
                            style: TextData.textButtonStyle1,
                          ),
                        ),
                      ])
                ],
              ),
            )
          ],
        ),
        floatingActionButton: const MyFloatingActionButton(),
      ),
    );
  }
}
