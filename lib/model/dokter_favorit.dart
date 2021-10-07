import 'package:json_annotation/json_annotation.dart';
part 'dokter_favorit.g.dart';

@JsonSerializable()
class DokterFavorit {
  @JsonKey(name: "id_dokter")
  final int idDokter;
  @JsonKey(name: "id_user")
  final int idUser;

  DokterFavorit({
    required this.idDokter,
    required this.idUser});

  factory DokterFavorit.fromJson(Map<String,dynamic> data) => _$DokterFavoritFromJson(data);
  Map<String,dynamic> toJson() => _$DokterFavoritToJson(this);

}