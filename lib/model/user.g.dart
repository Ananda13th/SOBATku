// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    password: json['password'] as String,
    namaUser: json['nama_user'] as String,
    nomorHp: json['nomor_hp'] as String,
    email: json['email'] as String,
  )..idUser = json['id_user'];
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id_user': instance.idUser,
      'password': instance.password,
      'nama_user': instance.namaUser,
      'nomor_hp': instance.nomorHp,
      'email': instance.email,
    };
