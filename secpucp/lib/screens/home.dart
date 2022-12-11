import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:secpucp/bNavigation/bottom_nav_user.dart';
import 'package:secpucp/bNavigation/routes_usuario.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';
import 'package:secpucp/screens/login.dart';
import 'package:secpucp/screens/welcome.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;
  BNavigatorUser? bNavigatorUser;

  @override
  void initState() {
    bNavigatorUser = BNavigatorUser(currentIndex: (i) {
      setState(() {
        index = i;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: secPUCPAppbar(context),
        bottomNavigationBar: bNavigatorUser,
        body: RoutesUsuario(index: index));
  }
}
