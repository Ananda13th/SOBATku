// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dokter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dokter _$DokterFromJson(Map<String, dynamic> json) {
  return Dokter(
    idDokter: json['id_dokter'] as int,
    foto: json['foto'] as String,
    namaDokter: json['nama_dokter'] as String,
    kodeDokter: json['kode_dokter'] as String,
    kodeSpesialisasi: json['kode_spesialisasi'] as String,
    spesialisasi: json['nama_spesialisasi'] as String,
  );
}

Map<String, dynamic> _$DokterToJson(Dokter instance) => <String, dynamic>{
      'id_dokter': instance.idDokter,
      'foto': instance.foto,
      'nama_dokter': instance.namaDokter,
      'nama_spesialisasi': instance.spesialisasi,
      'kode_dokter': instance.kodeDokter,
      'kode_spesialisasi': instance.kodeSpesialisasi,
    };
