import 'package:json_annotation/json_annotation.dart';
part 'transaksi_req.g.dart';

@JsonSerializable()
class TransaksiReq{
  @JsonKey(name: "kodejadwal")
  final String kodeJadwal;
  @JsonKey(name: "str")
  final String kodeDokter;
  @JsonKey(name: "rm")
  final String nomorRm;
  final String tipe;

  TransaksiReq({
    required this.kodeJadwal,
    required this.kodeDokter,
    required this.nomorRm,
    required this.tipe});

  factory TransaksiReq.fromJson(Map<String,dynamic> data) => _$TransaksiReqFromJson(data);
  Map<String,dynamic> toJson() => _$TransaksiReqToJson(this);

}