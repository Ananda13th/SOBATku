import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'pasien.g.dart';

@JsonSerializable()
class Pasien {
  @JsonKey(name: "nama_pasien")
  final String namaPasien;
  @JsonKey(name: "nomor_bpjs")
  final String nomorBpjs;
  @JsonKey(name: "nomor_ktp")
  final String nomorKtp;
  @JsonKey(name: "nomor_rm")
  final String nomorRm;
  @JsonKey(name: "jenis_kelamin")
  final String jenisKelamin;
  Pasien({
    required this.namaPasien,
    required this.nomorBpjs,
    required this.nomorKtp,
    required this.nomorRm,
    required this.jenisKelamin
  });

  factory Pasien.fromJson(Map<String,dynamic> data) => _$PasienFromJson(data);
  Map<String,dynamic> toJson() => _$PasienToJson(this);

}