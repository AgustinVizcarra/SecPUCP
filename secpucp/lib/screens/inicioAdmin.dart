import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secpucp/screens/alertaPerse.dart';
import 'package:secpucp/screens/welcome.dart';

class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioAdmin> {
  late DatabaseReference db;
  late DatabaseReference dbUser;
  Query dbRef =
      FirebaseDatabase.instance.ref().child('alertas').orderByChild('fecha');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db = FirebaseDatabase.instance.ref().child('alertas');
    dbUser = FirebaseDatabase.instance.ref().child('usuarios');
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
              SizedBox(height: 15),
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
                      const SizedBox(height: 2),
                      Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AutoSizeText("Usuario: ",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            const SizedBox(width: 5),
                            AutoSizeText(alerta['usuario'],
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
                          Icon(Icons.check_circle,
                              size: 27, color: Colors.blueAccent),
                          const SizedBox(width: 1),
                          Text(alerta['info']['util'].toString(),
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(width: 17),
                          Icon(Icons.do_not_disturb_on_total_silence_outlined,
                              size: 27, color: Colors.redAccent),
                          const SizedBox(width: 1),
                          Text(alerta['info']['noutil'].toString(),
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      SizedBox(width: 10),
                      Row(children: [
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                          title: Text("Confirmación"),
                                          content: Text(
                                              "¿Desea eliminar la notificacion seleccionado?"),
                                          actions: [
                                            TextButton(
                                                onPressed: (() async {
                                                  //Actualizamos reportes
                                                  String key = alerta['id'];
                                                  //Se suma a reportes de usuario!
                                                  DataSnapshot snapshot =
                                                      await dbUser
                                                          .child(key)
                                                          .get();
                                                  Map usuario =
                                                      snapshot.value as Map;
                                                  Map<String, Object>
                                                      updateCounter = {
                                                    'info': {
                                                      'reportes':
                                                          usuario['info']
                                                                  ['reportes'] +
                                                              1,
                                                      'notificaciones': usuario[
                                                                  'info'][
                                                              'notificaciones'] -
                                                          1
                                                    }
                                                  };
                                                  dbUser
                                                      .child(key)
                                                      .update(updateCounter)
                                                      .then((value) => {});
                                                  // Eliminacion de firebase
                                                  db
                                                      .child(alerta['key'])
                                                      .remove();
                                                  Navigator.pop(context);
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "La alerta ha sido eliminada exitosamente",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.blueAccent,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0);
                                                }),
                                                child: Text("Sí")),
                                            TextButton(
                                                onPressed: (() {
                                                  Navigator.pop(context);
                                                }),
                                                child: Text("No")),
                                          ]));
                            },
                            icon: Icon(Icons.delete_forever,
                                size: 30, color: Colors.white)),
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
            SizedBox(width: 40),
            Text("Notificaciones Recientes",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color.fromARGB(255, 2, 105, 165),
                    fontSize: 28))
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
