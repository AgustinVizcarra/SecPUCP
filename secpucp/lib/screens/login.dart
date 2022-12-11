import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';
import 'package:secpucp/screens/home.dart';
import 'package:secpucp/screens/homeAdmin.dart';
import 'package:secpucp/screens/registro.dart';
import 'package:crypto/crypto.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final _auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance;

  void _asincLogin(String email, String password, BuildContext context) async {
    try {
      final newUser = await _auth.signInWithEmailAndPassword(
          email: email,
          password: sha256.convert(utf8.encode(password)).toString());
      if (newUser != null) {
        final uid = newUser.user!.uid;
        final snapshot = await dbRef.ref("usuarios/" + uid + "/rol").get();
        if (snapshot.exists) {
          if (snapshot.value == 1) {
            //En Usuario
            print("Usuario!");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
          } else {
            //En Admin
            print("Admin!");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeAdmin()));
          }
        } else {
          Fluttertoast.showToast(
              msg: "Su cuenta ha sido eliminada",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.blueAccent,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Credenciales invalidas!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "Credenciales invalidas!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _passwordEditingController = TextEditingController();
    TextEditingController _emailEditingController = TextEditingController();
    bool _emailValid = false;
    bool _passwordValid = false;
    final styleLoginButton = ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 0, 90, 141),
        disabledBackgroundColor: Colors.white);
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 120,
          elevation: 0,
          title: const Text(
            "Login",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints.expand(),
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
                logoWidget("assets/images/secpucpLogo.png", 240, 240),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField(
                    "Correo Electrónico",
                    Icons.account_circle,
                    false,
                    _emailEditingController,
                    _emailValid,
                    "Debe ingresar un correo"),
                const SizedBox(
                  height: 50,
                ),
                reusableTextField(
                    "Contraseña",
                    Icons.lock,
                    true,
                    _passwordEditingController,
                    _passwordValid,
                    "Debe ingresar una contraseña"),
                const SizedBox(height: 80),
                SizedBox(
                    height: 45,
                    width: 150,
                    child: ElevatedButton(
                        onPressed: () {
                          bool validateEmail =
                              _emailEditingController.text.isEmpty;
                          bool validatePassword =
                              _passwordEditingController.text.isEmpty;
                          if (validateEmail || validatePassword) {
                            Fluttertoast.showToast(
                                msg: "Hay campos vacios",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.blueAccent,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else {
                            _asincLogin(_emailEditingController.text,
                                _passwordEditingController.text, context);
                          }
                        },
                        style: styleLoginButton,
                        child: const Text("Iniciar Sesión"))),
                const SizedBox(
                  height: 90,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("¿Aun no tienes cuenta?  ",
                      style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Registro()));
                      },
                      child: const Text("Registrate",
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
