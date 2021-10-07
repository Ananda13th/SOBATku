// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spesialisasi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Spesialisasi _$SpesialisasiFromJson(Map<String, dynamic> json) {
  return Spesialisasi(
    idSpesialisasi: json['id_spesialisasi'] as int,
    kodeSpesialisasi: json['kode_spesialisasi'] as String,
    namaSpesialisasi: json['nama_spesialisasi'] as String,
  );
}

Map<String, dynamic> _$SpesialisasiToJson(Spesialisasi instance) =>
    <String, dynamic>{
      'id_spesialisasi': instance.idSpesialisasi,
      'kode_spesialisasi': instance.kodeSpesialisasi,
      'nama_spesialisasi': instance.namaSpesialisasi,
    };
