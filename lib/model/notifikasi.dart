import 'package:json_annotation/json_annotation.dart';
part 'notifikasi.g.dart';

@JsonSerializable()
class Notifikasi {
  @JsonKey(name: "id_user")
  final int idUSer;
  @JsonKey(name: "id_notifikasi")
  final int idNotifikasi;
  final String judul;
  final String berita;

  Notifikasi({
    required this.idNotifikasi,
    required this.idUSer,
    required this.judul,
    required this.berita
  });

  factory Notifikasi.fromJson(Map<String,dynamic> data) => _$NotifikasiFromJson(data);
  Map<String,dynamic> toJson() => _$NotifikasiToJson(this);

}