import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';

class AddAlerta extends StatefulWidget {
  const AddAlerta({super.key, required this.coordenadas});
  final Position coordenadas;
  @override
  State<AddAlerta> createState() => _AddAlertaState();
}

class _AddAlertaState extends State<AddAlerta> {
  late DatabaseReference dbRef;
  late DatabaseReference dbUsuarios;
  final items = ['Asalto', 'Accidente', 'Incendio', 'Asesinato', 'Otros'];
  final descripcionController = TextEditingController();
  final lugarController = TextEditingController();
  late CameraPosition _cameraPositionInit;
  late Marker _marker;
  File? image;

  String? value;
  double? lat;
  double? lon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('alertas');
    dbUsuarios = FirebaseDatabase.instance.ref().child('usuarios');
  }

  Future addAlert(BuildContext context) async {
    var imageNull = image == null;
    var descripcionVacia = descripcionController.text.isEmpty;
    var lugarVacio = lugarController.text.isEmpty;
    var tipoVacio = value == null;
    if (imageNull || descripcionVacia || lugarVacio || tipoVacio) {
      Fluttertoast.showToast(
          msg: "Todos los campos deben estar llenos",
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
      String id = FirebaseAuth.instance.currentUser!.uid;
      DataSnapshot snapshot = await dbUsuarios.child(id).get();
      Map usuario = snapshot.value as Map;
      String usuarioNombre = usuario['nombres'];
      String coordenadas = widget.coordenadas.latitude.toString() +
          "," +
          widget.coordenadas.longitude.toString();
      var now = new DateTime.now();
      var formatterFecha = new DateFormat('dd-MM-yyyy');
      var formatterHora = new DateFormat.jm();
      String hora = formatterHora.format(now);
      String fecha = formatterFecha.format(now);
      String lugar = lugarController.text;
      String descripcion = descripcionController.text;
      String tipo = value!;
      Map<String, Object> map = {
        'coordenadas': coordenadas,
        'descripcion': descripcion,
        'fecha': fecha,
        'hora': hora,
        'id': id,
        'imagen': url,
        'info': {'noutil': 0, 'util': 0},
        'lugar': lugar,
        'tipo': tipo,
        'usuario': usuarioNombre
      };
      Map<String, Object> updateCounter = {
        'info': {
          'reportes': usuario['info']['reportes'],
          'notificaciones': usuario['info']['notificaciones'] + 1
        }
      };
      dbUsuarios.child(id).update(updateCounter).then((value) => {});
      dbRef.push().set(map).then((value) => (Navigator.pop(context)));
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

  Widget alertaWidget() {
    Completer<GoogleMapController> _controller = Completer();
    //Configuraciones del mapa
    _cameraPositionInit = CameraPosition(
        target:
            LatLng(widget.coordenadas.latitude, widget.coordenadas.longitude),
        zoom: 13);
    _marker = Marker(
      markerId: MarkerId("MarkerEditar"),
      position:
          LatLng(widget.coordenadas.latitude, widget.coordenadas.longitude),
      infoWindow: InfoWindow(title: "Mi ubicacion actual"),
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
                          Text("Crear alerta",
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
                                value: value,
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
                            backgroundImage:
                                AssetImage("assets/images/imagenSubir.png"),
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
                                      color: Colors.white, size: 28.0)))
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
                        height: 70,
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
                      Text("Lugar: ",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 40,
                        child: Card(
                          color: const Color.fromARGB(250, 217, 217, 217),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: TextField(
                                controller: lugarController,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14)),
                          ),
                        ),
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
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 30,
                              width: 180,
                              child: ElevatedButton(
                                child: const Text("Crear alerta"),
                                onPressed: () {
                                  addAlert(context);
                                },
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
      body: alertaWidget(),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(item,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      );
}
