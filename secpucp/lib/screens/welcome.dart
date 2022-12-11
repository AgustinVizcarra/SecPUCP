import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';
import 'package:secpucp/screens/login.dart';
import 'package:secpucp/screens/registro.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final styleLoginButton = ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 0, 90, 141),
        disabledBackgroundColor: Colors.white);
    final styleRegisterButton = ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 11, 166, 254),
        disabledBackgroundColor: Colors.white);
    return Scaffold(
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
        padding: EdgeInsets.fromLTRB(
            30, MediaQuery.of(context).size.height * 0, 30, 0),
        child: Column(
          children: <Widget>[
            logoWidget("assets/images/secpucpLogo.png", 210, 210),
            const Text(
                "Este es un aplicativo desarrollado con el fin de proporcionar un sistema de alerta en los alrededores de la PUCP",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            SizedBox(
                height: 50,
                width: 120,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    style: styleLoginButton,
                    child: const Text("Loguearse"))),
            const SizedBox(height: 30),
            SizedBox(
                height: 50,
                width: 120,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Registro()));
                    },
                    style: styleRegisterButton,
                    child: const Text("Registrarse"))),
          ],
        ),
      )),
    ));
  }
}
