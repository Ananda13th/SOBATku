// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pasien.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pasien _$PasienFromJson(Map<String, dynamic> json) {
  return Pasien(
    namaPasien: json['nama_pasien'] as String,
    nomorBpjs: json['nomor_bpjs'] as String,
    nomorKtp: json['nomor_ktp'] as String,
    nomorRm: json['nomor_rm'] as String,
  );
}

Map<String, dynamic> _$PasienToJson(Pasien instance) => <String, dynamic>{
      'nama_pasien': instance.namaPasien,
      'nomor_bpjs': instance.nomorBpjs,
      'nomor_ktp': instance.nomorKtp,
      'nomor_rm': instance.nomorRm,
    };
