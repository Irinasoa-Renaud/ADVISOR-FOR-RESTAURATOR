import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/foodTypes.dart';
import 'package:menu_advisor/models/price.dart';

import 'package:menu_advisor/utils/dependences.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;

class DetailCommandPage extends StatefulWidget {
  const DetailCommandPage({Key? key}) : super(key: key);

  @override
  _DetailCommandPageState createState() => _DetailCommandPageState();
}

class _DetailCommandPageState extends State<DetailCommandPage> {
  bool _hasCallSupport = false;
  bool processing = false;
  bool validationProcessing = false;
  bool revokeProcessing = false;
  var args = DetailCommandArgs("", "", "");
  DetailCommandFields command = DetailCommandFields.vide();
  Future<void> getCommandById(String id, String token) async {
    debugPrint("$logTrace getCommandById");
    setState(() {
      processing = true;
    });
    var url = Uri.parse(Api.commandes + "/$id");
    debugPrint("$logTrace url:$url");
    try {
      setState(() {
        processing = true;
      });
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace jsonData $jsonData");
      setState(() {
        command = DetailCommandFields.fromJson(jsonData);
        debugPrint("$logTrace command:$command");
        processing = false;
      });
    } catch (e) {
      debugPrint("$logTrace error $e");
      setState(() {
        processing = false;
      });
      MyToast.showAlert("Une erreur s'est produite");
      Navigator.pop(context);
    }
  }

  Future<bool> validate(String commandId, String aToken) async {
    setState(() {
      validationProcessing = true;
    });
    var url = Uri.parse(Api.commandes + "/$commandId/validate");
    try {
      var response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      if (response.statusCode == 200) {
        MyToast.showSuccess("Commande validée");
        setState(() {
          validationProcessing = false;
        });
        getCommandById(args.id, args.token);
        return true;
      } else {
        setState(() {
          validationProcessing = false;
        });
        return false;
      }
    } catch (e) {
      debugPrint("$logTrace erreur validation $e");
      MyToast.showAlert("Erreur lors de la validation");
      setState(() {
        validationProcessing = false;
      });
      return false;
    }
  }

  Future<bool> revoke(String commandId, String aToken) async {
    setState(() {
      revokeProcessing = true;
    });
    var url = Uri.parse(Api.commandes + "/$commandId/revoke");
    try {
      var response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      if (response.statusCode == 200) {
        MyToast.showSuccess("Commande refusée");
        setState(() {
          revokeProcessing = false;
        });
        getCommandById(args.id, args.token);
        return true;
      } else {
        setState(() {
          revokeProcessing = false;
        });
        return false;
      }
    } catch (e) {
      debugPrint("$logTrace erreur validation $e");
      MyToast.showAlert("Erreur lors du refus de la commande");
      setState(() {
        revokeProcessing = false;
      });
      return false;
    }
  }

