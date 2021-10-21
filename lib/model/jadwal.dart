import 'package:json_annotation/json_annotation.dart';
part 'jadwal.g.dart';

@JsonSerializable()
class Jadwal {
  final String jam;
  @JsonKey(name: "id")
  final String kodeJadwal;
  final String aktif;

  Jadwal({
    required this.jam,
    required this.kodeJadwal,
    required this.aktif});

  factory Jadwal.fromJson(Map<String,dynamic> data) => _$JadwalFromJson(data);
  Map<String,dynamic> toJson() => _$JadwalToJson(this);

}