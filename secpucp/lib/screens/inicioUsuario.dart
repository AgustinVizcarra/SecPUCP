import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:secpucp/screens/welcome.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InicioUsuario extends StatefulWidget {
  const InicioUsuario({super.key});

  @override
  State<InicioUsuario> createState() => _InicioUsuarioState();
}

class _InicioUsuarioState extends State<InicioUsuario> {
  late CameraPosition _cameraPositionInit;
  late DatabaseReference dbRef;
  final Set<Marker> listMarkers = new Set();

  final List l = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('alertas');
  }

  Future getAlerts() async {
    //Aqui obtendré todas mis alertas!
    Query query = dbRef;
    var result = await query.get();
    Map data = result.value as Map;
    data.forEach((key, value) => l.add(value));
    //Añadimos el primer valor de la lista
    if (l.length == 0) {
      //Seteamos una posicion por defecto
      _cameraPositionInit = CameraPosition(
          target: LatLng(-12.06876909848102, -77.07850266247988), zoom: 12.5);
    } else {
      //Obtenemos el primer valor de la lista
      var primerValor = l[0];
      var coordenadas = primerValor['coordenadas'].split(',');
      var lat = double.parse(coordenadas[0]);
      var lon = double.parse(coordenadas[1]);
      _cameraPositionInit =
          CameraPosition(target: LatLng(lat, lon), zoom: 12.5);
    }
    //Añadimos todos los marcadores para luego mostrarlos en el mapa!
    for (var i = 0; i < l.length; i++) {
      print("Iterando: " + i.toString());
      var valor = l[i];
      var coordenadas = valor['coordenadas'].split(',');
      var lat = double.parse(coordenadas[0]);
      var lon = double.parse(coordenadas[1]);
      var color;
      switch (valor['tipo']) {
        case "Asalto":
          {
            color =
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          }
          break;
        case "Accidente":
          {
            color =
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
          }
          break;
        case "Incendio":
          {
            color = BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueYellow);
          }
          break;
        case "Asesinato":
          {
            color = BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueMagenta);
          }
          break;
        default:
          {
            color = BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen);
          }
          break;
      }
      listMarkers.add(Marker(
        markerId: MarkerId("Marker" + i.toString()),
        position: LatLng(lat, lon),
        infoWindow:
            InfoWindow(title: valor['tipo'], snippet: valor['descripcion']),
        icon: color,
      ));
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    Completer<GoogleMapController> _controller = Completer();
    return Scaffold(
        body: FutureBuilder(
      future: getAlerts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          var information = snapshot.data;
          return GoogleMap(
              initialCameraPosition: _cameraPositionInit,
              markers: listMarkers,
              onMapCreated: ((GoogleMapController controller) {
                _controller.complete(controller);
              }));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    ));
  }
}
