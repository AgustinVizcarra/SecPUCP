// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';
import 'package:secpucp/screens/login.dart';
import 'package:secpucp/screens/welcome.dart';
import 'package:crypto/crypto.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _nombresEditingController = TextEditingController();
    TextEditingController _apellidosEditingController = TextEditingController();
    TextEditingController _codigoEditingController = TextEditingController();
    TextEditingController _passwordEditingController = TextEditingController();
    TextEditingController _emailEditingController = TextEditingController();
    bool _emailValid = false;
    bool _codigoValid = false;
    bool _nombresValid = false;
    bool _apellidosValid = false;
    bool _passwordValid = false;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final reference = FirebaseDatabase.instance;
    final styleLoginButton = ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 90, 141),
        disabledBackgroundColor: Colors.white);
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 100,
          elevation: 0,
          title: const Text(
            "Registro",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/secPUCPWelcomeBackground.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/secpucpLogo.png", 120, 120),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Nombres",
                    Icons.abc,
                    false,
                    _nombresEditingController,
                    _nombresValid,
                    "Debe ingresar un nombre"),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Apellido",
                    Icons.abc,
                    false,
                    _apellidosEditingController,
                    _apellidosValid,
                    "Debe ingresar un apellido"),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Codigo PUCP",
                    Icons.numbers,
                    false,
                    _codigoEditingController,
                    _codigoValid,
                    "Debe ingresar un codigo"),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Correo Personal",
                    Icons.mail,
                    false,
                    _emailEditingController,
                    _emailValid,
                    "Debe ingresar un correo"),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Contraseña",
                    Icons.lock,
                    true,
                    _passwordEditingController,
                    _passwordValid,
                    "Debe ingresar una contraseña"),
                const SizedBox(height: 60),
                SizedBox(
                    height: 45,
                    width: 150,
                    child: ElevatedButton(
                        onPressed: () {
                          bool nombreVacios =
                              _nombresEditingController.text.isEmpty;
                          bool apellidosVacios =
                              _apellidosEditingController.text.isEmpty;
                          bool codigoVacio =
                              _codigoEditingController.text.isEmpty;
                          bool correoVacio =
                              _emailEditingController.text.isEmpty;
                          bool passwordVacio =
                              _passwordEditingController.text.isEmpty;
                          if (nombreVacios ||
                              apellidosVacios ||
                              codigoVacio ||
                              correoVacio ||
                              passwordVacio) {
                            Fluttertoast.showToast(
                                msg: "Por favor llene todos los campos",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.blueAccent,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else {
                            auth
                                .createUserWithEmailAndPassword(
                                    email: _emailEditingController.text,
                                    password: sha256
                                        .convert(utf8.encode(
                                            _passwordEditingController.text))
                                        .toString())
                                .then((value) async {
                              //Creo el usuario
                              String key = auth.currentUser!.uid;
                              //Si es que lo chapa
                              await reference.ref("usuarios/" + key).set({
                                "id": key,
                                "nombres": _nombresEditingController.text,
                                "apellidos": _apellidosEditingController.text,
                                "codigo": _codigoEditingController.text,
                                "email": _emailEditingController.text,
                                "password": sha256
                                    .convert(utf8.encode(
                                        _passwordEditingController.text))
                                    .toString(),
                                "estado": 1,
                                "rol": 1,
                                "foto":
                                    "https://firebasestorage.googleapis.com/v0/b/secpucp.appspot.com/o/usuarios%2FfotoDePerfil.jpg?alt=media&token=042af9a5-dacd-4224-a9dd-6944b795bfa3",
                                "info": {"notificaciones": 0, "reportes": 0}
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WelcomeScreen()));
                            });
                          }
                        },
                        style: styleLoginButton,
                        child: const Text("Registrarse"))),
                const SizedBox(
                  height: 40,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("¿Ya tienes una cuenta?  ",
                      style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: const Text("Logueate",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)))
                ])
              ],
            ),
          )),
        ));
  }
}
