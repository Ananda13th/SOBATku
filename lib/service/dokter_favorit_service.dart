import 'dart:convert';

import 'package:sobatku/helper/url_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sobatku/model/dokter_favorit.dart';

class DokterFavoritService {
  var baseUrl = URL.urlAddress;

  Future<List<DokterFavorit>> getDokterfavorit(String idUser) async {
    final response = await http.get(
      Uri.parse(baseUrl + "favorit/$idUser"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<DokterFavorit>.from(data['data'].map((dokter) => DokterFavorit.fromJson(dokter)));
    } else {
      return List<DokterFavorit>.empty(growable: true);
    }
  }

  Future<String> addDokterFavorit(DokterFavorit dokterFavorit) async {
    final response = await http.post(
      Uri.parse(baseUrl + "favorit/"),
      headers: URL.createHeader(),
      body: json.encode(dokterFavorit)
    );
    if (response.statusCode == 200) {
      return "Berhasil Menambah Dokter Favorit";
    } else {
      return "Terjadi Kesalahan";
    }
  }

  Future<String> deleteDokterFavorit(int idUser, int idDokter) async {
    final response = await http.delete(
      Uri.parse(baseUrl + "favorit/$idUser/$idDokter"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      return "Berhasil Menghapus Dokter Favorit";
    } else {
      return "Terjadi Kesalahan";
    }
  }
}