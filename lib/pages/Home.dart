import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth.dart';
import '../utils/location.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(150.0),
                child: Image(
                  image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                  width: 110,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello 👋",
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                    Text(
                      "John Doe",
                      style: TextStyle(
                          fontSize: 40
                      ),
                    )
                  ],
                ),
              )
            ]
        ),
        Container(
          margin: EdgeInsets.only(top: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 8,
                child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      )
                  ),
                  onPressed: () {},
                  child: const Text(
                      "About Me"
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 8,
                child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      )
                  ),
                  onPressed: () {},
                  child: const Text(
                      "Close Ones"
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10.0),
          width: double.infinity,
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
                snapshot.docs.forEach((doc) async {

                  final username = doc["name"];

                  if ((doc.data() as Map<String, dynamic>).containsKey('caretakers')) {
                    final caretakers = doc["caretakers"].map((obj) => obj["email"]).toList();
                    
                    List fCMTokens = [];
                    await Future.forEach(caretakers, (elem) async {
                      await firestore.collection("users").where("email", isEqualTo: elem).limit(1).get().then((QuerySnapshot querySnapshot) {
                        querySnapshot.docs.forEach((element) {
                          print(element["fCMToken"]);
                          fCMTokens.add(element["fCMToken"]);
                        });
                      });
                    });

                    await firestore.collection("emergencies").add({
                      "name": username,
                      "caretakers": fCMTokens
                    });
                  }
                });
              });
            },
            child: const Text(
                "Emergency"
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10.0),
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                )
            ),
            onPressed: () async {
              Navigator.pushNamed(context, LocationBtn.id);
            },
            child: const Text(
                "Get Location"
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10.0),
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                )
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, Auth.id);
            },
            child: const Text(
                "Logout"
            ),
          ),
        ),
      ],
    );
  }
}
