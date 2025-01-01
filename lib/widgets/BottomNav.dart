import 'package:flutter/material.dart';

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
      items: const [
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