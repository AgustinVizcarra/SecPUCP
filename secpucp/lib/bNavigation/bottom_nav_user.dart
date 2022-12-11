import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class BNavigatorUser extends StatefulWidget {
  final Function currentIndex;
  const BNavigatorUser({super.key, required this.currentIndex});

  @override
  State<BNavigatorUser> createState() => _BNavigatorUserState();
}

class _BNavigatorUserState extends State<BNavigatorUser> {
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
        selectedItemColor: Color.fromARGB(255, 0, 162, 255),
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
              icon: Icon(Icons.notifications),
              label: 'Notificaciones'),
          BottomNavigationBarItem(
              //Luego se cambiará
              icon: Icon(Icons.message_sharp),
              label: 'Alertas')
        ]);
  }
}
