import 'package:flutter/material.dart';
import 'package:secpucp/screens/avisosAdmin.dart';
import 'package:secpucp/screens/inicioAdmin.dart';
import 'package:secpucp/screens/usuariosAdmin.dart';

class RoutesAdmin extends StatelessWidget {
  final int index;
  const RoutesAdmin({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    List<Widget> rutasAdmin = [
      const InicioAdmin(),
      const UsuariosAdmin(),
      const avisoAdmin()
    ];
    return rutasAdmin[index];
  }
}
