import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

import 'constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List? _myActivities;
  late String _myActivitiesResult;
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _myActivities = [];
    _myActivitiesResult = '';
  }

  _saveForm() {
    var form = formKey.currentState!;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivitiesResult = _myActivities.toString();
      });
    }
    print("$_myActivitiesResult .. $_myActivities");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MultiSelect Formfield Example'),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                child: MultiSelectFormField(
                  autovalidate: AutovalidateMode.disabled,
                  chipBackGroundColor: Colors.red,
                  chipLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  dialogTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                  checkBoxActiveColor: Colors.blue,
                  checkBoxCheckColor: Colors.white,
                  dialogShapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  title: const Text(
                    "Languages",
                    style: TextStyle(fontSize: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.length == 0) {
                      return 'Please select one or more options';
                    }
                    return null;
                  },
                  dataSource: const [
                    {
                      "display": "Running",
                      "value": "Running",
                    },
                    {
                      "display": "Climbing",
                      "value": "Climbing",
                    },
                    {
                      "display": "Walking",
                      "value": "Walking",
                    },
                    {
                      "display": "Swimming",
                      "value": "Swimming",
                    },
                    {
                      "display": "Soccer Practice",
                      "value": "Soccer Practice",
                    },
                    {
                      "display": "Baseball Practice",
                      "value": "Baseball Practice",
                    },
                    {
                      "display": "Football Practice",
                      "value": "Football Practice",
                    },
                  ],
                  textField: 'display',
                  valueField: 'value',
                  okButtonLabel: 'OK',
                  cancelButtonLabel: 'CANCEL',
                  hintWidget: const Text('Please choose one or more'),
                  initialValue: _myActivities,
                  onSaved: (value) {
                    if (value == null) return;
                    setState(() {
                      _myActivities = value;
                    });
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  child: const Text('Save'),
                  onPressed: _saveForm,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(_myActivitiesResult),
              )
            ],
          ),
        ),
      ),
    );
  }
}
