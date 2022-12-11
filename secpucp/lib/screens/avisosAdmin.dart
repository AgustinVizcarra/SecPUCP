import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secpucp/screens/addAvisos.dart';
import 'package:secpucp/screens/avisos.dart';
import 'package:secpucp/screens/welcome.dart';

class avisoAdmin extends StatefulWidget {
  const avisoAdmin({super.key});

  @override
  State<avisoAdmin> createState() => _avisoAdminState();
}

class _avisoAdminState extends State<avisoAdmin> {
  final styleLoginAdd = ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 0, 90, 141),
      disabledBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)));
  late DatabaseReference db;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db = FirebaseDatabase.instance.ref().child('avisos');
  }

  Query dbRef =
      FirebaseDatabase.instance.ref().child('avisos').orderByChild('fecha');
  Widget listAviso({required Map aviso}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 150,
      child: Card(
        color: const Color.fromARGB(252, 0, 32, 71),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const SizedBox(width: 25),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const AutoSizeText("Fecha: ",
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 5),
                      AutoSizeText(aviso['fecha'],
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white, fontSize: 12))
                    ]),
                const SizedBox(height: 2),
                Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const AutoSizeText("Hora: ",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(width: 5),
                    AutoSizeText(aviso['hora'],
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white, fontSize: 12))
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                    // ignore: prefer_const_literals_to_create_immutable
                    children: [
                      //Eliminar
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        title: Text("Confirmación"),
                                        content:
                                            Text("¿Desea eliminar el aviso?"),
                                        actions: [
                                          TextButton(
                                              onPressed: (() {
                                                // Eliminacion de firebase
                                                db.child(aviso['key']).remove();
                                                Navigator.pop(context);
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "La notificación ha sido eliminada exitosamente",
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
                              size: 30,
                              color: Color.fromARGB(255, 0, 162, 255))),
                      //Espacio
                      SizedBox(width: 12),
                      //Editar
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Avisos(avisoKey: aviso['key'])));
                          },
                          icon: Icon(Icons.edit,
                              size: 30,
                              color: Color.fromARGB(255, 0, 162, 255)))
                    ]),
                const SizedBox(height: 2),
              ],
            ),
            const SizedBox(width: 15),
            Column(
              children: [
                SizedBox(height: 5),
                SizedBox(
                    height: 100,
                    width: 200,
                    child: Card(
                        color: const Color.fromARGB(250, 217, 217, 217),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: AutoSizeText(
                            aviso['descripcion'],
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            minFontSize: 12,
                            maxFontSize: 18,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )))
              ],
            )
          ],
        ),
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
                Text("Tus Avisos",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color.fromARGB(255, 2, 105, 165),
                        fontSize: 28)),
                SizedBox(width: 59),
                SizedBox(
                    height: 30,
                    width: 140,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AvisosAdd()));
                        },
                        style: styleLoginAdd,
                        child: const Text("Crear un Aviso"))),
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
                Map aviso = snapshot.value as Map;
                aviso['key'] = snapshot.key;
                return listAviso(aviso: aviso);
              },
            ),
          ],
        ));
  }
}
