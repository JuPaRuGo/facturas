import 'dart:convert';
import 'package:facturas/Objects/Choice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter_calendar/flutter_calendar.dart';

import '../Objects/VehiculoMensualidad.dart';

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Traer', icon: Icons.get_app),
  const Choice(title: 'Subir Mensualidades', icon: Icons.file_upload),
  const Choice(title: 'Subir Registro', icon: Icons.cloud_upload),
  const Choice(title: 'Seleccionar Fecha', icon: Icons.calendar_today),
];

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
  int lastIndex;
  String dateNow=DateFormat("yyy-MM-dd").format(DateTime.now()).toString();

  Choice _selectedChoice = choices[0]; // The app's "state".
  @override
  void initState() {
    super.initState();
    vehiculos=new List<VehiculoMensualidad>();
    this.getLastIndex();
    this.getCarsFromJson(); //primero se obtienen del json
    if(vehiculos==null){//si no se encontro nada del json se busca del internet
      print("se encontro nulo en mensualidades");
      vehiculos = List<VehiculoMensualidad>();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensualidades"),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),

        ],
      ),
      body: Container(
          child: Column(
            children: <Widget>[
            new Expanded(
              flex: 10,
              child: _buildList(),
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
                              print("cambio c1");
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
                              print("cambio c2");
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
      this._PersistMonthlyVehicles();
  }
  void ItemChangeCheckBox2(bool val,int index){
      setState(() {
        String estado="0";
        if(val){
          estado="1";
        }
        vehiculos[index].TardeJson=estado;
        print("Se obtuvo: "+vehiculos[index].TardeJson);
        vehiculos[index].Tarde=val;
      });
      this._PersistMonthlyVehicles();
  }
  Future getCarsFromJson() async{
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
    for(var i=0;i<vehiculos.length;i++){
      vehiculos[i].fillBoleans();
    }
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
            vehiculos[i].fillBoleans();
          }
        });
      } else {
        throw Exception('Failed to load photos');
      }
    }
    this._PersistMonthlyVehicles();
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
        this._fetchData(DateFormat("yyy-MM-dd").format(selectedDate).toString());
      });
  }


  void SubirVehiculos() async{
      print("Subiendo");

      for(var i=0;i<vehiculos.length;i++){//no funciono lo del last
        VehiculoMensualidad v=vehiculos[i];
        var client = new http.Client();
        String url="http://ruedadifusion.com/JP/Parqueadero/AddMonthlyVehicle.php";
        client.post(
            url,
            body: {"entrada": v.FechaEntrada, "placa": v.placa})
            .then((response) => print(response.body))
            .whenComplete(client.close);
      }
  }
  void SubirRegistro() async{
    print("subiendo reg");
    for(var i=0;i<vehiculos.length;i++){//no funciono lo del last
      VehiculoMensualidad v=vehiculos[i];
      var client = new http.Client();
      print("fecha:"+ dateNow+" id: "+v.idVehiculo+" m:"+v.MananaJson+" t:"+v.TardeJson);

      String url="http://ruedadifusion.com/JP/Parqueadero/AddToRegister.php";
      client.post(
          url,
          body: {"fecha": dateNow,"id":v.idVehiculo,"m":v.MananaJson,"t":v.TardeJson})
          .then((response) => print(response.body))
          .whenComplete(client.close);
    }
  }
  void _PersistMonthlyVehicles() async{
      print("Guardando");
      final String membershipKey = 'jsoncarsm'; // maybe use your domain + appname
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setString(membershipKey, json.encode(vehiculos));
  }
  Future getLastIndex() async{
    final response =
        await http.get('http://ruedadifusion.com/JP/Parqueadero/GetLastIndex.php');
    if (response.statusCode == 200) {
      print("rta "+response.body);
      setState(() {
        lastIndex=int.parse(response.body);

      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Traeras los registros del Internet"),
          content: new Text("Esto borrara los archivos de ahora"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Aceptar"),
              onPressed: () {
                print('Aceptado');
                _fetchData("");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    this._PersistMonthlyVehicles();
  }

  @override
  void reassemble() {
    super.reassemble();
  }
  void _select(Choice choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    print("se selecciono el "+choice.title);
    if(choice==choices[0]){//traer

      this._showDialog();
    }else{
      if(choice==choices[1]){//subir
        SubirVehiculos();

      }else{
          if(choice==choices[2]){//subir
            SubirRegistro();

          }else{// es el ultimo seleccionar fecha
            setState(() {
              _selectDate(context);
              print("fecha"+DateFormat("yyy-MM-dd").format(selectedDate).toString());
              this._fetchData(DateFormat("yyy-MM-dd").format(selectedDate).toString());
            });

          }
      }

    }
    setState(() {
      _selectedChoice = choice;
    });
  }

}

