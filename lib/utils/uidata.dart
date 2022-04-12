import 'package:flutter/material.dart';

class UIData {
  // Images
  static const String imageDir = "assets/images";
  static const String logo = imageDir + "/logo.png";
  static const String logoGastro = imageDir + "/logo_gastro.png";
  static const String placeholder = imageDir + "/placeholder.jpg";
  static const String fondLoginPage = imageDir + "/fond.jpeg";

  // Colors
  static const MaterialColor colorPrincipal =
      MaterialColor(_colorPrincipalPrimaryValue, <int, Color>{
    50: Color(0xFFFBE3E8),
    100: Color(0xFFF5B9C5),
    200: Color(0xFFEE8A9E),
    300: Color(0xFFE75B77),
    400: Color(0xFFE13759),
    500: Color(_colorPrincipalPrimaryValue),
    600: Color(0xFFD81236),
    700: Color(0xFFD30E2E),
    800: Color(0xFFCE0B27),
    900: Color(0xFFC5061A),
  });
  static const int _colorPrincipalPrimaryValue = 0xFFDC143C;

  static const MaterialColor colorPrincipalAccent =
      MaterialColor(_colorPrincipalAccentValue, <int, Color>{
    100: Color(0xFFFFEEEF),
    200: Color(_colorPrincipalAccentValue),
    400: Color(0xFFFF8890),
    700: Color(0xFFFF6F78),
  });
  static const int _colorPrincipalAccentValue = 0xFFFFBBC0;

  // static const MaterialColor colorPrincipal = Colors.red;

  // static const Color logoTitleColor = Color.fromARGB(255, 218, 106, 98);
  static const Color navBarColor1 = Colors.white;
  static const Color navBarColor2 = colorPrincipal;
  static const Color logoTitleColor = colorPrincipal;

  static const Color selectColor = Color.fromARGB(0, 33, 149, 243);

  static const Color pageBG = Color.fromARGB(255, 204, 203, 203);

  static const Color btnSuccess = Color.fromARGB(255, 2, 133, 6);

  static const Color btnAlert = colorPrincipal;

  static const Color btnDefault = Color.fromARGB(218, 21, 106, 253);
}

class TextData {
  // static const TextStyle titlePageStyle =
  //     TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w300);
  static const TextStyle titlePageStyle = TextStyle(
      color: UIData.colorPrincipal, fontSize: 20, fontWeight: FontWeight.w300);

  static const TextStyle subtitlePageStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w300);

  static const TextStyle textStyle1 =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w300);

  static const TextStyle textStyle2 =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w300);

  static const TextStyle textButtonStyle1 =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
}

class RoutePage {
  static const String dashboardPage = '/dashboard';
  static const String qrPage = '/qr';

  static const String simulationLivraisonPage = '/simulationLivraison';
  static const String mapFullScreenPage = '/mapFullScreen';

  static const String messagesPage = '/messages';
  // static const String homePage = '/';
  static const String homePage = '/home';

  static const String restaurantPage = '/restaurant';

  static const loginPage = '/login';
  static const String recupComptePage = '/recupCompte';

  static const String platsRecommandedPage = '/recommandedPlats';
  static const String recommanderPlatPage = '/recommanderPlat';

  static const String platsPage = '/plats';
  static const String modifPlatPage = '/modifPlat';
  static const String ajoutPlatPage = '/ajoutPlat';

  static const String menuPage = '/menu';
  static const String modifMenuPage = '/modifMenu';
  static const String ajoutMenuPage = '/ajoutMenu';

  // static const String commandesPage = '/commandes';
  static const String commandesPage = '/';
  static const String detailCommandPage = '/detailCommand';
  static const String surPlaceCommandePage = '/surPlace';
  static const String commandesLivraisonPage = '/comandLivraison';
  static const String emportedCommandePage = '/emportedCommandes';

  static const String typePage = '/type';
  static const String ajoutTypePage = '/ajoutType';
  static const String modifTypePage = '/modifType';

  static const String accompagnementPage = '/accompagnements';
  static const String ajoutAccompagnementPage = '/ajoutAccompagnement';
  static const String modifAccompagnementPage = '/modifAccompagnement';

  static const String maPage = '/maPage';
}
