import 'package:json_annotation/json_annotation.dart';
import 'package:sobatku/model/jadwal.dart';
part 'jadwal_dokter.g.dart';

@JsonSerializable()
class JadwalDokter {
  final String nama;
  final int hari;
  @JsonKey(name: "kode_dokter")
  final String kodeDokter;
  @JsonKey(name: "jadwal")
  final List<Jadwal> jadwalPraktek;
  final String aktif;

  JadwalDokter({
    required this.nama,
    required this.hari,
    required this.kodeDokter,
    required this.jadwalPraktek,
    required this.aktif});

  factory JadwalDokter.fromJson(Map<String,dynamic> data) => _$JadwalDokterFromJson(data);
  Map<String,dynamic> toJson() => _$JadwalDokterToJson(this);

}