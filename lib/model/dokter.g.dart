// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dokter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dokter _$DokterFromJson(Map<String, dynamic> json) {
  return Dokter(
    idDokter: json['id_dokter'] as int,
    namaDokter: json['nama_dokter'] as String,
    kodeDokter: json['kode_dokter'] as String,
    idSpesialisasi: json['id_spesialisasi'] as int,
    spesialisasi: json['nama_spesialisasi'] as String,
  );
}

Map<String, dynamic> _$DokterToJson(Dokter instance) => <String, dynamic>{
      'id_dokter': instance.idDokter,
      'nama_dokter': instance.namaDokter,
      'nama_spesialisasi': instance.spesialisasi,
      'kode_dokter': instance.kodeDokter,
      'id_spesialisasi': instance.idSpesialisasi,
    };
