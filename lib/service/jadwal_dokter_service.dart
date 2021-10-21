import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sobatku/helper/url_helper.dart';
import 'package:sobatku/model/jadwal_dokter.dart';

class JadwalService {
  var baseUrl = URL.devAddress;

  Future<List<JadwalDokter>> getJadwalDokter(String idSpesialisasi, String hari) async {
    final response = await http.get(
      Uri.parse(baseUrl + "jadwal/$idSpesialisasi/$hari"),
      headers: URL.createHeader(),);
    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<JadwalDokter>.from(data['data'].map((jadwal) => JadwalDokter.fromJson(jadwal)));
    } else {
      throw Exception("Failed");
    }
  }

  Future<List<JadwalDokter>> getJadwalDokterById(String kodeDokter) async {
    final response = await http.get(
        Uri.parse(baseUrl + "jadwal/$kodeDokter"),
        headers: URL.createHeader()
    );
    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<JadwalDokter>.from(data['data'].map((jadwal) => JadwalDokter.fromJson(jadwal)));
    } else {
      throw Exception("Failed");
    }
  }
}