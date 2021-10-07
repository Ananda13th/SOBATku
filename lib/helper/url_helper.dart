import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class URL {
  static String devAddress = "http://192.167.4.32:6000/api/v1/";
  static String prodAddress = "";

  static String createXSignature(String tStamp) {
    var data = utf8.encode("ancient one");
    var secretKey = utf8.encode("secretkey");
    var hMacSha256 = Hmac(sha256, secretKey);
    var signature = hMacSha256.convert(data + utf8.encode("&") + utf8.encode(tStamp));
    var encodedSignature = base64Encode(signature.bytes);
    return encodedSignature.toString();
  }

  static String createXTimestamp() {
    DateTime test = DateTime.parse("1970-01-01 00:00:00");
    String now = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now().toUtc());
    var tStamp = DateTime.parse(now).millisecondsSinceEpoch - test.millisecondsSinceEpoch;
    return tStamp.toString().substring(0,10);
  }

  static Map<String,String> createHeader() {
    String timestamp  = createXTimestamp();
    String signature = createXSignature(timestamp);
    Map<String, String> _header = <String, String>{
      'id'          : 'ancient one',
      'time'        : timestamp,
      'token'       : signature,
      'Content-Type': 'application/json; charset=UTF-8',
    };
    return _header;
  }
}