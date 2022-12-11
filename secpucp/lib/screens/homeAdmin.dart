import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secpucp/bNavigation/bottom_nav_admin.dart';
import 'package:secpucp/bNavigation/bottom_nav_user.dart';
import 'package:secpucp/bNavigation/routes_admin.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';
import 'package:secpucp/screens/welcome.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int index = 0;
  BNavigatorAdmin? bNavigatorAdmin;

  @override
  void initState() {
    bNavigatorAdmin = BNavigatorAdmin(currentIndex: (i) {
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
        bottomNavigationBar: bNavigatorAdmin,
        body: RoutesAdmin(index: index));
  }
}
