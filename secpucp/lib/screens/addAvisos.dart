import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';
import 'package:intl/intl.dart';

class AvisosAdd extends StatefulWidget {
  const AvisosAdd({super.key});

  @override
  State<AvisosAdd> createState() => _AvisosAddState();
}

class _AvisosAddState extends State<AvisosAdd> {
  final styleLoginAdd = ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 0, 90, 141),
      disabledBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)));
  final descripcionController = TextEditingController();
  late DatabaseReference dbRef;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('avisos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: secPUCPAppbar2(context),
        body: Center(
          child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("Cree un aviso",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color.fromARGB(255, 2, 105, 165),
                          fontSize: 28)),
                  SizedBox(height: 20),
                  SizedBox(
                      height: 550,
                      child: Card(
                          color: Color.fromARGB(252, 0, 32, 71),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  SizedBox(height: 12),
                                  Text("Descripci??n: ",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    height: 400,
                                    child: Card(
                                      color: const Color.fromARGB(
                                          250, 217, 217, 217),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: TextField(
                                            controller: descripcionController,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      SizedBox(width: 90),
                                      SizedBox(
                                          height: 30,
                                          width: 160,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                //Aqui viene la magia
                                                if (descripcionController
                                                    .text.isEmpty) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "El aviso no puede estar vac??o",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.blueAccent,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0);
                                                } else {
                                                  var now = new DateTime.now();
                                                  var formatterFecha =
                                                      new DateFormat(
                                                          'dd-MM-yyyy');
                                                  var formatterHora =
                                                      new DateFormat.jm();
                                                  String hora =
                                                      formatterHora.format(now);
                                                  String fecha = formatterFecha
                                                      .format(now);
                                                  Map<String, String> aviso = {
                                                    'descripcion':
                                                        descripcionController
                                                            .text,
                                                    'hora': hora,
                                                    'fecha': fecha
                                                  };
                                                  //guardado en firebase
                                                  dbRef.push().set(aviso).then(
                                                      (value) => Navigator.pop(
                                                          context));
                                                }
                                              },
                                              style: styleLoginAdd,
                                              child:
                                                  const Text("Crear Aviso"))),
                                    ],
                                  )
                                ],
                              ))))
                ],
              )),
        ));
  }
}
