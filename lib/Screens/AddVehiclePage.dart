import 'dart:convert';
import 'package:facturas/Objects/VehiculoMensualidad.dart';
import 'package:facturas/Screens/Home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter_calendar/flutter_calendar.dart';

import '../Objects/Vehiculo.dart';

class AddVehiclePage extends StatefulWidget{
  bool esParticular;
  AddVehiclePage({ Key key, @required this.esParticular }) : super(key: key);
  @override
  AddVehiclePageState createState()=> AddVehiclePageState();
}
class AddVehiclePageState extends State<AddVehiclePage>{

  final controller = TextEditingController();
  List<Vehiculo> vehiculos = [];
  List<VehiculoMensualidad> vehiculosMensuales = [];
  String _placaAlfabetica = "";
  String _placaNumerica = "";

  @override
  void initState() {
    super.initState();
    this.getCarsFromJson();
    controller.addListener(listen);
  }
  void getCarsFromJson() async{
    if(widget.esParticular==true){
      final String membershipKey = 'jsoncars';
      SharedPreferences sp = await SharedPreferences.getInstance();
      json
          .decode(sp.getString(membershipKey))
          .forEach((map) => vehiculos.add(new Vehiculo.fromJson(map)));
    }else{
      final String membershipKey = 'jsoncarsm';
      SharedPreferences sp = await SharedPreferences.getInstance();
      json
          .decode(sp.getString(membershipKey))
          .forEach((map) => vehiculosMensuales.add(new VehiculoMensualidad.fromJson(map)));

    }

  }
  void listen() {
    print("Second text field: ${controller.text}");
    _placaNumerica=controller.text;
  }

  @override
  Widget build(BuildContext context) {
    BuildContext contexto = context;
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Vehiculo'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                  flex: 5,
                  child: new Container(
                    width: 160.0,
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                        onChanged: (text) {
                          print("First text field: $text");
                          _placaAlfabetica=text;
                        },
                        decoration: const InputDecoration(
                            labelText: 'Placas Alfabeticas')
                    ),
                  )
              ),
              new Expanded(
                  flex: 5,
                  child: new Container(
                    width: 160.0,
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            labelText: 'Placas Numericas')
                    ),
                  )
              )
            ],

          ),

          RaisedButton(
              onPressed: () {
                _AddNewVehicle();
                this._launchFirstScreen();
              },
              color: Theme
                  .of(contexto)
                  .accentColor,
              padding: EdgeInsets.all(10),
              child:
              Center(child: Text('Guardar'))

          ),
        ],

      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  void _launchFirstScreen(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
  }
  void _AddNewVehicle() async {

    if(_placaAlfabetica.length==3){
      if(_placaNumerica.length>=2 &&_placaNumerica.length<4){
        var now = new DateTime.now();
        if(widget.esParticular==true){
          Vehiculo _vehiculo= new Vehiculo(_placaAlfabetica+"-"+_placaNumerica, now.toString(), "");
          vehiculos.add(_vehiculo);
          _PersistParticularVehicles();
        }else{
          VehiculoMensualidad _car=new VehiculoMensualidad(_placaAlfabetica+"-"+_placaNumerica, now.toString(), "");
          vehiculosMensuales.add(_car);
          _PersistMonthlyVehicles();
        }
      }
    }

  }
  void _PersistParticularVehicles() async{
    final String membershipKey = 'jsoncars'; // maybe use your domain + appname
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(membershipKey, json.encode(vehiculos));
  }
  void _PersistMonthlyVehicles() async{
    final String membershipKey = 'jsoncarsm'; // maybe use your domain + appname
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(membershipKey, json.encode(vehiculosMensuales));
  }
}
