import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sobatku/helper/url_helper.dart';
import 'package:sobatku/model/transaksi_req.dart';
import 'package:sobatku/model/transaksi_resp.dart';

class TransaksiService {
  var baseUrl = URL.devAddress;

  Future<List<TransaksiResp>> getTransaksi(String noRm) async {
    String _finalUrl = baseUrl + "transaksi/$noRm";
    final response = await http.get
      (Uri.parse(_finalUrl),
      headers: URL.createHeader(),
    );
    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<TransaksiResp>.from(data['data'].map((response) => TransaksiResp.fromJson(response)));
    } else {
      throw Exception();
    }
  }

  Future<String> createTransaksi(TransaksiReq newTransaksi, String idUser) async {
    final response = await http.post(
        Uri.parse(baseUrl + "transaksi/$idUser"),
        headers: URL.createHeader(),
        body: json.encode(newTransaksi)
    );
    if(response.statusCode == 200) {
        var obj = json.decode(response.body);
        print(obj);
        return obj['message'];
    } else {
        throw Exception("Failed");
    }
  }
}