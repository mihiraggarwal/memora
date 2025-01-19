import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth.dart';
import '../utils/location.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = '';

  bool dataLoaded = false;

  Future<String> getDetails() async {
    final uid = auth.currentUser?.uid;
    String name = '';

    await firestore.collection("users").where("uid", isEqualTo: uid).limit(1).get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        name = doc["name"];
      }
    });

    return name;
  }

  @override
  Widget build(BuildContext context) {

    if (name == '') {
      getDetails().then((value) {
        if (mounted) {
          setState(() {
            name = value;
            dataLoaded = true;
          });
        }
      });
    }

    if (dataLoaded) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(150.0),
                      child: Image(
                        image: NetworkImage(
                            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                        width: 110,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hello 👋",
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
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
                    await firestore.collection("users").where(
                        "uid", isEqualTo: auth.currentUser?.uid).limit(1)
                        .get()
                        .then((QuerySnapshot snapshot) {
                      snapshot.docs.forEach((doc) async {
                        final username = doc["name"];

                        if ((doc.data() as Map<String, dynamic>).containsKey(
                            'caretakers')) {
                          final caretakers = doc["caretakers"].map((
                              obj) => obj["email"]).toList();

                          List fCMTokens = [];
                          await Future.forEach(caretakers, (elem) async {
                            await firestore.collection("users").where(
                                "email", isEqualTo: elem).limit(1).get().then((
                                QuerySnapshot querySnapshot) {
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
                margin: EdgeInsets.only(top: 30.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5.0)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Location",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      ),
                    ),
                    Text(
                        "If you're feeling lost, see your live location and the location of your home :)"
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
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
                            "View Map"
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(bottom: 20.0),
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
    else {
      return Scaffold(
        body: Center(
          child: Text("Loading..."),
        ),
      );
    }
  }
}
