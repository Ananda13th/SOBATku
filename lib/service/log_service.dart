import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sobatku/helper/url_helper.dart';
import 'package:sobatku/model/log.dart';

class LogService {
  var baseUrl = URL.devAddress;

  Future<String> createLog(Log newLog) async {
    final response = await http.post(
        Uri.parse(baseUrl + "log"),
        headers: URL.createHeader(),
        body: newLog
    );
    if(response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed");
    }
  }
}