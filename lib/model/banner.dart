import 'package:json_annotation/json_annotation.dart';
part 'banner.g.dart';

@JsonSerializable()
class BannerModel {
  final String url;
  final String deskripsi;
  final String keterangan;

  BannerModel({
    required this.url,
    required this.deskripsi,
    required this.keterangan
  });

  factory BannerModel.fromJson(Map<String,dynamic> data) => _$BannerModelFromJson(data);
  Map<String,dynamic> toJson() => _$BannerModelToJson(this);

}