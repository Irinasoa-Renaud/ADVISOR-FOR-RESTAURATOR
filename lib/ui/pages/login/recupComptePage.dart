import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/ui/pages.dart';
export 'package:menu_advisor/utils/dependences.dart';

import 'package:menu_advisor/utils/uidata.dart';

import 'package:http/http.dart' as http;

class RecupComptePage extends StatefulWidget {
  const RecupComptePage({Key? key}) : super(key: key);

  @override
  _RecupComptePageState createState() => _RecupComptePageState();
}

class _RecupComptePageState extends State<RecupComptePage> {
  final TextEditingController _phoneNumberController = TextEditingController(),
      _newPasswordController = TextEditingController(),
      _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool resetPwdProcessing = false,
      resendCodeProcessing = false,
      isResetPwd = false,
      _obscureText = true;
  String token = "";
  int code = 0;

  Future<void> _resendCode(String _token) async {
    setState(() {
      resendCodeProcessing = true;
    });
    Map<String, dynamic> body = {"token": _token};
    var url = Uri.parse(Api.resendConfirmationCode);
    try {
      var response = await http.post(url,
          headers: {
            'Accept': 'application/json',
          },
          body: body);
      debugPrint(
          "$logTrace data :${response.body}-${response.statusCode}-${response.reasonPhrase}");
      var jsonData = await json.decode(response.body);
      if (response.statusCode != 200) {
        MyToast.showAlert("Un erreur est survenue, veuillez réessayer");
      } else if (response.statusCode == 200) {
        setState(() {
          MyToast.showSuccess("Votre code de confirmation à été envoyé");
          isResetPwd = true;
        });
      }
      setState(() {
        resendCodeProcessing = false;
      });
    } catch (e) {
      MyToast.showAlert("Erreur lors de la connexion");
      setState(() {
        resendCodeProcessing = false;
      });
      debugPrint("$logTrace erreur :$e");
    }
  }

  Future<void> _resetPassword(String phoneNumber) async {
    setState(() {
      resetPwdProcessing = true;
    });
    Map<String, dynamic> body = {"phoneNumber": phoneNumber};
    var url = Uri.parse(Api.resetPassword);
    try {
      var response = await http.post(url,
          headers: {
            'Accept': 'application/json',
          },
          body: body);
      debugPrint(
          "$logTrace data :${response.body}-${response.statusCode}-${response.reasonPhrase}");
      var jsonData = await json.decode(response.body);
      if (response.statusCode != 200) {
        MyToast.showAlert("Numéro invalide");
      } else if (response.statusCode == 200) {
        setState(() {
          token = jsonData['token'];
          code = jsonData['code'];
          isResetPwd = true;
        });
      }
      setState(() {
        resetPwdProcessing = false;
      });
    } catch (e) {
      MyToast.showAlert("Erreur lors de la connexion");
      setState(() {
        resetPwdProcessing = false;
      });
      debugPrint("$logTrace erreur :$e");
    }
  }

  Future<void> confirmResetPassword(
      String _token, String _code, String _pwd) async {
    setState(() {
      resetPwdProcessing = true;
    });
    Map<String, dynamic> body = {
      "token": _token,
      "code": _code,
      "password": _pwd
    };
    var url = Uri.parse(Api.confirmResetPwd);
    try {
      var response = await http.post(url,
          headers: {
            'Accept': 'application/json',
          },
          body: body);
      debugPrint(
          "$logTrace data :${response.body}-${response.statusCode}-${response.reasonPhrase}");
      if (response.statusCode != 200) {
        MyToast.showAlert("Veuillez vérifier votre code");
      } else if (response.statusCode == 200) {
        MyToast.showSuccess(
            "Mot de passe modifié avec succès, veullez vous reconnecter");
        Navigator.popAndPushNamed(context, RoutePage.loginPage);
        setState(() {
          isResetPwd = true;
        });
      }
      setState(() {
        resetPwdProcessing = false;
      });
    } catch (e) {
      MyToast.showAlert("Erreur lors de la connexion");
      setState(() {
        resetPwdProcessing = false;
      });
      debugPrint("$logTrace erreur :$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: UIData.colorPrincipal,
      body: WillPopScope(
        onWillPop: () {
          throw Navigator.popAndPushNamed(context, RoutePage.loginPage);
        },
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(UIData.fondLoginPage,
              fit: BoxFit.fitHeight,
              alignment: AlignmentDirectional.centerStart),
          Center(
              child: SingleChildScrollView(
            child: SizedBox(
              width: (w / 2) + (w / 3),
              height: (h / 3) + (h / 4),
              child: Form(
                key: _formKey,
                child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  elevation: 50,
                  child: !isResetPwd
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                              child: const Text(
                                "Entrer votre numéro de téléphone pour recevoir votre code",
                                style: TextData.textStyle2,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextFormField(
                                controller: _phoneNumberController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le numéro de téléphone ne doit pas \nêtre vide!';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  // icon: Icon(Icons.phone),
                                  hintText: "Numéro de téléphone",
                                ),
                              ),
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: UIData.btnDefault,
                                  minimumSize: Size((w / 2) + (w / 4), 40),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    debugPrint(
                                        "$logTrace number:${_phoneNumberController.text}");
                                    _resetPassword(_phoneNumberController.text);
                                  }
                                },
                                child: resetPwdProcessing
                                    ? Container(
                                        padding: EdgeInsets.all(1),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                        ))
                                    : const Text("Valider")),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: UIData.btnAlert,
                                  minimumSize: Size((w / 2) + (w / 4), 40),
                                ),
                                onPressed: () {
                                  Navigator.popAndPushNamed(
                                      context, RoutePage.loginPage);
                                },
                                child: const Text("Annuler")),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: const Text(
                                "Entrer votre nouveau mot de passe",
                                style: TextData.textStyle2,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _codeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Code de validation ne doit pas être vide!';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  // icon: Icon(Icons.phone),
                                  hintText: "Code de validation",
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextFormField(
                                controller: _newPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le mot de passe ne doit pas être vide!';
                                  }
                                  return null;
                                },
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  // icon: Icon(Icons.phone),
                                  hintText: "Nouveau mot de passe",
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
                              ),
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: UIData.btnDefault,
                                  minimumSize: Size((w / 2) + (w / 4), 40),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    debugPrint(
                                        "$logTrace pwd:${_newPasswordController.text}");
                                    confirmResetPassword(
                                        token,
                                        _codeController.text,
                                        _newPasswordController.text);
                                  }
                                },
                                child: resetPwdProcessing
                                    ? Container(
                                        padding: EdgeInsets.all(1),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                        ))
                                    : const Text("Valider")),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: UIData.btnAlert,
                                  minimumSize: Size((w / 2) + (w / 4), 40),
                                ),
                                onPressed: () {
                                  _newPasswordController.clear();
                                  _codeController.clear();
                                  _resendCode(token);
                                },
                                child: resendCodeProcessing
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text("Renvoyer le code")),
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
