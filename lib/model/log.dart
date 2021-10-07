import 'package:json_annotation/json_annotation.dart';
part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(name: "nomor_rm")
  final String nomorRm;
  @JsonKey(name: "idUser")
  final int idUser;
  final String keterangan;
  final String perubahan;

  Log({
    required this.nomorRm,
    required this.idUser,
    required this.keterangan,
    required this.perubahan});

  factory Log.fromJson(Map<String,dynamic> data) => _$LogFromJson(data);
  Map<String,dynamic> toJson() => _$LogToJson(this);

}