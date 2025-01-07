import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  bool user = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 30.0, 15.0, 15.0),
        child: Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "memora",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Airbnb"
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
            child: Column(
              children: [
                SegmentedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      )
                  ),
                  segments: const [
                    ButtonSegment(
                        value: "user",
                        label: Text("Sign up as a user")
                    ),
                    ButtonSegment(
                        value: "caretaker",
                        label: Text("Sign up as a caretaker")
                    ),
                  ],
                  selected: {user == true ? "user" : "caretaker"},
                  onSelectionChanged: (newSelection) => setState(() {
                    newSelection.first == "user" ? user = true : user = false;
                  }),
                )
              ],
            ),
          ),
            Questions()
        ]
       )
      )
    );
  }
}

class Questions extends StatefulWidget {
  const Questions({Key? key}) : super(key: key);

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {

  Map<String, dynamic> details = {};
  final _formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void updateState(k, v) {
    setState(() {
      details[k] = v;
    });
    print(details);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SpecificTextInput(value: "name", keyboardType: TextInputType.name, callback: updateState),
          SpecificTextInput(value: "age", keyboardType: TextInputType.number, callback: updateState),
          ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)
                ),
              ),
            ),
            child: const Text('Finish'),
            onPressed: () async {
              if (_formKey.currentState?.validate() == true) {
                _formKey.currentState?.save();

                details["uid"] = auth.currentUser?.uid;
                details["email"] = auth.currentUser?.email;

                await firestore.collection("users").add(
                  details
                );

                print("User saved");
                Navigator.pushNamed(context, '/');
              }
            }
          ),
        ],
      ),
    );
  }
}

class SpecificTextInput extends StatefulWidget {
  const SpecificTextInput({Key? key, required this.value, required this.keyboardType, required this.callback}) : super(key: key);

  final String value;
  final TextInputType keyboardType;
  final Function callback;

  @override
  State<SpecificTextInput> createState() => _SpecificTextInputState();
}

class _SpecificTextInputState extends State<SpecificTextInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: widget.value[0].toUpperCase() + widget.value.substring(1),
        border: const OutlineInputBorder(),
      ),
      keyboardType: widget.keyboardType,
      onSaved: (String? s) => {
        widget.callback(widget.value, s)
      },
      validator: (String? s) {
        if (s == null || s.isEmpty) {
          return 'Please enter your ${widget.value}';
        } else {
          return null;
        }
      },
    );
  }
}


