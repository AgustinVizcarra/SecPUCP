import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:secpucp/reusable_widgets/reusable_widget.dart';

class AlertaPerse extends StatefulWidget {
  const AlertaPerse({super.key, required this.alertaKey});

  final String alertaKey;

  @override
  State<AlertaPerse> createState() => _AlertaPerseState();
}

class _AlertaPerseState extends State<AlertaPerse> {
  late DatabaseReference dbRef;
  late CameraPosition _cameraPositionInit;
  late Marker _marker;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('alertas');
  }

  Future getAlert() async {
    DataSnapshot snapshot = await dbRef.child(widget.alertaKey).get();
    Map alert = snapshot.value as Map;
    return alert;
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
                          Text(alert['tipo'],
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontSize: 18))
                        ],
                      ),
                      SizedBox(height: 5),
                      Text("Fecha: ",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 5),
                      //El dropdown
                      Text(alert['fecha'],
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 5),
                      Text("Hora: ",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 5),
                      Text(alert['hora'],
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 5),
                      Center(
                          child: Stack(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 60.0,
                            backgroundImage: NetworkImage(alert['imagen']),
                          ),
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
                            child: Text(alert['descripcion'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
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
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
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
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                var map = snapshot.data;
                return alertaWidget(map);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
            future: getAlert()));
  }
}
