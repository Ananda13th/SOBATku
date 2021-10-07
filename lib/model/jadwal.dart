import 'package:json_annotation/json_annotation.dart';
part 'jadwal.g.dart';

@JsonSerializable()
class Jadwal {
  final String jam;
  @JsonKey(name: "id")
  final String kodeJadwal;

  Jadwal({
    required this.jam,
    required this.kodeJadwal});

  factory Jadwal.fromJson(Map<String,dynamic> data) => _$JadwalFromJson(data);
  Map<String,dynamic> toJson() => _$JadwalToJson(this);

}