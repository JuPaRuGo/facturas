import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Vehiculo {
  final String placa;
  final String horaEntrada;
  final String horaSalida;

  Vehiculo({this.placa, this.horaEntrada, this.horaSalida});

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      placa: json['placa'] as String,
      horaEntrada: json['hora1'] as String,
      horaSalida: json['hora2'] as String,
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Isolate Demo';

    return MaterialApp(
      title: appTitle,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({ Key key }) : super(key: key);
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Vehiculo> vehiculos = List();

  var isLoading = false;

  _fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response =
    await http.get("http://ruedadifusion.com/JP/Parqueadero/Vehicles.php");
    if (response.statusCode == 200) {
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

  List VehiculosFiltrados = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text( 'Parqueadero' );

  _MainPageState() {
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

  @override
  void initState() {
    this._fetchData();
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
      for (int i = 0; i < VehiculosFiltrados.length; i++) {
        if (VehiculosFiltrados[i].placa.toString().toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(VehiculosFiltrados[i]);
        }
      }
      VehiculosFiltrados = tempList;
    }
    return ListView.builder(
      itemCount: vehiculos == null ? 0 : VehiculosFiltrados.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(VehiculosFiltrados[index].placa.toString()),
          onTap: () => print(VehiculosFiltrados[index].placa.toString()+"  Click"),
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
class SecondScreenState extends State<SecondScreen> {

  final controller = TextEditingController();
  List<Vehiculo> vehiculos = [];
  String _placaAlfabetica = "";
  String _placaNumerica = "";

  @override
  void initState() {
    super.initState();

    controller.addListener(listen);
  }

  void listen() {
    print("Second text field: ${controller.text}");
  }

  @override
  Widget build(BuildContext context) {
    BuildContext contexto = context;
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
              },
              color: Theme
                  .of(contexto)
                  .accentColor,
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

  void _AddNewVehicle() async {

  }
}