import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secpucp/bNavigation/bottom_nav_user.dart';
import 'package:secpucp/screens/login.dart';
import 'package:secpucp/screens/welcome.dart';
import 'package:auto_size_text/auto_size_text.dart';

class UsuariosAdmin extends StatefulWidget {
  const UsuariosAdmin({super.key});

  @override
  State<UsuariosAdmin> createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  Query dbRef = FirebaseDatabase.instance
      .ref()
      .child('usuarios')
      .orderByChild('rol')
      .equalTo(1);
  final List l = [];
  late DatabaseReference dbAlertas;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbAlertas = FirebaseDatabase.instance.ref().child('alertas');
  }

  void eliminarAlertas(String id) async {
    try {
      var result = await dbAlertas.orderByChild('id').equalTo(id).get();
      Map data = result.value as Map;
      data.forEach((key, value) => l.add(key));
      if (l.length > 0) {
        for (var i = 0; i < l.length; i++) {
          dbAlertas.child(l[i]).remove();
        }
      }
    } catch (e) {
      print("El usuario no tenia notificaciones");
    }
  }

  Widget listUsuario({required Map usuario}) {
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
              children: [
                const SizedBox(height: 35),
                Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const AutoSizeText("Nombre: ",
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 5),
                      AutoSizeText(usuario['nombres'],
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white, fontSize: 12))
                    ]),
                const SizedBox(height: 2),
                Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const AutoSizeText("Apellidos: ",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(width: 5),
                    AutoSizeText(usuario['apellidos'],
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white, fontSize: 12))
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const AutoSizeText("Codigo: ",
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 5),
                      AutoSizeText(usuario['codigo'],
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white, fontSize: 12))
                    ]),
                const SizedBox(height: 2),
              ],
            ),
            const SizedBox(width: 65),
            Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.block_flipped, size: 25, color: Colors.white),
                    const SizedBox(width: 1),
                    Text(usuario['info']['reportes'].toString(),
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.notifications, size: 25, color: Colors.white),
                    const SizedBox(width: 1),
                    Text(usuario['info']['notificaciones'].toString(),
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                      title: Text("Confirmación"),
                                      content: Text(
                                          "¿Desea eliminar el usuario seleccionado?"),
                                      actions: [
                                        TextButton(
                                            onPressed: (() async {
                                              //Eliminacion de todos las alertas
                                              eliminarAlertas(usuario['key']);
                                              // Eliminacion de firebase
                                              FirebaseDatabase.instance
                                                  .ref()
                                                  .child('usuarios')
                                                  .child(usuario['key'])
                                                  .remove();
                                              Navigator.pop(context);
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "El usuario se ha eliminado exitosamente",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
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
                            size: 30, color: Color.fromARGB(255, 0, 162, 255))),
                  ],
                )
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
                SizedBox(width: 135),
                Text("Usuarios",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color.fromARGB(255, 2, 105, 165),
                        fontSize: 28))
              ],
            ),
            SizedBox(height: 20),
            //Aqui va el listado
            FirebaseAnimatedList(
              query: dbRef,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                Map usuario = snapshot.value as Map;
                usuario['key'] = snapshot.key;
                return listUsuario(usuario: usuario);
              },
            ),
          ],
        ));
  }
}
