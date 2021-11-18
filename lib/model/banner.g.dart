// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) {
  return BannerModel(
    url: json['url'] as String,
    urlDetailBanner: json['url_detail_banner'] as String?,
    urlSumberBerita: json['url_sumber'] as String?,
    deskripsi: json['deskripsi'] as String,
    keterangan: json['keterangan'] as String,
  );
}

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'url_detail_banner': instance.urlDetailBanner,
      'url_sumber': instance.urlSumberBerita,
      'deskripsi': instance.deskripsi,
      'keterangan': instance.keterangan,
    };
