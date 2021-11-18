import 'dart:convert';

import 'package:sobatku/helper/url_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sobatku/model/dokter.dart';

class DokterService {
  var baseUrl = URL.devAddress;

  Future<List<Dokter>> getDokter() async {
    final response = await http.get(
        Uri.parse(baseUrl + "dokter/all/1"),
        headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Dokter>.from(data['data'].map((dokter) => Dokter.fromJson(dokter)));
    } else {
      throw Exception("Failed");
    }
  }

  Future<List<Dokter>> getDokterLazy(int increment, int panjangData) async {
    final response = await http.get(
      Uri.parse(baseUrl + "dokter/all/1"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Dokter> tempList = List<Dokter>.from(data['data'].map((dokter) => Dokter.fromJson(dokter)));
      List<Dokter> editedList = List.empty(growable: true);
      for (var i = panjangData; i < panjangData + increment; i++) {
        if(i > tempList.length)
          print("Sudah Semua");
        else
         editedList.add(tempList[i]);
      }
      return editedList;
    } else {
      throw Exception("Failed");
    }
  }
}