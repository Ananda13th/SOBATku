import 'package:json_annotation/json_annotation.dart';
part 'spesialisasi.g.dart';

@JsonSerializable()
class Spesialisasi {
  @JsonKey(name: "id_spesialisasi")
  final int idSpesialisasi;
  @JsonKey(name: "kode_spesialisasi")
  final String kodeSpesialisasi;
  @JsonKey(name: "nama_spesialisasi")
  final String namaSpesialisasi;

  Spesialisasi({
    required this.idSpesialisasi,
    required this.kodeSpesialisasi,
    required this.namaSpesialisasi});

  factory Spesialisasi.fromJson(Map<String,dynamic> data) => _$SpesialisasiFromJson(data);
  Map<String,dynamic> toJson() => _$SpesialisasiToJson(this);

}