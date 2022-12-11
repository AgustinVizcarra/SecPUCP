import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';

class EditarNotificacion extends StatefulWidget {
  const EditarNotificacion({super.key, required this.alertaKey});

  final String alertaKey;

  @override
  State<EditarNotificacion> createState() => _EditarNotificacionState();
}

class _EditarNotificacionState extends State<EditarNotificacion> {
  late DatabaseReference dbRef;
  final items = ['Asalto', 'Accidente', 'Incendio', 'Asesinato', 'Otros'];
  final descripcionController = TextEditingController();
  late CameraPosition _cameraPositionInit;
  late Marker _marker;

  String? value;
  File? image;
  double? lat;
  double? lon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('alertas');
  }

  Future updateAlert(Map alert) async {
    if (image == null) {
      //Solo se actualizará
      var valor = value == null ? alert['tipo'] : value;
      if (descripcionController.text == "") {
        Fluttertoast.showToast(
            msg: "Debe rellenar el campo de descripcion",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Map<String, String> map = {
          "descripcion": descripcionController.text,
          "tipo": valor,
        };
        dbRef.child(widget.alertaKey).update(map).then((value) => {
              Fluttertoast.showToast(
                  msg: "Se actualizó correctamente!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 16.0)
            });
      }
    } else {
      if (descripcionController.text == "") {
        Fluttertoast.showToast(
            msg: "Debe rellenar el campo de descripcion",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        final path = "alertas/" + image!.path;
        var task = FirebaseStorage.instance.ref().child(path).putFile(image!);
        final snapshotImagen = await task!.whenComplete(() => {});
        String url = (await snapshotImagen.ref.getDownloadURL()).toString();
        var valor = value == null ? alert['tipo'] : value;
        Map<String, String> map = {
          "descripcion": descripcionController.text,
          "tipo": valor,
          "imagen": url,
        };
        dbRef.child(widget.alertaKey).update(map).then((value) => {
              Fluttertoast.showToast(
                  msg: "Se actualizó correctamente!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 16.0)
            });
      }
    }
  }

  Future getAlert() async {
    DataSnapshot snapshot = await dbRef.child(widget.alertaKey).get();
    Map alert = snapshot.value as Map;
    descripcionController.text = alert['descripcion'];
    return alert;
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
      Fluttertoast.showToast(
          msg: "Es necesario que habilite los permisos",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16.0);
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
          "Añada una foto",
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

  Widget alertaWidget(Map alert) {
    Completer<GoogleMapController> _controller = Completer();
    //Configuraciones del mapa
    var coordenadas = alert['coordenadas'].split(',');
    var lat = double.parse(coordenadas[0]);
    var lon = double.parse(coordenadas[1]);
    _cameraPositionInit = CameraPosition(target: LatLng(lat, lon), zoom: 12.5);
    _marker = Marker(
      markerId: MarkerId("MarkerEditar"),
      position: LatLng(lat, lon),
      icon: BitmapDescriptor.defaultMarker,
    );

    return SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(
                  height: 739,
                  child: Card(
                    color: Color.fromARGB(252, 0, 32, 71),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Editar alerta",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontSize: 18))
                        ],
                      ),
                      SizedBox(height: 5),
                      Text("Tipo: ",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 5),
                      //El dropdown
                      Container(
                          width: 275,
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                value: value == null ? alert['tipo'] : value,
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                iconSize: 24,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Color.fromARGB(255, 0, 90, 141)),
                                items: items.map(buildMenuItem).toList(),
                                onChanged: ((value) => setState(() {
                                      this.value = value;
                                    }))),
                          )),
                      SizedBox(height: 5),
                      Text("Imagen: ",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 5),
                      Center(
                          child: Stack(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 60.0,
                            backgroundImage: NetworkImage(alert['imagen']),
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
                        height: 5,
                      ),
                      Text("Descripcion: ",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 150,
                        child: Card(
                          color: const Color.fromARGB(250, 217, 217, 217),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: TextField(
                                controller: descripcionController,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Ubicacion: ",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 200,
                        child: Card(
                          color: const Color.fromARGB(250, 217, 217, 217),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                              padding: EdgeInsets.all(8),
                              //Aqui va el google maps
                              child: GoogleMap(
                                initialCameraPosition: _cameraPositionInit,
                                markers: {_marker},
                                onMapCreated:
                                    ((GoogleMapController controller) {
                                  _controller.complete(controller);
                                }),
                                onTap: _handleTap,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 30,
                              width: 180,
                              child: ElevatedButton(
                                child: const Text("Actualizar mi alerta"),
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 90, 141),
                                    disabledBackgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25))),
                              ))
                        ],
                      )
                    ]),
                  ),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: secPUCPAppbar2(context),
        body: FutureBuilder(
          future: getAlert(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }
            if (snapshot.connectionState == ConnectionState.done) {
              var information = snapshot.data;
              return alertaWidget(information);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(item,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      );

  void _handleTap(LatLng argument) {
    setState(() {
      _marker = Marker(
        markerId: MarkerId("MarkerEditar"),
        position: argument,
        icon: BitmapDescriptor.defaultMarker,
      );
    });
  }
}
