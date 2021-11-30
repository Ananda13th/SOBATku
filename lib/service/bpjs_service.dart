import 'dart:convert';

import 'package:sobatku/helper/url_helper.dart';
import 'package:http/http.dart' as http;

class BpjsService {
  var baseUrl = URL.urlAddress;

  Future<String> cekAtivasi(String noBpjs) async {
    final response = await http.get(
      Uri.parse(baseUrl + "bpjs/$noBpjs"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if(data['error_code'] == "200" && data['data'].toString().toLowerCase() == "aktif")
        return "aktif";
      else
        return data['message'].toString();
    } else {
      throw Exception("Failed");
    }
  }

  Future<String> cekRujukan(String noBpjs) async {
    final response = await http.get(
      Uri.parse(baseUrl + "bpjs/rujukan/$noBpjs"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      if(data['error_code'] == "200")
        return "aktif";
      else
        return data['message'];
    } else {
      throw Exception("Failed");
    }
  }
}