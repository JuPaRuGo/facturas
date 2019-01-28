import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter_calendar/flutter_calendar.dart';

import '../Objects/VehiculoMensualidad.dart';

class MensualitiesScreen extends StatefulWidget{

  MensualitiesScreen({Key key}): super(key: key);
  @override
  _StateMensualities createState()=> _StateMensualities();

}
class _StateMensualities extends State<MensualitiesScreen> {
  List<VehiculoMensualidad> vehiculos;
  var isLoading = false;
  String json_string;
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    vehiculos=new List<VehiculoMensualidad>();
    //this.getCarsFromJson();
    this._fetchData("");

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensualidades"),
      ),
      body: Container(
          child: Column(
            children: <Widget>[
            new Expanded(
              flex: 10,
              child: _buildList(),
            ),
            new Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                    child: new RaisedButton(
                      child: const Text('Subir'),
                      color: Colors.indigo,
                      textColor: Colors.white,
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      onPressed: () {
                        // Perform some action
                      },
                    ),
                    padding: EdgeInsets.all(8),
                    ),
                    Container(
                      child: new RaisedButton(
                        child: const Text('Traer'),
                        color: Colors.teal,
                        textColor: Colors.white,
                        elevation: 4.0,
                        splashColor: Colors.blueGrey,
                        onPressed: () {
                          // Perform some action
                        },
                      ),

                      padding: EdgeInsets.all(8),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      tooltip: 'Calendario',
                      onPressed: () {
                        setState(() {
                          _selectDate(context);
                          print("fecha"+DateFormat("yyy-MM-dd").format(selectedDate).toString());
                          this._fetchData(DateFormat("yyy-MM-dd").format(selectedDate).toString());
                        }); },
                    )
                  ],
                )
            ),  
            ],
          )
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  void handleNewDate(date) {
    print("handleNewDate ${date}");
  }

  Widget _buildList() {
    return ListView.builder(
        itemCount: vehiculos.length,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new Container(
              padding: new EdgeInsets.all(10.0),
              child: new Column(
                children: <Widget>[
                  Text(vehiculos[index].placa,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        fontSize: 22.0,
                      )
                  ),
                  Text("Mensualidad vence: "+vehiculos[index].FechaDeVencimiento,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        fontSize: 14.0,
                      )
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: new CheckboxListTile(
                            value: vehiculos[index].Manana,
                            activeColor: Colors.amberAccent,
                            title: new Text("Dia"),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool val) {
                              ItemChange(val, index);
                            }
                        ),
                      ),

                      Expanded(
                        child: new CheckboxListTile(
                            value: vehiculos[index].Tarde,
                            activeColor: Colors.black87,
                            title: new Text("Tarde"),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool val) {
                              ItemChangeCheckBox2(val, index);
                            }
                        )
                        ,
                      )
                    ],
                  ),

                ],
              ),
            ),
          );
        }
    );
  }
  void ItemChange(bool val,int index){
    setState(() {
      String estado="0";
      if(val){
        estado="1";
      }
      vehiculos[index].MananaJson=estado;
      vehiculos[index].Manana=val;
    });
  }
  void ItemChangeCheckBox2(bool val,int index){
    setState(() {
      String estado="0";
      if(val){
        estado="1";
      }
      vehiculos[index].TardeJson=estado;
      vehiculos[index].Tarde=val;
    });
  }
  getCarsFromJson() async{
    setState(() {
      isLoading = true;
    });
    final String membershipKey = 'jsoncarsm';
    SharedPreferences sp = await SharedPreferences.getInstance();
    json
        .decode(sp.getString(membershipKey))
        .forEach((map) => vehiculos.add(new VehiculoMensualidad.fromJson(map)));
    setState(() {
      isLoading = false;
    });
  }

  _fetchData(String param) async {
    if(param.length>0){
      setState(() {
        isLoading = true;
      });
      String direccion="http://ruedadifusion.com/JP/Parqueadero/MonthlyVehicles.php?fecha="+param;
      print("direccion = "+direccion);
      final response =
      await http.get(direccion);
      if (response.statusCode == 200) {
        json_string=response.body;
        vehiculos = (json.decode(response.body) as List)
            .map((data) => new VehiculoMensualidad.fromJson(data))
            .toList();
        setState(() {
          isLoading = false;
          for(var i=0; i<vehiculos.length;i++){
            vehiculos[i].fillBoleans();
          }
        });
      } else {
        throw Exception('Failed to load photos');
      }

    }else{
      setState(() {
        isLoading = true;
      });
      final response =
      await http.get("http://ruedadifusion.com/JP/Parqueadero/MonthlyVehicles.php");
      if (response.statusCode == 200) {
        json_string=response.body;
        print("json: "+json_string);
        vehiculos = (json.decode(response.body) as List)
            .map((data) => new VehiculoMensualidad.fromJson(data))
            .toList();
        setState(() {
          isLoading = false;
          for(var i=0; i<vehiculos.length;i++){
            print("se lleno booleana");
            vehiculos[i].fillBoleans();
          }
        });
      } else {
        throw Exception('Failed to load photos');
      }
    }

  }
  void saveDataInPreferences() async{
    final String membershipKey = 'jsoncarsm'; // maybe use your domain + appname
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(membershipKey, json.encode(vehiculos));
  }
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

}