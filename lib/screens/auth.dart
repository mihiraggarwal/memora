import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

import '../main.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  static String id = 'auth';

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {

  FirebaseAuth auth = FirebaseAuth.instance;
  final formKey =  GlobalKey<FormState>();

  String userEmail = '', userPassword = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.purple
              ),
              child: const Padding(
                padding: EdgeInsets.all(70.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "memora",
                      style: TextStyle(
                        fontSize: 35,
                        fontFamily: "Airbnb"
                      ),
                    )
                  ],
                ),
              ),
            ),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 30.0, 15.0, 30.0),
                child: Column(
                  children: [
                    Container(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Email',
                            border: OutlineInputBorder(
                              gapPadding: 0.0
                            ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (String? email) => userEmail = email!,
                        validator: (String? email) {
                          if (email == null || email.isEmpty) {
                            return 'Please enter your email';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        decoration:
                        const InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder()
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        onSaved: (String? password) => userPassword = password!,
                        validator: (String? password) {
                          if (password == null || password.isEmpty) {
                            return 'Please enter your password';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.all(2.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)
                                  ),
                              ),
                              // fixedSize: MaterialStatePropertyAll(Size(50.0, 50.0))
                            ),
                            child: const Text('Sign up'),
                            onPressed: () async {
                              if (formKey.currentState?.validate() == true) {
                                formKey.currentState?.save();
                                try {
                                  UserCredential userCredential =
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                      email: userEmail,
                                      password: userPassword);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Signed up successfully')));
                                  // Navigator.pushNamed(context, '/');
                                } on FirebaseAuthException catch (e) {
                                  print(e.code);
                                  if (e.code == 'weak_password') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Password is too weak')));
                                  } else if (e.code ==
                                      'email-already-in-use') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Email is already in use')));
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                      content: Text(e.toString())));
                                  print(e);
                                }
                              } else {
                                print('not');
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(2.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)
                                  )
                              )
                            ),
                            child: const Text('Login'),
                            onPressed: () async {
                              if (formKey.currentState?.validate() ==
                                  true) {
                                formKey.currentState?.save();
                                try {
                                  UserCredential userCredential =
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                      email: userEmail,
                                      password: userPassword);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Logged in successfully')));
                                  // Navigator.pushNamed(context, '/');
                                } on FirebaseAuthException catch (e) {
                                  print(e.code);
                                  if (e.code == 'user-not-found') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content:
                                        Text('User not found')));
                                  } else if (e.code == 'wrong-password') {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong password')));
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                      content: Text(e.toString())));
                                  print(e);
                                }
                              } else {
                                print('not');
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
