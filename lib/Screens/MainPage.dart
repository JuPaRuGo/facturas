import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:intl/intl.dart';

import '../Objects/Vehiculo.dart';
import 'AddVehiclePage.dart';

class MainPage extends StatefulWidget {
  MainPage({ Key key }) : super(key: key);
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {

  List<Vehiculo> vehiculos;
  var isLoading = false;
  String json_string;
  getCarsFromJson() async{
    setState(() {
      isLoading = true;
    });
    final String membershipKey = 'jsoncars';
    SharedPreferences sp = await SharedPreferences.getInstance();
    json
        .decode(sp.getString(membershipKey))
        .forEach((map) => vehiculos.add(new Vehiculo.fromJson(map)));
    setState(() {
      isLoading = false;
    });
  }

  _fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response =
    await http.get("http://ruedadifusion.com/JP/Parqueadero/Vehicles.php");
    if (response.statusCode == 200) {
      json_string=response.body;
      vehiculos = (json.decode(response.body) as List)
          .map((data) => new Vehiculo.fromJson(data))
          .toList();
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  // final formKey = new GlobalKey<FormState>();
  // final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<Vehiculo> VehiculosFiltrados;
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text( 'Parqueadero' );

  _MainPageState() {
    VehiculosFiltrados=vehiculos;
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          VehiculosFiltrados = vehiculos;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  void saveDataInPreferences() async{
    final String membershipKey = 'jsoncars'; // maybe use your domain + appname
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(membershipKey, json.encode(vehiculos));
  }
  @override
  initState() {
    super.initState();
    //this._fetchData();
    this.getCarsFromJson();
    vehiculos = List<Vehiculo>();
    VehiculosFiltrados = new List<Vehiculo>();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (_buildBar(context)),
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

                    ],
                  )
              ),
            ],
          )
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,

      ),
    );
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List<Vehiculo> tempList = new List<Vehiculo>();
      for (int i = 0; i < VehiculosFiltrados.length; i++) {
        if (VehiculosFiltrados[i].placa.toString().toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(VehiculosFiltrados[i]);
        }
      }
      VehiculosFiltrados = tempList;
    }else{
      VehiculosFiltrados=vehiculos;
    }
    return ListView.builder(
      itemCount: vehiculos == null ? 0 : VehiculosFiltrados.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(VehiculosFiltrados[index].placa.toString()),
          subtitle: Text(DateFormat("HH:mm").format(DateTime.parse(VehiculosFiltrados[index].horaEntrada))),
          onTap: () => this._showDialog(VehiculosFiltrados[index]),
        );
      },
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Busca'
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text( 'Parqueadero' );
        VehiculosFiltrados = vehiculos;
        _filter.clear();
      }
    });
  }
  void _showDialog(Vehiculo v) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("El vehiculo debe pagar:  "),
          content: new Text(this.GetValueToPay(v).toString()),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Pagar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  bool DeterminarSiEsCarro(String str  ){
    if(str.length<=6){
      return false;// es moto
    }else{
      RegExp exp = new RegExp(r"([A-Z]$)");
      bool bol=exp.hasMatch(str);
      if(bol==true){
        return false;
      }else{
        return true;
      }
    }
  }

  int GetMinutes(Vehiculo v){
     DateTime Entrada=DateTime.parse(v.horaEntrada);
     DateTime Salida=DateTime.parse(v.horaSalida);
    return (Salida.difference(Entrada).inMinutes);
  }
  int GetHours(Vehiculo v){
    DateTime Entrada=DateTime.parse(v.horaEntrada);
    DateTime Salida=DateTime.parse(v.horaSalida);
    return (Salida.difference(Entrada).inMinutes);
  }

  int GetValueToPay(Vehiculo v){
    final HourValueVehicle=2300;
    final HourValueBike=1000;
    int cost;
    v.horaSalida=DateTime.now().toString();
    int minutes=GetMinutes(v);
    if(minutes%60==0){
      bool isACar=DeterminarSiEsCarro(v.placa);
      if(isACar){
        cost=HourValueVehicle*GetHours(v);
      }else{
        cost=HourValueBike*GetHours(v);
      }
    }else{
      bool isACar=DeterminarSiEsCarro(v.placa);
      if(isACar){
        cost=HourValueVehicle*GetHours(v)+HourValueVehicle;
      }else{
        cost=HourValueBike*GetHours(v)+HourValueBike;
      }
    }

    return cost;
  }
}