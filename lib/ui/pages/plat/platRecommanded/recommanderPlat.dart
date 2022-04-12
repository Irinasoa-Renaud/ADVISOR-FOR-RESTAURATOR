import 'package:flutter/material.dart';

import 'package:menu_advisor/utils/dependences.dart';

class RecommanderPlatPage extends StatefulWidget {
  const RecommanderPlatPage({Key? key}) : super(key: key);

  @override
  _RecommanderPlatPageState createState() => _RecommanderPlatPageState();
}

class _RecommanderPlatPageState extends State<RecommanderPlatPage> {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const TextField(
                //   decoration: InputDecoration(hintText: "Plat"),
                // ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              primary: UIData.btnAlert),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text("Annuler")),
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              primary: UIData.btnSuccess),
                          onPressed: () {},
                          icon: const Icon(Icons.save),
                          label: const Text("Enregistrer"))
                    ])
              ],
            ),
          )
        ],
      ),
    );
  }
}
