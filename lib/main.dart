import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memora/utils/notification.dart';
import 'firebase_options.dart';

import 'package:memora/pages/Home.dart';
import 'package:memora/widgets/BottomNav.dart';
import 'package:memora/utils/location.dart';
import 'package:memora/screens/auth.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await Messaging().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  static String id = 'main';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'memora',
      routes: {
        MyApp.id: (context) => MyHomePage(title: "memora"),
        Auth.id: (context) => const Auth()
      },
      initialRoute: Auth.id,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: "Inter"
      ),
      home: MyHomePage(title: 'memora'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 40.0),
                child: const Home()
              ),
              LocationBtn()
            ],
          ),
        ),
        bottomNavigationBar: const BottomNav(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.mic),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
