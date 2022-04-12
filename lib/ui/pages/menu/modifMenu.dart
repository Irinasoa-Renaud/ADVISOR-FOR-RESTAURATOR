import 'package:flutter/material.dart';

import 'package:menu_advisor/utils/dependences.dart';

class ModifMenuPage extends StatefulWidget {
  const ModifMenuPage({Key? key}) : super(key: key);

  @override
  _ModifMenuPageState createState() => _ModifMenuPageState();
}

class _ModifMenuPageState extends State<ModifMenuPage> {
  var args;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(context)!.settings.arguments as ModifMenuArgs;
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
        title: const Text("Modifier un restaurant"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const Text(
              "Général",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            // Nom
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Nom",
                    style: TextData.textStyle1,
                  ),
                  TextField(
                    obscureText: true,
                    // decoration: InputDecoration(hintText: "GASTRO PIZZA"),
                  ),
                ],
              ),
            ),
            // Adresse
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Adresse",
                    style: TextData.textStyle1,
                  ),
                  DropdownButtonFormField(
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
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    const Text(
                      "Localisation",
                      style: TextData.textStyle1,
                    ),
                    Row(
                      children: const [
                        TextField(
                          decoration: InputDecoration(hintText: "10"),
                        )
                      ],
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class ModifMenuArgs {
  String token;
  String nom;
  String type;
  String description;
  ModifMenuArgs(this.token, this.nom, this.type, this.description);
}
