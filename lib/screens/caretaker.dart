import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  bool request = false;
  String requestor = '';

  void initState() {
    super.initState();
    var userUid = auth.currentUser!.uid;

    firestore.collection("users").where("uid", isEqualTo: userUid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, String> taker = {};

        if ((doc.data() as Map<String, dynamic>).containsKey('caretakers')) {
          doc["caretakers"].forEach((element) {
            taker["name"] = element["name"];
            taker["email"] = element["email"];

            caretakers.add(taker);
          });
        }

        if (doc["request"] == true) {
          setState(() {
            request = true;
            requestor = doc["requestor"];
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Caretakers",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30
          ),
        ),
        Request(request: request, requestor: requestor),
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

class Request extends StatefulWidget {
  bool request = false;
  String requestor = '';

  Request({Key? key, required this.request, this.requestor = ''}) : super(key: key);

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (widget.request == true) {
      return Container(
        padding: EdgeInsets.all(8.0),
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
              "${widget.requestor} is requesting to add you as a caretaker.",
              style: TextStyle(
                  fontSize: 20
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 5,
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

                    onPressed: () async {
                      await firestore.collection("users").where("email", isEqualTo: widget.requestor).limit(1).get().then((QuerySnapshot snapshot) {
                        snapshot.docs.forEach((doc) {
                          doc.reference.update({
                            "caretakers": FieldValue.arrayUnion([{
                              "name": auth.currentUser?.displayName,
                              "email": auth.currentUser?.email
                            }])
                          });
                        });
                      });

                      await firestore.collection("users").where("uid", isEqualTo: auth.currentUser?.uid).limit(1).get().then((QuerySnapshot snapshot) {
                        snapshot.docs.forEach((doc) {
                          doc.reference.update({
                            "request": false,
                            "requestor": null
                          });
                        });
                      });

                      setState(() {
                        widget.request = false;
                      });

                    },
                    child: const Text(
                        "Accept"
                    ),
                  ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        foregroundColor: MaterialStateProperty.all(Colors.black),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)
                            )
                        )
                    ),
                    onPressed: () async {
                      await firestore.collection("users").where("uid", isEqualTo: auth.currentUser?.uid).limit(1).get().then((QuerySnapshot snapshot) {
                        snapshot.docs.forEach((doc) {
                          doc.reference.update({
                            "request": false,
                            "requestor": null
                          });
                        });
                      });
                    },
                    child: const Text(
                        "Reject"
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    } else return Container();
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
