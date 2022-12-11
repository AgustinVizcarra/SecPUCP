import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secpucp/screens/alertaPerse.dart';
import 'package:secpucp/screens/welcome.dart';

class NotificacionesUsuario extends StatefulWidget {
  const NotificacionesUsuario({super.key});

  @override
  State<NotificacionesUsuario> createState() => _NotificacionesUsuarioState();
}

class _NotificacionesUsuarioState extends State<NotificacionesUsuario> {
  late DatabaseReference db;
  late int utilVoto;
  late int noutilVoto;
  Query dbRef =
      FirebaseDatabase.instance.ref().child('alertas').orderByChild('fecha');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db = FirebaseDatabase.instance.ref().child('alertas');
    utilVoto = 0;
    noutilVoto = 0;
  }

  Widget listAlerta({required Map alerta}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 170,
      child: Card(
        color: const Color.fromARGB(252, 0, 32, 71),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const SizedBox(width: 25),
          Column(
            children: [
              SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(width: 40),
                  Text(alerta['tipo'],
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontSize: 14)),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  Column(
                    children: [
                      Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AutoSizeText("Hora: ",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            const SizedBox(width: 5),
                            AutoSizeText(alerta['hora'],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12))
                          ]),
                      const SizedBox(height: 2),
                      Row(
                        // ignore: prefer_const_literals_to_create_immutables
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const AutoSizeText("Fecha: ",
                              textAlign: TextAlign.start,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 5),
                          AutoSizeText(alerta['fecha'],
                              textAlign: TextAlign.start,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12))
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AutoSizeText("Lugar: ",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            const SizedBox(width: 5),
                            AutoSizeText(alerta['lugar'],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12))
                          ]),
                    ],
                  ),
                  const SizedBox(width: 35),
                  Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.check_circle,
                                  size: 30,
                                  color: Color.fromARGB(255, 34, 136, 231)),
                              onPressed: (() {
                                //Actualizo
                                int util = alerta['info']['util'];
                                util += 1;
                                if (utilVoto != util) {
                                  Map<String, int> updateUtil = {"util": util};
                                  utilVoto = util;
                                  db
                                      .child(alerta['key'])
                                      .update(updateUtil)
                                      .then((value) => null);
                                }
                              })),
                          const SizedBox(width: 1),
                          IconButton(
                              icon: Icon(
                                  Icons
                                      .do_not_disturb_on_total_silence_outlined,
                                  size: 32,
                                  color: Color.fromARGB(255, 34, 136, 231)),
                              onPressed: (() {
                                int noutil = alerta['info']['noutil'];
                                noutil += 1;
                                if (noutilVoto != noutil) {
                                  Map<String, int> updateUtil = {
                                    "noutil": noutil
                                  };
                                  noutilVoto = noutil;
                                  db
                                      .child(alerta['key'])
                                      .update(updateUtil)
                                      .then((value) => null);
                                }
                              })),
                        ],
                      ),
                      Row(children: [
                        IconButton(
                            onPressed: () {
                              //Proximamente
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AlertaPerse(
                                          alertaKey: alerta['key'])));
                            },
                            icon:
                                Icon(Icons.info, size: 30, color: Colors.white))
                      ]),
                    ],
                  )
                ],
              )
            ],
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 90),
            Text("Tus Notificaciones",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color.fromARGB(255, 2, 105, 165),
                    fontSize: 26))
          ],
        ),
        SizedBox(height: 10),
        FirebaseAnimatedList(
          query: dbRef,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map alerta = snapshot.value as Map;
            alerta['key'] = snapshot.key;
            return listAlerta(alerta: alerta);
          },
        ),
      ]),
    );
  }
}
