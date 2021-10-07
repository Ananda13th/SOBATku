// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dokter_favorit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DokterFavorit _$DokterFavoritFromJson(Map<String, dynamic> json) {
  return DokterFavorit(
    idDokter: json['id_dokter'] as int,
    idUser: json['id_user'] as int,
  );
}

Map<String, dynamic> _$DokterFavoritToJson(DokterFavorit instance) =>
    <String, dynamic>{
      'id_dokter': instance.idDokter,
      'id_user': instance.idUser,
    };
