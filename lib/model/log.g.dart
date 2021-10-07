// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) {
  return Log(
    nomorRm: json['nomor_rm'] as String,
    idUser: json['idUser'] as int,
    keterangan: json['keterangan'] as String,
    perubahan: json['perubahan'] as String,
  );
}

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'nomor_rm': instance.nomorRm,
      'idUser': instance.idUser,
      'keterangan': instance.keterangan,
      'perubahan': instance.perubahan,
    };
