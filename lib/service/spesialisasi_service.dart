import 'dart:convert';

import 'package:sobatku/helper/url_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sobatku/model/spesialisasi.dart';

class SpesialisasiService {
  var baseUrl = URL.urlAddress;

  Future<List<Spesialisasi>> getSpesialisasi() async {
    final response = await http.get(
      Uri.parse(baseUrl + "spesialisasi"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Spesialisasi>.from(data['data'].map((item) => Spesialisasi.fromJson(item)));
    } else {
      throw Exception("Failed");
    }
  }
}