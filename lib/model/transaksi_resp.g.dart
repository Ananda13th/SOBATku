// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransaksiResp _$TransaksiRespFromJson(Map<String, dynamic> json) {
  return TransaksiResp(
    status: json['status'] as String,
    tanggal: json['tanggal'] as String,
    namaDokter: json['dokter'] as String,
    spesialis: json['spesialis'] as String,
    nomorRm: json['nomor_rm'] as String,
    tipePembayaran: json['tipe_pembayaran'] as String,
    notifikasi: json['notifikasi'] as String,
    waktu: json['waktu'] as String,
    antrian: json['antrian'] as String,
    kodeJadwal: json['kode_jadwal'] as String,
    namaPasien: json['nama_pasien'] as String,
  );
}

Map<String, dynamic> _$TransaksiRespToJson(TransaksiResp instance) =>
    <String, dynamic>{
      'status': instance.status,
      'dokter': instance.namaDokter,
      'nomor_rm': instance.nomorRm,
      'spesialis': instance.spesialis,
      'antrian': instance.antrian,
      'tipe_pembayaran': instance.tipePembayaran,
      'tanggal': instance.tanggal,
      'waktu': instance.waktu,
      'notifikasi': instance.notifikasi,
      'kode_jadwal': instance.kodeJadwal,
      'nama_pasien': instance.namaPasien,
    };
