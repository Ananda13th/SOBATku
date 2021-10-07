// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pairing _$PairingFromJson(Map<String, dynamic> json) {
  return Pairing(
    idPairing: json['id_pairing'] as int?,
    idUser: json['id_user'] as String,
    nomorRm: json['nomor_rm'] as String,
  );
}

Map<String, dynamic> _$PairingToJson(Pairing instance) => <String, dynamic>{
      'id_pairing': instance.idPairing,
      'id_user': instance.idUser,
      'nomor_rm': instance.nomorRm,
    };
