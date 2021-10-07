import 'package:json_annotation/json_annotation.dart';
part 'dokter.g.dart';

@JsonSerializable()
class Dokter {
  @JsonKey(name: "id_dokter")
  final int idDokter;
  @JsonKey(name: "nama_dokter")
  final String namaDokter;
  @JsonKey(name: "nama_spesialisasi")
  final String spesialisasi;
  @JsonKey(name: "kode_dokter")
  final String kodeDokter;
  @JsonKey(name: "id_spesialisasi")
  final int idSpesialisasi;

  Dokter({
    required this.idDokter,
    required this.namaDokter,
    required this.kodeDokter,
    required this.idSpesialisasi,
    required this.spesialisasi});

  factory Dokter.fromJson(Map<String,dynamic> data) => _$DokterFromJson(data);
  Map<String,dynamic> toJson() => _$DokterToJson(this);

}