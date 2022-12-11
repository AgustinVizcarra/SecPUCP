import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';
import 'package:secpucp/screens/welcome.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.profileKey});

  final String profileKey;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? image;

  final nombreController = TextEditingController();
  final correoController = TextEditingController();

  late String url = "";
  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('usuarios');
  }

  Future getProfile() async {
    DataSnapshot snapshot = await dbRef.child(widget.profileKey).get();
    Map profile = snapshot.value as Map;
    return profile;
  }

  Future uploadFile() async {
    if (image == null) {
      Fluttertoast.showToast(
          msg: "Añada una imagen ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      final path = "usuarios/" + image!.path;
      var task = FirebaseStorage.instance.ref().child(path).putFile(image!);
      final snapshotImagen = await task!.whenComplete(() => {});
      String url = (await snapshotImagen.ref.getDownloadURL()).toString();
      Map<String, String> actualizacion = {
        "foto": url,
      };
      FirebaseDatabase.instance
          .ref()
          .child('usuarios')
          .child(widget.profileKey)
          .update(actualizacion)
          .then((value) => {
                Fluttertoast.showToast(
                    msg: "Se ha actualizado la foto de Perfil!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    fontSize: 16.0)
              });
    }
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
        Fluttertoast.showToast(
            msg: "Se ha cargado la imagen exitosamente",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    } on PlatformException catch (e) {
      print("Se denegaron los permisos");
    }
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(children: <Widget>[
        Text(
          "Escoja su foto de perfil",
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  pickImage(ImageSource.camera);
                },
                icon: Icon(Icons.camera)),
            SizedBox(
              width: 1,
            ),
            Text("Camara"),
            IconButton(
                onPressed: () {
                  pickImage(ImageSource.gallery);
                },
                icon: Icon(Icons.image)),
            SizedBox(
              width: 20,
            ),
            Text("Galeria"),
          ],
        )
      ]),
    );
  }

  Widget perfilWidget(String url, String nombre, String correo) {
    return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Mi perfil",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Color.fromARGB(255, 2, 105, 165),
                      fontSize: 24))
            ],
          ),
          SizedBox(height: 30),
          Center(
              child: Stack(
            children: <Widget>[
              CircleAvatar(
                radius: 80.0,
                backgroundImage: NetworkImage(url),
              ),
              Positioned(
                  bottom: 20.0,
                  right: 20.0,
                  child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (builder) => bottomSheet());
                      },
                      child: Icon(Icons.camera_alt,
                          color: Colors.blueAccent, size: 28.0)))
            ],
          )),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 150,
            child: Card(
                color: Color.fromARGB(252, 0, 32, 71),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Tu información",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.white,
                                fontSize: 18))
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Nombre: ",
                            textAlign: TextAlign.right,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(width: 2),
                        Text(nombre,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(children: [
                      Text("Correo: ",
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(width: 2),
                      Text(correo,
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ]),
                  ],
                )),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 40,
                  width: 180,
                  child: ElevatedButton(
                    child: const Text("Actualizar mi perfil"),
                    onPressed: () {
                      uploadFile();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 90, 141),
                        disabledBackgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                  ))
            ],
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final styleLoginAdd = ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 0, 90, 141),
        disabledBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)));

    return Scaffold(
        appBar: secPUCPAppbar2(context),
        body: FutureBuilder(
            future: getProfile(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                var information = snapshot.data;
                return perfilWidget(information['foto'], information['nombres'],
                    information['email']);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}
