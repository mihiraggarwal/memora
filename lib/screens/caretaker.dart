import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memora/widgets/BottomNav.dart';

class Caretaker extends StatefulWidget {
  const Caretaker({Key? key}) : super(key: key);

  static String id = "caretaker";

  @override
  _CaretakerState createState() => _CaretakerState();
}

class _CaretakerState extends State<Caretaker> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List caretakers = [];

  @override
  Widget build(BuildContext context) {

    var userUid = auth.currentUser!.uid;

    firestore.collection("users").where("uid", isEqualTo: userUid).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {

        Map<String, String> taker = {};

        taker["name"] = doc["name"];
        taker["email"] = doc["email"];

        caretakers.add(taker);
      });
    });

    return Column(
      children: [
        const Text(
          "Caretakers",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30
          ),
        ),
        ListView.builder(
          itemCount: caretakers.length,
          itemBuilder: (BuildContext context, index) {
            return Person(name: caretakers[index]["name"], email: caretakers[index]["email"]);
          },
          shrinkWrap: true,
        ),
        Container(
          margin: EdgeInsets.only(top: 50.0),
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                )
            ),
            onPressed: () {
              showDialog(context: context, builder: (BuildContext context) => CareDialog());
            },
            child: const Text(
                "Add Caretaker"
            ),
          ),
        ),
      ],
    );
  }
}

class CareDialog extends StatelessWidget {
  CareDialog({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  String email = '';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      child: Dialog(
        shape: OutlineInputBorder(
          borderSide: BorderSide.none
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Email address",
                    border: const OutlineInputBorder()
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (String? s) => email = s!,
                  validator: (String? s) {
                    if (s == null || s.isEmpty) {
                      return 'Please enter the email';
                    } else {
                      return null;
                    }
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        ),
                      ),
                    ),
                    child: const Text('Send Request'),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        _formKey.currentState?.save();

                        await firestore.collection("users").where("email", isEqualTo: email).get().then((QuerySnapshot snapshot) {
                          snapshot.docs.forEach((doc) {
                            doc.reference.update({
                              "request": true,
                              "requestor": auth.currentUser?.email
                            });
                          });
                        });

                        Navigator.pop(context);
                      }
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class Person extends StatelessWidget {
  final String name;
  final String email;

  const Person({Key? key, required this.name, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black
        ),
        borderRadius: BorderRadius.all(Radius.circular(5.0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 32
            ),
          ),
          Text(
            email,
            style: TextStyle(
              fontSize: 20
            ),
          )
        ],
      ),
    );
  }
}
