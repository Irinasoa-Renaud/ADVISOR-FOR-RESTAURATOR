import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menu_advisor/utils/dependences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _login;
  String? _password;

  bool _obscureText = true;

  bool? seSouvenir = false;
  bool processing = false;

  bool error = false;
  bool success = false;
  String errorContent = "";

  String nom = "";
  String user_id = "";
  String userDataFileName = "user_data.txt";
  String userDataFileContent = ".";

  Future<bool> _logIn(String? login, String? password) async {
    debugPrint("$logTrace $login + $password");
    setState(() {
      processing = true;
    });
    var url = Uri.parse(Api.login);
    try {
      var response = await http.post(
        url,
        body: {'login': '$_login', 'password': '$_password'},
      );

      var jsonData = json.decode(response.body);
      // ROLE_RESTAURANT_ADMIN

      if (jsonData['access_token'] != null) {
        debugPrint(
            "$logTrace connection reussi,Role:${jsonData['user']['roles'][0]}");
        setState(() {
          // error = false;
          // success = true;
          // processing = false;
          // nom = jsonData['user']['name']['first'];
          User user = User.fromJson(json.decode(response.body)['user']);
          nom = user.name.first;
          user_id = user.id;
        });

        var url = Uri.parse(Api.restaurants + "?admin=$user_id");
        try {
          var restoResponse = await http.get(url, headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${jsonData['access_token']}',
          });
          if (restoResponse.body == '[]') {
            MyToast.showAlert("Vous devez être associé à un restaurant");
            setState(() {
              error = true;
              success = false;
              processing = false;
              errorContent = "Vous devez être associé à un restaurant";
            });
            return false;
          } else {
            var restoData = json.decode(restoResponse.body)[0];
            // Restaurant resto = Restaurant.fromJson(restoData);
            RestoData.save(restoResponse.body);
            MyToast.showSuccess("Succès de la connexion");
            AccessTokenData.saveToken(jsonData['access_token']);
            RefreshTokenData.saveToken(jsonData['refresh_token']);
            UserData.save(response.body);
            setState(() {
              error = false;
              success = true;
            });
            return true;
          }

          // debugPrint('$logTrace resto ${resto.minPriceIsDelivery.toString()}');
          // debugPrint('$logTrace erreur ${restaurants.last.category}');
          // setState(() {
          //   error = false;
          //   success = true;
          // });
          // return true;
        } catch (e) {
          setState(() {
            error = true;
            success = false;
            processing = false;
            errorContent = "$e";
          });
          debugPrint('$logTrace erreur $e');
          return false;
        }

        // debugPrint("$logTrace runtimeType  ${response.body.runtimeType}");
        // MyToast.showSuccess("Succès de la connexion");
        // AccessTokenData.saveToken(jsonData['access_token']);
        // RefreshTokenData.saveToken(jsonData['refresh_token']);
        // UserData.save(response.body);
        // return true;
      } else {
        debugPrint("$logTrace email ou mot de passe incorrect");
        setState(() {
          error = true;
          success = false;
          processing = false;
          errorContent = "email ou mot de passe incorrect";
        });
        MyToast.showAlert("email ou mot de passe incorrect");
        return false;
      }
    } catch (e) {
      debugPrint("$logTrace eo $e");
      setState(() {
        error = true;
        success = false;
        processing = false;
        errorContent = "Erreur lors de la connexion";
      });
      MyToast.showAlert("Erreur lors de la connexion");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          throw showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Quiter"),
                  content: const Text("Vous allez Quiter l'Application?"),
                  actions: [
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: UIData.btnSuccess,
                        ),
                        onPressed: () {
                          print("oui");
                          Navigator.pop(context);
                          exit(0);
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
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(UIData.fondLoginPage,
              fit: BoxFit.fitHeight,
              alignment: AlignmentDirectional.centerStart),
          Center(
              child: SingleChildScrollView(
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              margin: const EdgeInsets.all(30.0),
              elevation: 50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: w / 6,
                        child: Image.asset(UIData.logo),
                      ),
                      const Text(
                        "Bon retour",
                        style: TextData.textStyle1,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "Se connecter à votre compte",
                        style: TextData.textStyle2,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),

                      Container(
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                ((!value.contains('@')) ||
                                    (!value.contains('.')))) {
                              return 'Nom d\'utilisateur invalide';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            // icon: Icon(Icons.person),
                            hintText: "Mail",
                          ),
                          onChanged: (String value) {
                            setState(() {
                              _login = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le mot de passe ne doit pas \nêtre vide';
                            }
                            return null;
                          },
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            // icon: const Icon(Icons.lock),
                            hintText: "Mot de Passe",
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(!_obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                          ),
                          onChanged: (String value) {
                            setState(() {
                              _password = value;
                            });
                          },
                          // onFieldSubmitted: (String value) {
                          //   setState(() {
                          //     _password = value;
                          //   });
                          // },
                        ),
                      ),
                      Visibility(
                        visible: error ? true : false,
                        child: Card(
                          color: Colors.red,
                          child: Container(
                            width: w,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            child: Text(
                              errorContent,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: success ? true : false,
                        child: Card(
                          color: Colors.green.shade500,
                          child: Center(
                            child: Text(
                              "Bienvenu $nom!",
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // Visibility(
                      //   visible: error ? false : true,
                      //   child: const SizedBox(
                      //     height: 20,
                      //   ),
                      // ),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                                value: seSouvenir,
                                onChanged: (val) {
                                  debugPrint("$logTrace seSouvenir: $val");
                                  setState(() {
                                    seSouvenir = val;
                                  });
                                }),
                            const Text(
                              "Se souvenir de moi",
                              style: TextData.textStyle2,
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: ElevatedButton(
                            onPressed: () async {
                              if (!processing) {
                                if (_formKey.currentState!.validate()) {
                                  _logIn(_login, _password).then((value) {
                                    if (value) {
                                      // Navigator.pushNamed(
                                      //     context, RoutePage.commandesPage);
                                      Navigator.pushNamed(
                                          context, RoutePage.menuPage);
                                      // context,
                                      // RoutePage.typePage);
                                    }
                                  });
                                }
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  processing == false
                                      ? "Se connecter "
                                      : "Connexion ",
                                ),
                                processing == false
                                    ? const Icon(Icons.login)
                                    : const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                              ],
                            )),
                      ),
                      Visibility(
                        visible: success ? false : true,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.popAndPushNamed(
                                  context, RoutePage.recupComptePage);
                            },
                            child: const Text(
                              "Mot de passe oublié?",
                              style: TextStyle(
                                  color: UIData.btnAlert,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
        ]),
      ),
    );
  }
}


// FlutterError (setState() called after dispose()