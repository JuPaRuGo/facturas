import 'package:json_annotation/json_annotation.dart';
import 'dart:async';
import 'dart:convert';

@JsonSerializable()
class VehiculoMensualidad {
  String placa;
  String idVehiculo;
  String FechaEntrada;
  String FechaDeVencimiento;
  String MananaJson="0";
  String TardeJson="0";
  bool Manana=false;
  bool Tarde=false;

  VehiculoMensualidad(this.placa, this.FechaEntrada, this.FechaDeVencimiento);

  VehiculoMensualidad.fromJson(Map<String, dynamic> json)
      : placa = json['placa'] as String,
        idVehiculo= json['id'] as String,
        FechaEntrada = json['fecha1'] as String,
        FechaDeVencimiento = json['fecha2'] as String,
        MananaJson= json['manana'] as String,
        TardeJson = json['tarde'] as String;

  Map<String, dynamic> toJson() =>
      {
        'placa': this.placa,
        'id': this.idVehiculo,
        'fecha1': this.FechaEntrada,
        'fecha2': this.FechaDeVencimiento,
        'manana': this.MananaJson,
        'tarde':this.TardeJson,
      };

    void fillBoleans(){
      if(MananaJson=="1"){
        Manana=true;
      }
      if(TardeJson=="1"){
        Tarde=true;
      }

    }

}
