import 'package:flutter/material.dart';

class BNavigatorAdmin extends StatefulWidget {
  final Function currentIndex;

  const BNavigatorAdmin({super.key, required this.currentIndex});

  @override
  State<BNavigatorAdmin> createState() => _BNavigatorAdminState();
}

class _BNavigatorAdminState extends State<BNavigatorAdmin> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: index,
        onTap: (int i) {
          setState(() {
            index = i;
            widget.currentIndex(i);
          });
        },
        selectedItemColor: const Color.fromARGB(255, 0, 162, 255),
        unselectedItemColor: Color.fromARGB(225, 255, 255, 255),
        iconSize: 27.0,
        selectedFontSize: 16.0,
        unselectedFontSize: 14.0,
        backgroundColor: Color.fromARGB(252, 0, 32, 71),
        items: const [
          BottomNavigationBarItem(
              //Luego se cambiará
              icon: Icon(Icons.home),
              label: 'Inicio'),
          BottomNavigationBarItem(
              //Luego se cambiará
              icon: Icon(Icons.supervised_user_circle),
              label: 'Usuarios'),
          BottomNavigationBarItem(
              //Luego se cambiará
              icon: Icon(Icons.announcement),
              label: 'Avisos')
        ]);
  }
}
