import 'dart:convert';

import 'package:sobatku/helper/url_helper.dart';
import 'package:http/http.dart' as http;

class CutiService {
  var baseUrl = URL.devAddress;

  Future<bool> cekCuti(String kodeJadwal) async {
    final response = await http.get(
      Uri.parse(baseUrl + "cuti/$kodeJadwal"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if(data['data'] == true)
        return true;
      return false;
    } else {
      throw Exception("Failed");
    }
  }
}