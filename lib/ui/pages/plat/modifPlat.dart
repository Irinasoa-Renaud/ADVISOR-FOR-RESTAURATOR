import 'package:flutter/material.dart';

import 'package:menu_advisor/utils/dependences.dart';

class ModifPlatPage extends StatefulWidget {
  const ModifPlatPage({Key? key}) : super(key: key);

  @override
  _ModifPlatPageState createState() => _ModifPlatPageState();
}

class _ModifPlatPageState extends State<ModifPlatPage> {
  bool phtNonContractuel = true;
  bool statut = true;
  bool dispo = true;
  int? accompagnement = 0;
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
        title: const Text("Modifier un plat"),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Nom",
                    style: TextData.textStyle1,
                  ),
                  TextField(
                    decoration: InputDecoration(icon: Icon(Icons.text_fields)),
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
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Prix",
                    style: TextData.textStyle1,
                  ),
                  TextField(
                    decoration: InputDecoration(icon: Icon(Icons.euro)),
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
                        const Icon(
                          Icons.cloud_upload,
                          size: 50,
                        ),
                        SizedBox(
                          height: 100,
                          child: Image.asset(
                            UIData.placeholder,
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
            child: DropdownButtonFormField(
                value: 1,
                items: const [
                  DropdownMenuItem(
                    child: Text(
                      'Accompagnement',
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
                    accompagnement = value as int;
                  });
                  print(value);
                }),
          ),
          accompagnement == 2
              ? Column(children: [
                  ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle),
                      label: const Text("AJOUTER")),
                  ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(primary: UIData.btnAlert),
                      icon: const Icon(Icons.add_circle),
                      label: const Text("AJOUTER UN ACCOMPAGNEMENT")),
                ])
              : Container(),
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
                      onPressed: null,
                      icon: const Icon(Icons.cancel),
                      label: const Text("Annuler")),
                  ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(primary: UIData.btnSuccess),
                      onPressed: null,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"))
                ]),
          )
        ],
      ),
    );
  }
}
