import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sobatku/helper/url_helper.dart';
import 'package:sobatku/model/pairing.dart';
import 'package:sobatku/model/pasien.dart';

class PasienService {
  var baseUrl = URL.devAddress;

  Future<String> createPasien(Pasien newPasien) async {
    final response = await http.post(
        Uri.parse(baseUrl + "pasien"),
        headers: URL.createHeader(),
        body: json.encode(newPasien)
    );
    if(response.statusCode == 200) {
        var message = json.decode(response.body);
        return message['message'];
    } else {
        throw Exception("Failed");
    }
  }

  Future<bool> searchPasien(String nomorRm) async {
    final response = await http.get(
      Uri.parse(baseUrl + "pasien/search/$nomorRm"),
      headers: URL.createHeader()
    );
    if(response.statusCode == 200) {
      var obj = json.decode(response.body);
      if(obj["error_code"] == 200)
        return true;
      return false;
    } else {
      return false;
    }
  }

  Future<String> createPairing(String nomorRm, String idUser) async {
    Pairing pairing = new Pairing(idPairing: null, idUser: idUser, nomorRm: nomorRm);
    final response = await http.post(
        Uri.parse(baseUrl + "pairing"),
        headers: URL.createHeader(),
        body: json.encode(pairing)
    );
    if(response.statusCode == 200) {
      var message = json.decode(response.body);
      return message['message'];
    } else {
      throw Exception("Failed");
    }
  }

  Future<String> deletePairing(String idUser, String noRm) async {
    final response = await http.delete(
        Uri.parse(baseUrl + "pairing/$idUser/$noRm"),
        headers: URL.createHeader()
    );
    if(response.statusCode == 200) {
      return "Berhasil Menghapus Pasien";
    } else {
      throw Exception("Failed");
    }
  }

  Future<List<Pasien>> getPairing(String idUser) async {
    final response = await http.get(
        Uri.parse(baseUrl + "pasien/$idUser"),
        headers: URL.createHeader()
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Pasien>.from(data['data'].map((pasien) => Pasien.fromJson(pasien)));
    } else {
      throw Exception();
    }
  }
}