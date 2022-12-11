import 'package:flutter/material.dart';
import 'package:secpucp/screens/alertasUsuario.dart';
import 'package:secpucp/screens/inicioUsuario.dart';
import 'package:secpucp/screens/notificacionesUsuario.dart';

class RoutesUsuario extends StatelessWidget {
  final int index;
  const RoutesUsuario({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    List<Widget> rutasUsuario = [
      const InicioUsuario(),
      const NotificacionesUsuario(),
      const AlertasUsuario()
    ];
    return rutasUsuario[index];
  }
}
