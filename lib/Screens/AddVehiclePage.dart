import 'dart:convert';
import 'package:facturas/Objects/VehiculoMensualidad.dart';
import 'package:facturas/Screens/Home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Objects/Vehiculo.dart';
import 'package:flutter/services.dart';

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
  DateTime selectedDate= DateTime.parse(DateFormat("yyy-MM-dd").format(DateTime.now()));
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                  flex: 5,
                  child: new Container(
                    width: 160.0,
                    height: 200,
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (text) {
                          text.toLowerCase();
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
                    height: 200,
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            labelText: 'Placas Numericas')
                    ),
                  )
              )
            ],

          ),
      ButtonTheme(
          minWidth: 300.0,
          height: 100.0,
          child:
          new RaisedButton(
            child: const Text('Guardar'),
            color: Colors.blueAccent,
            textColor: Colors.white,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
              this._AddNewVehicle();

            },
          ),
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
        //YYYY-MM-DD HH:MI:SS
        if(widget.esParticular==true){
          var now=DateFormat("yyy-MM-dd kk:mm:ss").format(DateTime.now());
          Vehiculo _vehiculo= new Vehiculo(_placaAlfabetica+"-"+_placaNumerica, now.toString(), "");
          vehiculos.add(_vehiculo);
          _PersistParticularVehicles();
        }else{
          _selectDate(context);

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
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        var now=DateFormat("yyy-MM-dd").format(selectedDate);
        VehiculoMensualidad _car=new VehiculoMensualidad(_placaAlfabetica+"-"+_placaNumerica, now.toString(), selectedDate.add(new Duration(days: 31)).toString());
        vehiculosMensuales.add(_car);
        _PersistMonthlyVehicles();
        this._launchFirstScreen();
      });
  }

}
