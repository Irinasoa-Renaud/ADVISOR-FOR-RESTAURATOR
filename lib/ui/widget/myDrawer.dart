import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menu_advisor/models/restaurant.dart';

import 'package:menu_advisor/utils/dependences.dart';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  final int selection;
  const MyDrawer({Key? key, required this.selection}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

String userDataFileName = "user_data.txt";
String userDataFileContent = ".";

class _MyDrawerState extends State<MyDrawer> {
  String username = "UserName";
  String aToken = "", rToken = "";

  String restoName = "";
  String restoLogo = "";
  String restoId = "";

  @override
  void initState() {
    UserData.loadUser().then((value) {
      setState(() {
        // debugPrint("$logTrace before decode ${value.toString()}");
        // debugPrint(
        //     "$logTrace user_data.txt-> ${json.decode(value)['user']['name']['first']}");
        User user = User.fromJson(json.decode(value)['user']);
        username = user.name.first;
        debugPrint(
            "$logTrace usernama $username  favoriteResto: ${user.favoriteRestaurants}");
      });
      RestoData.loadResto().then((value) {
        Restaurant resto = Restaurant.fromJson(json.decode(value)[0]);
        setState(() {
          restoName = resto.name;
          restoLogo = resto.logo;
          restoId = resto.id;
        });
      });
      AccessTokenData.loadToken().then((value) {
        debugPrint("$logTrace rtokenLoaded $value");
        setState(() {
          aToken = value;
        });
        RefreshTokenData.loadToken().then((value) {
          debugPrint("$logTrace rtokenLoaded $value");
          setState(() {
            rToken = value;
            // rToken = "";
          });
        });
      });
    });
    if (mounted) super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int select = widget.selection;
    var _myDrawerHeader = Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: 60, child: Image.asset(UIData.logo)),
          Row(
            children: const [
              Text("Menu",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 25)),
              Text("Advisor",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.normal,
                      fontSize: 25))
            ],
          )
        ]),
        CircleAvatar(
          backgroundColor: Colors.grey,
          maxRadius: 30,
          child: !restoLogo.contains("data:image")
              ? ClipOval(
                  child: restoLogo.contains("http")
                      ? Image.network(
                          restoLogo,
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
          backgroundImage: restoLogo.contains("data:image")
              ? MemoryImage(Tools.stringToImg(restoLogo))
              : null,
        ),
        Text(
          restoName == "" ? "Nom du resto" : restoName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "RESTAURATEUR",
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(username,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Deconnection"),
                        content: const Text("Vous allez etre deconnecté?"),
                        actions: [
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: UIData.btnSuccess,
                              ),
                              onPressed: () {
                                print("oui");
                                if (Auth.logOut()) {
                                  debugPrint("$logTrace loged out");
                                  MyToast.showSuccess("Deconnecté");
                                  Navigator.popAndPushNamed(
                                      context, RoutePage.loginPage);
                                } else {
                                  Navigator.pop(context);
                                }
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
              icon: const Icon(Icons.exit_to_app_sharp))
        ])
      ],
    );

    _launch(String url) async {
      if (!await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        // headers: <String, String>{'my_header_key': 'my_header_value'},
      )) {
        MyToast.showAlert("Impossible d'ouvrir l'url:$url");
        throw "Impossible d'ouvrir l'url:$url";
      }
    }

    Widget _myDrawerContent(icon, titre, page, number) {
      return Card(
          child: ListTile(
        selected: select == number ? true : false,
        leading: Icon(
          icon,
          color: select == number ? UIData.colorPrincipal : Colors.grey,
        ),
        title: Text(
          titre,
          style: TextData.textStyle1,
        ),
        onTap: () {
          if (select == number) {
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
            if (page != "/maPage") {
              Navigator.of(context).pushNamed(page);
            } else {
              _launch("https://advisor.voirlemenu.fr/restaurants/$restoId");
            }
          }
        },
      ));
    }

    return Drawer(
      child: ListView(
        children: [
          _myDrawerHeader,
          _myDrawerContent(
              Icons.dashboard, "Dashboard", RoutePage.dashboardPage, 1),
          _myDrawerContent(Icons.shopping_cart_outlined, "Commandes",
              RoutePage.commandesPage, 2),
          _myDrawerContent(
              Icons.restaurant, "Restaurants", RoutePage.restaurantPage, 3),
          _myDrawerContent(Icons.fastfood, "Plats", RoutePage.platsPage, 4),
          _myDrawerContent(Icons.menu_book, "Menus", RoutePage.menuPage, 5),
          _myDrawerContent(Icons.list, "Types", RoutePage.typePage, 6),
          _myDrawerContent(Icons.view_module, "Accompagnements",
              RoutePage.accompagnementPage, 7),
          _myDrawerContent(
              Icons.qr_code_scanner, "QR Code", RoutePage.qrPage, 8),
          _myDrawerContent(FontAwesomeIcons.truck, "Simulation de livraison",
              RoutePage.simulationLivraisonPage, 9),
          _myDrawerContent(Icons.card_giftcard, "Plats recommandés",
              RoutePage.platsRecommandedPage, 10),
          _myDrawerContent(Icons.pages, "Voir ma page", RoutePage.maPage, 11)
        ],
      ),
    );
  }
}
