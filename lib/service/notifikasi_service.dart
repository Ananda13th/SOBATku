import 'dart:convert';

import 'package:sobatku/helper/url_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sobatku/model/notifikasi.dart';

class NotifikasiService {
  var baseUrl = URL.urlAddress;

  Future<List<Notifikasi>> getNotifList(String idUser) async {
    final response = await http.get(
      Uri.parse(baseUrl + "notif/$idUser"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Notifikasi>.from(data['data'].map((notif) => Notifikasi.fromJson(notif)));
    } else {
      throw Exception("Failed");
    }
  }
}