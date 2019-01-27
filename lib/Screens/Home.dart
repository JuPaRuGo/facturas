import 'dart:convert';
import 'package:facturas/Screens/AddVehiclePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'MainPage.dart';
import 'MensualidadesScreen.dart';

class Home extends StatefulWidget{
  Home({ Key key }) : super(key: key);
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home>{
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.directions_car),
            title: new Text('Particulares'),

          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.calendar_today),
            title: new Text('Mensualidades'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchSecondScreen,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
  final List<Widget> _children = [
    MainPage(),
    MensualitiesScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  void _launchSecondScreen(){
    bool Flag= true;
    if(_currentIndex==1){
      Flag= false;
    }else{
      Flag= true;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>AddVehiclePage(esParticular:Flag)));
  }
}