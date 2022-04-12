import 'package:flutter/material.dart';

import 'package:menu_advisor/utils/dependences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // Widget menuCommande=

    return WillPopScope(
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
      child: Scaffold(
          drawer: const MyDrawer(selection: 0),
          appBar: MyAppBar(selection: 0, callback: () {}),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '2K',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          ),
          floatingActionButton: const MyFloatingActionButton()),
    );
  }
}
