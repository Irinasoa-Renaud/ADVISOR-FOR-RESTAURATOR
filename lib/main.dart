import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menu_advisor/ui/pages/SimulationLivraison/mapFullScreen.dart';

import 'package:menu_advisor/utils/dependences.dart';

import 'utils/test/testCalculDistance.dart';
import 'utils/test/testGooglePlace.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  RestoData.initRestoDataFile();
  AccessTokenData.initAccessTokenDataFile();
  RefreshTokenData.initRefreshTokenDataFile();
  UserData.initUserDataFile().then((value) {
    UserData.loadUser().then((value) {
      // if (value != "none") {
      if (value != "") {
        User user = User.fromJson(json.decode(value)['user']);
        String username = user.name.first;
        debugPrint("$logTrace runApp(username:$username");
        runApp(MyApp(username: username));
      } else {
        runApp(const MyApp(
          // username: "none",
          username: "",
        ));
      }

      FlutterNativeSplash.remove();
    });
  });

  // runApp(RoutesWidget());
  // runApp(MyDistanceApp());
}

class MyApp extends StatelessWidget {
  final String username;
  const MyApp({Key? key, required this.username}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPrint("$logTrace main");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu Advisor',
      theme: ThemeData(
        primarySwatch: UIData.colorPrincipal,
      ),
      initialRoute:
          // RoutePage.menuPage,
          //       // username == "none" ? RoutePage.loginPage : RoutePage.commandesPage,
          // username == "none" ? RoutePage.loginPage : RoutePage.menuPage,
          // username == "" ? RoutePage.loginPage : RoutePage.commandesPage,
          username == "" ? RoutePage.loginPage : RoutePage.menuPage,
      routes: <String, WidgetBuilder>{
        RoutePage.homePage: (BuildContext context) =>
            const MyHomePage(title: "Menu Advisor"),
        RoutePage.dashboardPage: (BuildContext context) =>
            const DashBoardPage(),
        RoutePage.qrPage: (BuildContext context) => const QrPage(),
        RoutePage.simulationLivraisonPage: (BuildContext context) =>
            const SimulationLivraisonPage(),
        RoutePage.messagesPage: (BuildContext context) => const MessagesPage(),
        RoutePage.platsPage: (BuildContext context) => const PlatsPage(),
        RoutePage.modifPlatPage: (BuildContext context) =>
            const ModifPlatPage(),
        RoutePage.ajoutPlatPage: (BuildContext context) =>
            const AjoutPlatPage(),
        RoutePage.ajoutMenuPage: (BuildContext context) =>
            const AjoutMenuPage(),
        RoutePage.accompagnementPage: (BuildContext context) =>
            const AccompagnementsPage(),
        RoutePage.ajoutAccompagnementPage: (BuildContext context) =>
            const AjoutAccompagnementPage(),
        RoutePage.restaurantPage: (BuildContext context) =>
            const RestaurantsPage(),
        RoutePage.menuPage: (BuildContext context) => const MenuPage(),
        RoutePage.typePage: (BuildContext context) => const TypePage(),
        RoutePage.modifTypePage: (BuildContext context) =>
            const ModifTypePage(),
        RoutePage.commandesPage: (BuildContext context) =>
            const CommandesPage(),
        RoutePage.platsRecommandedPage: (BuildContext context) =>
            const PlatsRecommandedPage(),
        RoutePage.recommanderPlatPage: (BuildContext context) =>
            const RecommanderPlatPage(),
        RoutePage.loginPage: (BuildContext context) => const LoginPage(),
        RoutePage.recupComptePage: (BuildContext context) =>
            const RecupComptePage(),
        RoutePage.emportedCommandePage: (BuildContext context) =>
            const EmportedCommandesPage(),
        RoutePage.surPlaceCommandePage: (BuildContext context) =>
            const CommandesSurPlacePage(),
        RoutePage.detailCommandPage: (BuildContext context) =>
            const DetailCommandPage(),
        RoutePage.modifMenuPage: (BuildContext context) =>
            const ModifMenuPage(),
        RoutePage.commandesLivraisonPage: (BuildContext context) =>
            const CommandesLivraisonPage(),
        RoutePage.ajoutTypePage: (BuildContext context) =>
            const AjoutTypePage(),
        RoutePage.modifAccompagnementPage: (BuildContext context) =>
            const ModifAccompagnementPage(),
        RoutePage.mapFullScreenPage: (BuildContext context) =>
            const MapFullScreen(),
      },

      // home: const MyHomePage(title: 'Menu Advisor'),
    );
  }
}
