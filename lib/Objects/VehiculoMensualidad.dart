import 'package:json_annotation/json_annotation.dart';
import 'dart:async';
import 'dart:convert';

@JsonSerializable()
class VehiculoMensualidad {
  String placa;
  String horaEntrada;
  String horaSalida;
  bool Manana=false;
  bool Tarde=false;

  VehiculoMensualidad(this.placa, this.horaEntrada, this.horaSalida);

  VehiculoMensualidad.fromJson(Map<String, dynamic> json)
      : placa = json['placa'] as String,
        horaEntrada = json['hora1'] as String,
        Manana= json['manana'] as bool,
        Tarde = json['tarde'] as bool,
        horaSalida = json['hora2'] as String;

  Map<String, dynamic> toJson() =>
      {
        'placa': this.placa,
        'hora1': this.horaEntrada,
        'hora2': this.horaSalida,
        'manana': this.Manana,
        'tarde':this.Tarde,
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
