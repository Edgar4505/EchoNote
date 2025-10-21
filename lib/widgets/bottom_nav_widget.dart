import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavWidget({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.mic, color: currentIndex == 0 ? Colors.white : Colors.grey),
          label: 'Live',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history, color: currentIndex == 1 ? Colors.white : Colors.grey),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: currentIndex == 2 ? Colors.white : Colors.grey),
          label: 'Profile',
        ),
      ],
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(color: Colors.white),
      unselectedLabelStyle: TextStyle(color: Colors.grey),
    );
  }
}