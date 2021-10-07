import 'package:json_annotation/json_annotation.dart';
part 'transaksi_resp.g.dart';

@JsonSerializable()
class TransaksiResp{
  final String status;
  @JsonKey(name: "dokter")
  final String namaDokter;
  @JsonKey(name: "nomor_rm")
  final String nomorRm;
  final String spesialis;
  final String antrian;
  @JsonKey(name: "tipe_pembayaran")
  final String tipePembayaran;
  String tanggal;
  final String waktu;
  final String notifikasi;
  @JsonKey(name: "kode_jadwal")
  final String kodeJadwal;
  @JsonKey(name: "nama_pasien")
  final String namaPasien;

  TransaksiResp({
    required this.status,
    required this.tanggal,
    required this.namaDokter,
    required this.spesialis,
    required this.nomorRm,
    required this.tipePembayaran,
    required this.notifikasi,
    required this.waktu,
    required this.antrian,
    required this.kodeJadwal,
    required this.namaPasien});

  factory TransaksiResp.fromJson(Map<String,dynamic> data) => _$TransaksiRespFromJson(data);
  Map<String,dynamic> toJson() => _$TransaksiRespToJson(this);

}