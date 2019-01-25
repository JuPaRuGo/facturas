import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter_calendar/flutter_calendar.dart';

@JsonSerializable()
class Vehiculo {
  String placa;
  String horaEntrada;
  String horaSalida;

  Vehiculo(this.placa, this.horaEntrada, this.horaSalida);

  /**factory Vehiculo.fromJson(Map<String, dynamic> json) {
      return Vehiculo(
      placa: json['placa'] as String,
      horaEntrada: json['hora1'] as String,
      horaSalida: json['hora2'] as String,
      );
      }*/
  Vehiculo.fromJson(Map<String, dynamic> json)
      : placa = json['placa'] as String,
        horaEntrada = json['hora1'] as String,
        horaSalida = json['hora2'] as String;

  Map<String, dynamic> toJson() =>
      {
        'placa': this.placa,
        'hora1': this.horaEntrada,
        'hora2': this.horaSalida,
      };

  set _placa(String pl) {
    this.placa=pl;
  }
  set _horaEntrada(String h1) {
    this.placa=h1;
  }
  set _horaSalida(String h2) {
    this.placa=h2;
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Parqueadero';

    return MaterialApp(
      title: appTitle,
      home: Home(),
    );
  }
}

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
    );
  }
  final List<Widget> _children = [
    MainPage(),
    Mensualities(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

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
        child: _buildList()
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
          subtitle: Text(VehiculosFiltrados[index].horaEntrada.toString()),
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
    Navigator.push(context, MaterialPageRoute(builder: (context)=>AddVehiclePage()));
  }

}
class AddVehiclePage extends StatefulWidget{
  final List names;
  AddVehiclePage({ Key key, this.names }) : super(key: key);
  @override
  AddVehiclePageState createState()=> AddVehiclePageState();

}
class AddVehiclePageState extends State<AddVehiclePage> {

  final controller = TextEditingController();
  List<Vehiculo> vehiculos = [];
  String _placaAlfabetica = "";
  String _placaNumerica = "";

  @override
  void initState() {
    super.initState();
    this.getCarsFromJson();
    controller.addListener(listen);
  }
  void getCarsFromJson() async{
    final String membershipKey = 'jsoncars';
    SharedPreferences sp = await SharedPreferences.getInstance();
    json
        .decode(sp.getString(membershipKey))
        .forEach((map) => vehiculos.add(new Vehiculo.fromJson(map)));
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
  void _launchFirstScreen(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
  }
  void _AddNewVehicle() async {
    var now = new DateTime.now();
    if(_placaAlfabetica.length==3){

      if(_placaNumerica.length>2 &&_placaNumerica.length<4){
        Vehiculo _vehiculo= new Vehiculo(_placaAlfabetica+"-"+_placaNumerica, now.toString(), "");
        vehiculos.add(_vehiculo);
        _PersistVehicles();
      }
    }

  }
  void _PersistVehicles() async{
    final String membershipKey = 'jsoncars'; // maybe use your domain + appname
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(membershipKey, json.encode(vehiculos));
  }
}

 class Mensualities extends StatefulWidget{

   Mensualities({Key key}): super(key: key);
   @override
   _StateMensualities createState()=> _StateMensualities();

 }
 class _StateMensualities extends State<Mensualities> {
  List<Vehiculo> carros;
   @override
   void initState() {
     super.initState();
     carros=new List<Vehiculo>();
     carros.add(new Vehiculo("SAM", "", ""));
   }
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("Mensualidades"),
       ),
       body: Container(
           child: _buildList()
       ),
       resizeToAvoidBottomPadding: false,
     );
   }

   void handleNewDate(date) {
     print("handleNewDate ${date}");
   }

  Widget _buildList() {
    return ListView.builder(
      itemCount: carros.length,
      itemBuilder: (BuildContext context, int index) {
        bool _checkboxDay=false;
        bool _checkboxAfternoon=false;
        return Column(
            children: <Widget>[
              Divider(height: 5.0),
              ListTile(
                title: Text("HOLA"),
                leading: Column(
                  children: <Widget>[
                    Checkbox(
                      value: _checkboxDay,
                      onChanged: (bool value) {
                        _checkboxDay=value;
                      },
                    ),
                  ],
                ),
              )
            ]
        );
      },
    );
  }

 }
