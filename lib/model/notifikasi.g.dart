// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifikasi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notifikasi _$NotifikasiFromJson(Map<String, dynamic> json) {
  return Notifikasi(
    idNotifikasi: json['id_notifikasi'] as int,
    idUSer: json['id_user'] as int,
    judul: json['judul'] as String,
    berita: json['berita'] as String,
  );
}

Map<String, dynamic> _$NotifikasiToJson(Notifikasi instance) =>
    <String, dynamic>{
      'id_user': instance.idUSer,
      'id_notifikasi': instance.idNotifikasi,
      'judul': instance.judul,
      'berita': instance.berita,
    };
