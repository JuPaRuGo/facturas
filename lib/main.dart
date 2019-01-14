import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Vehiculo{
    final String Placa;
    final DateTime horaEntrada;
    DateTime horaSalida;

    Vehiculo({this.Placa, this.horaEntrada, this.horaSalida});

    factory Vehiculo.fromJson(Map<String, dynamic> json) {
      return Vehiculo(
        Placa: json['userId'],
        horaEntrada: json['id'],
        horaSalida: json['title'],

      );
    }


}

void main() => runApp(new MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'App Parqueadero',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
   MainPage({ Key key }) : super(key: key);
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // final formKey = new GlobalKey<FormState>();
  // final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _filter = new TextEditingController();

  String _searchText = "";
  List names = new List();
  List filteredNames = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text( 'Parqueadero' );

  _MainPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    this._getNames();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(
        child: _buildList(),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.pop(context);
              },
            ),
          ],
        ),

      ),
      floatingActionButton: FloatingActionButton(
      onPressed: _launchSecondScreen,
      tooltip: 'Increment',
      child: Icon(Icons.add),
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
      List tempList = new List();
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i].toString().toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(filteredNames[index].toString()),
          onTap: () => print(filteredNames[index].toString()+"  Click"),
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
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  void _getNames() async {
    names.add('CCK-201');
    names.add('FMG-142');
    names.add('FGA-11B');
    names.add('KKX-299');
    names.add('PYJ-223');
    names.add('HYP-654');
    names.add('KKY-100');
    names.add('AVA-10B');
  }

  void _launchSecondScreen(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SecondScreen()));
  }


}
class SecondScreen extends StatefulWidget{
  final List names;
  SecondScreen({ Key key, this.names }) : super(key: key);
    @override
    SecondScreenState createState()=> SecondScreenState();

}
class SecondScreenState extends State<SecondScreen>{
  final controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    controller.addListener(listen);
  }
  void listen(){
    print("Second text field: ${controller.text}");

  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Vehiculo'),
      ),

      body: Column(
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
                      },
                      decoration: const InputDecoration(labelText: 'Placas Alfabeticas')
                  ),
                )
              ),
              new Expanded(
                flex: 5,
                child:  new Container(
                  width: 160.0,
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Placas Numericas')
                  ),
                )
              )
            ],

          ),

          RaisedButton(
              onPressed: _AddNewVehicle,
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.all(1.0),
            child:
            Center(child: Text('Guardar'),
            )

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
  void _AddNewVehicle(){
    var route= new MaterialPageRoute(
        builder: (BuildContext context)=> new MainPage(),
    );
  }
}


