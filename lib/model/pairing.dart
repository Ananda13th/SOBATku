import 'package:json_annotation/json_annotation.dart';
part 'pairing.g.dart';

@JsonSerializable()
class Pairing {
  @JsonKey(name: "id_pairing")
  int? idPairing;
  @JsonKey(name: "id_user")
  final String idUser;
  @JsonKey(name: "nomor_rm")
  final String nomorRm;

  Pairing({
    required this.idPairing,
    required this.idUser,
    required this.nomorRm});

  factory Pairing.fromJson(Map<String,dynamic> data) => _$PairingFromJson(data);
  Map<String,dynamic> toJson() => _$PairingToJson(this);

}