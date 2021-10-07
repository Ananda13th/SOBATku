import 'dart:convert';

import 'package:sobatku/helper/url_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sobatku/model/banner.dart';

class BannerService {
  var baseUrl = URL.devAddress;

  Future<List<BannerModel>> getBanner() async {
    final response = await http.get(
      Uri.parse(baseUrl + "banner/"),
      headers: URL.createHeader(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<BannerModel>.from(data['data'].map((item) => BannerModel.fromJson(item)));
    } else {
      throw Exception("Failed");
    }
  }
}