import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: "id_user")
  var idUser;
  final String password;
  @JsonKey(name: "nama_user")
  final String namaUser;
  @JsonKey(name: "nomor_hp")
  final String nomorHp;
  final String email;

  User({
    required this.password,
    required this.namaUser,
    required this.nomorHp,
    required this.email});

  factory User.fromJson(Map<String,dynamic> data) => _$UserFromJson(data);
  Map<String,dynamic> toJson() => _$UserToJson(this);

}