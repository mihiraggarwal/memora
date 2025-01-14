import 'package:flutter/material.dart';
import 'package:memora/main.dart';
import 'package:memora/screens/caretaker.dart';

class BottomNav extends StatefulWidget {
  BottomNav({Key? key, required this.callback}) : super(key: key);

  var callback;

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: _currentIndex,
      items: const [
        BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home)
        ),
        BottomNavigationBarItem(
            label: "Caretakers",
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
      onTap: (value) {
        setState(() {
          _currentIndex = value;
        });
        widget.callback(value);
      },
    );
  }
}