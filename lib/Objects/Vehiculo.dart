import 'package:json_annotation/json_annotation.dart';
import 'dart:async';
import 'dart:convert';

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
