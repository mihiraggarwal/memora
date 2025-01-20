import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memora/main.dart';

import '../utils/notification.dart';

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
                        label: Text("Sign up as a user", style: TextStyle(fontSize: 15),)
                    ),
                    ButtonSegment(
                        value: "caretaker",
                        label: Text("Sign up as a caretaker", style: TextStyle(fontSize: 15),)
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
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Questions(user: user)
            )
        ]
       )
      )
    );
  }
}

class Questions extends StatefulWidget {
  final bool user;
  const Questions({Key? key, required this.user}) : super(key: key);

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {

  Map<String, dynamic> details = {};
  final _formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool wanderNotif = false;

  void updateState(k, v) {
    setState(() {
      details[k] = v;
    });
    print(details);
  }

  Widget userSpecific() {
    if (widget.user == true) {
      return Column(
        children: [
          SpecificTextInput(hint: "Address", value: "address", keyboardType: TextInputType.streetAddress, callback: updateState),
          SpecificTextInput(hint: "Max wander allowed (metres)",
              value: "threshold",
              keyboardType: TextInputType.number,
              callback: updateState),
          Container(
            margin: EdgeInsets.only(top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 5,
                  child: Text(
                    "Send notification to caretakers on wander",
                    style: TextStyle(
                        fontSize: 15
                    ),
                  ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 1,
                  child: CupertinoSwitch(
                    value: wanderNotif,
                    onChanged: (value) {
                      setState(() {
                        wanderNotif = value;
                        details["wanderNotif"] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SpecificTextInput(hint: "Name", value: "name", keyboardType: TextInputType.name, callback: updateState),
          SpecificTextInput(hint: "Age", value: "age", keyboardType: TextInputType.number, callback: updateState),
          userSpecific(),
          Container(
            margin: EdgeInsets.only(top: 40.0),
            child: ElevatedButton(
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
                  details["isUser"] = widget.user;

                  String fCMToken = await Messaging().initNotification();
                  details["fCMToken"] = fCMToken;

                  await firestore.collection("users").add(
                    details
                  );

                  auth.currentUser?.updateDisplayName(details["name"]);

                  print("User saved");
                  Navigator.pushNamed(context, MyApp.id);
                }
              }
            ),
          ),
        ],
      ),
    );
  }
}

class SpecificTextInput extends StatefulWidget {
  const SpecificTextInput({Key? key, required this.hint, required this.value, required this.keyboardType, required this.callback}) : super(key: key);

  final String hint;
  final String value;
  final TextInputType keyboardType;
  final Function callback;

  @override
  State<SpecificTextInput> createState() => _SpecificTextInputState();
}

class _SpecificTextInputState extends State<SpecificTextInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: widget.hint,
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
      ),
    );
  }
}


