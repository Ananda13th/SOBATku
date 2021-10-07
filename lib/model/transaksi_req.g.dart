// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransaksiReq _$TransaksiReqFromJson(Map<String, dynamic> json) {
  return TransaksiReq(
    kodeJadwal: json['kodejadwal'] as String,
    kodeDokter: json['str'] as String,
    nomorRm: json['rm'] as String,
    tipe: json['tipe'] as String,
  );
}

Map<String, dynamic> _$TransaksiReqToJson(TransaksiReq instance) =>
    <String, dynamic>{
      'kodejadwal': instance.kodeJadwal,
      'str': instance.kodeDokter,
      'rm': instance.nomorRm,
      'tipe': instance.tipe,
    };
