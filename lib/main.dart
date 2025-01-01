import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'memora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: "Inter"
      ),
      home: const MyHomePage(title: 'memora'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 30.0, 15.0, 15.0),
        child: Column(
          children: <Widget>[
            Align(
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
              margin: EdgeInsets.only(top: 40.0),
              child: Home()
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

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
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
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
                  child: Text(
                      "About Me"
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    )
                  ),
                  onPressed: () {},
                ),
              ),
              Spacer(),
              Expanded(
                flex: 8,
                child: ElevatedButton(
                  child: Text(
                      "Close Ones"
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    )
                  ),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10.0),
          width: double.infinity,
          child: ElevatedButton(
            child: Text(
                "Emergency"
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                )
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          label: "Home",
            icon: Icon(Icons.home)
        ),
        BottomNavigationBarItem(
            label: "Other",
            icon: Icon(Icons.accessible)
        ),
        BottomNavigationBarItem(
          label: "Quiz",
          icon: Icon(Icons.quiz)
        ),
        BottomNavigationBarItem(
          label: "Profile",
            icon: Icon(Icons.account_circle_rounded)
        )
      ],
    );
  }
}


