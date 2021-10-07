// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jadwal_dokter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JadwalDokter _$JadwalDokterFromJson(Map<String, dynamic> json) {
  return JadwalDokter(
    nama: json['nama'] as String,
    hari: json['hari'] as int,
    kodeDokter: json['kode_dokter'] as String,
    jadwalPraktek: (json['jadwal'] as List<dynamic>)
        .map((e) => Jadwal.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$JadwalDokterToJson(JadwalDokter instance) =>
    <String, dynamic>{
      'nama': instance.nama,
      'hari': instance.hari,
      'kode_dokter': instance.kodeDokter,
      'jadwal': instance.jadwalPraktek,
    };