  Future<void> _call(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(context)!.settings.arguments as DetailCommandArgs;
        getCommandById(args.id, args.token);
      });
    });
    canLaunch('tel:123').then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: !command.validated
              ? !command.revoked
                  ? [
                      IconButton(
                          onPressed: () {
                            // getCommandById(args.id, args.token);
                            validate(args.id, args.token);
                          },
                          icon: const Icon(Icons.check)),
                      IconButton(
                          onPressed: () {
                            revoke(args.id, args.token);
                            // getCommandById(args.id, args.token);
                          },
                          icon: const Icon(Icons.cancel_outlined))
                    ]
                  : []
              : [],
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(command.validated == true
              ? "Detail de la commande"
              : "Detail de \nla commande"),
        ),
        body: Stack(
          children: [
            body(),
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
                : validationProcessing
                    ? Center(
                        child: SizedBox.square(
                          dimension: 100,
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(118, 158, 158, 158),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromARGB(120, 0, 0, 0))
                                  ]),
                              padding: const EdgeInsets.all(30),
                              child: const CircularProgressIndicator()),
                        ),
                      )
                    : Container(),
            processing || validationProcessing
                ? SizedBox.expand(
                    child: Container(color: const Color.fromARGB(132, 0, 0, 0)),
                  )
                : Container(),
          ],
        ));
  }

  List<Widget> Items(List<Item> commandItems) {
    return commandItems
        .asMap()
        .map((index, commande) => MapEntry(
            index,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Text("${commande.quantity} X "),
                          const SizedBox(
                            width: 10,
                          ),
                          CircleAvatar(
                            backgroundImage: MemoryImage(
                                Tools.stringToImg(commande.imageURL)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text(commande.name.fr),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.euro,
                                    size: 15,
                                  ),
                                  Text("${commande.price!.amount / 100}")
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.euro,
                          size: 15,
                        ),
                        Text(
                            "${(commande.price!.amount) / 100 * commande.quantity}"),
                      ],
                    )
                  ],
                ),
                Column(
                  children: options(commande.options),
                ),
                commandItems.isEmpty ? const Divider() : Container(),
              ],
            )))
        .values
        .toList();
  }

  List<Widget> options(List<Option> options) {
    return options
        .asMap()
        .map((index, option) => MapEntry(
              index,
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: optionItems(option.options),
                    )
                  ],
                ),
              ),
            ))
        .values
        .toList();
  }

  List<Widget> optionItems(List<OptionItem> optionItems) {
    return optionItems
        .asMap()
        .map((index, option) => MapEntry(
            index,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Text("${option.quantity} X "),
                      const SizedBox(
                        width: 10,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Text(option.name),
                          Row(
                            children: [
                              const Icon(
                                Icons.euro,
                                size: 15,
                              ),
                              Text("${option.prix!.amount / 100}")
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.euro,
                      size: 15,
                    ),
                    Text("${(option.prix!.amount) / 100 * option.quantity}"),
                  ],
                )
              ],
            )))
        .values
        .toList();
  }

  Widget body() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ListView(
        children: [
          const Divider(),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                SizedBox.square(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: CircleAvatar(
                      child: !command.restoLogo.contains("data:image")
                          ? ClipOval(
                              child: command.restoLogo.contains("http")
                                  ? Image.network(
                                      command.restoLogo,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      UIData.placeholder,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ))
                          : null,
                      backgroundImage: command.restoLogo.contains("data:image")
                          ? MemoryImage(Tools.stringToImg(command.restoLogo))
                          : null,
                    ),
                  ),
                  dimension: 100,
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        command.restoName != ""
                            ? command.restoName
                            : "Nom du restaurant",
                        style: TextData.textStyle1,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.place),
                          Text(
                            command.adresse != ""
                                ? (command.adresse.split(",").first +
                                    "\n" +
                                    command.adresse.split(",").elementAt(1))
                                : "Adresse",
                            style: const TextStyle(
                                fontSize: 15, overflow: TextOverflow.fade),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.phone),
                          GestureDetector(
                            onTap: () {
                              if (command.phoneNumber != "") {
                                _hasCallSupport
                                    ? _call(command.phoneNumber)
                                    : null;
                              }
                            },
                            child: Text(
                              command.phoneNumber != ""
                                  ? command.phoneNumber
                                  : "phone Number",
                              style: const TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(),
          const SizedBox(
            height: 20,
          ),
          const Divider(),
          SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "ID de commande: ",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      command.idCommande != 0
                          ? command.idCommande.toString().padLeft(6, '0')
                          : "000000",
                      style:
                          const TextStyle(color: UIData.btnAlert, fontSize: 20),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: command.hasDelivery ? 80 : 2,
                      decoration: BoxDecoration(
                          color: command.hasDelivery
                              ? command.commandType == "delivery"
                                  ? Colors.green
                                  : Colors.green
                              : Colors.transparent,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: Center(
                        child: Text(
                          command.hasDelivery
                              ? command.commandType == "delivery"
                                  ? "Livraison déjà effectuer"
                                  : "La commande déjà emporter"
                              : "",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                          color: !command.validated
                              ? !command.revoked
                                  ? const Color.fromARGB(255, 204, 207, 6)
                                  : Colors.red
                              : Colors.green,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: Center(
                        child: Text(
                          !command.validated
                              ? !command.revoked
                                  ? "En Attente"
                                  : "Refusée"
                              : "Validée",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Liste des plats commandés",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              // nombre x image plat test/E10.0 E30.0
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    const Divider(),
                    Column(
                      children:
                          command.items.isNotEmpty ? Items(command.items) : [],
                    ),
                    const Divider(),
                  ],
                ),
              )
            ],
          ),
          const Divider(),
          SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sous-total de produits"),
                    Row(
                      children: [
                        const Icon(
                          Icons.euro,
                          size: 16,
                        ),
                        // Text(command.totalPriceSansRemise),
                        Text(int.tryParse(command.totalPriceSansRemise) != null
                            ? "${int.tryParse(command.totalPriceSansRemise)! / 100}"
                            : "0") //FormatException (FormatException: Invalid radix-10 number (at character 1) 0.0
                      ],
                    )
                  ],
                ),
                Container(
                    child: command.commandType == "delivery"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Frais de livraison"),
                              Row(
                                children: [
                                  Text(
                                    command.totalFraisLivraison,
                                    style: const TextStyle(
                                        color: UIData.btnAlert, fontSize: 20),
                                  ),
                                  const Icon(
                                    Icons.euro,
                                    size: 20,
                                    color: UIData.btnAlert,
                                  )
                                ],
                              )
                            ],
                          )
                        : null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total"),
                    Row(
                      children: [
                        Text(
                          "${command.totalPrice / 100}",
                          style: const TextStyle(
                              color: UIData.btnAlert, fontSize: 20),
                        ),
                        const Icon(
                          Icons.euro,
                          size: 20,
                          color: UIData.btnAlert,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Type de commande",
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  command.commandType == "on_site"
                      ? "SUR PLACE"
                      : command.commandType == "takeaway"
                          ? "À EMPORTER"
                          : "LIVRAISON",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detail",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  command.priceless ? "Sans prix" : "Avec prix",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                )
              ],
            ),
          ),
          const Divider(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nom et prenom"),
                  Text("${command.nom} ${command.prenom}"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Telephone"),
                  Text(command.userPhoneNumber),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                child: args.type == "delivery"
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Adresse de livraison"),
                              Text(command.adresseLivraison != ""
                                  ? command.adresseLivraison
                                          .split(",")
                                          .elementAt(0) +
                                      "\n" +
                                      command.adresseLivraison
                                          .split(",")
                                          .elementAt(1)
                                  : "Adresse"),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Appartement"),
                              Text(command.appartement),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Etage"),
                              Text("${command.etage}"),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Type de livraison"),
                              Text(command.livraisonOption == "behind_the_door"
                                  ? "Derrière la porte"
                                  : command.livraisonOption == "on_the_door"
                                      ? "Devant la porte"
                                      : "À l'extérieur"),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Date et heure \nde livraison"),
                              Text(
                                !command.shipAsSoonAsPossible
                                    ? Tools.dateTimeToStrFr(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                command.retrait)) +
                                        "\n" +
                                        (DateTime.fromMillisecondsSinceEpoch(
                                                    command.retrait)
                                                .toString()
                                                .split(".")
                                                .first)
                                            .split(" ")
                                            .last
                                    : "Le plus vite possible",
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Date de \nla commande"),
                  Text(
                    command.updatedAt == ""
                        ? ("${Tools.dateTimeToStrFr(DateTime.parse(command.createdAt))}\n ${command.createdAt.split(".").first.split("T").last}")
                        : ("${Tools.dateTimeToStrFr(DateTime.parse(command.updatedAt))}\n ${command.updatedAt.split(".").first.split("T").last}"),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: args.type == "delivery"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Paiement"),
                            Text((command.paiementLivraison
                                    ? "A la livraison"
                                    : "Avant la livraison") +
                                "-\n" +
                                (command.payed ? "Payé" : "Non payé")),
                          ],
                        )
                      : null),
              const Divider(),
              Container(
                width: MediaQuery.of(context).size.width - 10,
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Commentaire",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          decoration: TextDecoration.underline, fontSize: 15),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(
                        command.comment == ""
                            ? "Aucun Commentaire"
                            : command.comment,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DetailCommandArgs {
  final String id;
  final String token;
  final String type;
  // final DetailCommandFields fields;
  DetailCommandArgs(
    this.token,
    this.id,
    this.type,
    // this.fields,
  );
}

class DetailCommandFields {
  final String restoLogo;
  final String restoName;
  final String adresse;
  final String phoneNumber;
  final int idCommande;
  final bool validated;
  final bool revoked;
  final String totalPriceSansRemise;
  final int totalPrice;
  final String commandType;
  bool priceless;
  final String nom;
  final String prenom;
  final String userPhoneNumber;
  final String updatedAt;
  final String createdAt;
  final int retrait;
  final String adresseLivraison;
  final String appartement;
  final int etage;
  final String livraisonOption;
  // final String dateHeureLivraison;
  final bool paiementLivraison;
  final bool payed;
  final String totalFraisLivraison;
  final bool shipAsSoonAsPossible;
  final bool hasDelivery;
  final String comment;

  final List<Item> items;

  DetailCommandFields(
    this.restoLogo,
    this.restoName,
    this.adresse,
    this.phoneNumber,
    this.idCommande,
    this.validated,
    this.revoked,
    this.totalPriceSansRemise,
    this.totalPrice,
    this.commandType,
    this.priceless,
    this.nom,
    this.prenom,
    this.userPhoneNumber,
    this.updatedAt,
    this.createdAt,
    this.retrait,
    this.adresseLivraison,
    this.appartement,
    this.etage,
    this.livraisonOption,
    // this.dateHeureLivraison,
    this.paiementLivraison,
    this.payed,
    this.totalFraisLivraison,
    this.items,
    this.shipAsSoonAsPossible,
    this.hasDelivery,
    this.comment,
  );
  factory DetailCommandFields.fromJson(dynamic json) {
    return DetailCommandFields(
        json['restaurant']['logo'] ?? "",
        json['restaurant']['name'] ?? "",
        json['restaurant']['address'] ?? "",
        json['restaurant']['phoneNumber'] ?? "",
        json['code'] ?? 0,
        json['validated'] ?? false,
        json['revoked'] ?? false,
        json['totalPriceSansRemise'] ?? "",
        json['totalPrice'] ?? 0,
        json['commandType'] ?? "",
        json['priceless'] ?? false,
        json['relatedUser'] != null
            ? json['relatedUser']['name']['first']
            : json['customer']['name'],
        json['relatedUser'] != null ? json['relatedUser']['name']['last'] : "",
        json['relatedUser'] != null
            ? json['relatedUser']['phoneNumber']
            : json['customer']['phoneNumber'],
        json['updatedAt'] ?? "",
        json['createdAt'] ?? "",
        json['shippingTime'] ?? 0,
        json['shippingAddress'] ?? "",
        json['appartement'] ?? "",
        json['etage'] ?? 0,
        json['optionLivraison'] ?? "",
        // json['shippingTime'] ?? 0,
        json['paiementLivraison'] ?? false,
        json['payed']['status'] ?? false,
        json['totalDiscount'] ?? "",
        json['items'] != null ? Item.list(json['items']) : [],
        json['shipAsSoonAsPossible'] ?? false,
        json['hasDelivery'] ?? false,
        json['comment'] ?? "");
  }

  factory DetailCommandFields.vide() {
    return DetailCommandFields(
        "",
        "",
        "",
        "",
        0,
        false,
        false,
        "0.0",
        0,
        "",
        true,
        "nom",
        "prenom",
        "PhoneNumber",
        "0000-00-00 00:00:00",
        "0000-00-00 00:00:00",
        0,
        "",
        "",
        0,
        "",
        // "",
        false,
        false,
        "",
        [],
        false,
        false,
        "");
  }
}

class Item {
  final Price? price;
  final FoodTypeName name;
  final String imageURL;
  final int quantity;
  final List<Option> options;
  Item(this.price, this.name, this.imageURL, this.quantity, this.options);

  factory Item.fromJson(dynamic json) {
    return Item(
        json['item']['price'] == null
            ? Price.vide()
            : Price.fromJson(json['item']['price']),
        json['item']['name'] != null
            ? FoodTypeName.fromJson(json['item']['name'])
            : FoodTypeName(""),
        json['item']['imageURL'] ?? "",
        json['quantity'] ?? 0,
        json['options'] == null ? [] : Option.list(json['options'])); //vide
  }

  static List<Item> list(dynamic json) {
    List<Item> items = [];
    for (var i in json) {
      items.add(Item.fromJson(i));
    }
    return items;
  }
}

class Option {
  final String title;
  final List<OptionItem> options;
  Option(this.title, this.options);

  factory Option.fromJson(dynamic json) {
    return Option(json['title'] ?? "", OptionItem.list(json['items']));
  }
  static List<Option> list(dynamic json) {
    List<Option> items = [];
    for (var i in json) {
      items.add(Option.fromJson(i));
    }
    return items;
  }
}

class OptionItem {
  final Price? prix;
  final String name;
  final String imageURL;
  final int quantity;
  OptionItem(this.prix, this.name, this.imageURL, this.quantity);

  factory OptionItem.fromJson(dynamic json) {
    return OptionItem(
        json['price'] == null ? Price.vide() : Price.fromJson(json['price']),
        json['item']['name'] ?? "",
        json['item']['imageURL'] ?? "",
        json['quantity'] ?? 0);
  }

  static List<OptionItem> list(dynamic json) {
    List<OptionItem> items = [];
    for (var i in json) {
      items.add(OptionItem.fromJson(i));
    }
    return items;
  }
}
