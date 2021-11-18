// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jadwal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Jadwal _$JadwalFromJson(Map<String, dynamic> json) {
  return Jadwal(
    jam: json['jam'] as String,
    kodeJadwal: json['id'] as int,
    aktif: json['aktif'] as String,
  );
}

Map<String, dynamic> _$JadwalToJson(Jadwal instance) => <String, dynamic>{
      'jam': instance.jam,
      'id': instance.kodeJadwal,
      'aktif': instance.aktif,
    };
