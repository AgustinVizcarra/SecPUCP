import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:secpucp/screens/addAlerta.dart';
import 'package:secpucp/screens/alertaPerse.dart';
import 'package:secpucp/screens/editarAlerta.dart';
import 'package:secpucp/screens/welcome.dart';

class AlertasUsuario extends StatefulWidget {
  const AlertasUsuario({super.key});

  @override
  State<AlertasUsuario> createState() => _AlertasUsuarioState();
}

class _AlertasUsuarioState extends State<AlertasUsuario> {
  final styleLoginAdd = ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 0, 90, 141),
      disabledBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)));
  late Query dbRef;
  late DatabaseReference db;
  late DatabaseReference dbUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String key = FirebaseAuth.instance.currentUser!.uid;
    dbRef = FirebaseDatabase.instance
        .ref()
        .child('alertas')
        .orderByChild('id')
        .equalTo(key);
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
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                            title: Text("Confirmación"),
                                            content: Text(
                                                "¿Desea eliminar la alerta seleccionada?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: (() async {
                                                    // Eliminacion de firebase
                                                    DataSnapshot snapshot =
                                                        await dbUser
                                                            .child(alerta['id'])
                                                            .get();
                                                    Map usuario =
                                                        snapshot.value as Map;
                                                    Map<String, Object>
                                                        updateCounter = {
                                                      'info': {
                                                        'reportes':
                                                            usuario['info']
                                                                ['reportes'],
                                                        'notificaciones': usuario[
                                                                    'info'][
                                                                'notificaciones'] -
                                                            1
                                                      }
                                                    };
                                                    dbUser
                                                        .child(alerta['id'])
                                                        .update(updateCounter)
                                                        .then((value) => {});
                                                    db
                                                        .child(alerta['key'])
                                                        .remove();
                                                    Navigator.pop(context);
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "La alerta se ha eliminado exitosamente",
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
                          const SizedBox(width: 1),
                          IconButton(
                              icon: Icon(Icons.edit,
                                  size: 32, color: Colors.white),
                              onPressed: (() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditarNotificacion(
                                                alertaKey: alerta['key'])));
                              })),
                        ],
                      ),
                      Row(children: [
                        IconButton(
                            onPressed: () {
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
        height: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 32),
                Text("Tus Alertas",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color.fromARGB(255, 2, 105, 165),
                        fontSize: 28)),
                SizedBox(width: 50),
                SizedBox(
                    height: 30,
                    width: 150,
                    child: ElevatedButton(
                        onPressed: () {
                          //Proximamente
                          getUserCurrentLocation(context);
                        },
                        style: styleLoginAdd,
                        child: const Text("Crear una alerta"))),
              ],
            ),
            //Espaciamiento
            SizedBox(height: 5),
            //Aqui va el listado
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
          ],
        ));
  }

  void getUserCurrentLocation(BuildContext context) async {
    await Geolocator.requestPermission()
        .then(((value) {}))
        .onError((error, stackTrace) {
      Fluttertoast.showToast(
          msg: "Es necesario que habilite los permisos",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    });
    var coord = await Geolocator.getCurrentPosition();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddAlerta(coordenadas: coord)));
  }
}
