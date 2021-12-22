import 'dart:convert';

import 'package:crypto/crypto.dart';

class URL {
  static const String urlAddress = "https://appbk01.droensolobaru.com/api/v1/";
  // static String mockAddress = "http://192.167.4.32:3001/api/v1/";
  static const id = "ancient one";
  static const password = "secretkey";

  static String createXSignature(String tStamp) {
    var data = utf8.encode(id);
    var secretKey = utf8.encode(password);
    var hMacSha256 = Hmac(sha256, secretKey);
    var signature = hMacSha256.convert(data + utf8.encode("&") + utf8.encode(tStamp));
    var encodedSignature = base64Encode(signature.bytes);
    return encodedSignature.toString();
  }

  static String createXTimestamp() {
    return DateTime.now().toUtc().millisecondsSinceEpoch.toString().substring(0, 10);
  }

  static Map<String,String> createHeader() {
    String timestamp  = createXTimestamp();
    String signature = createXSignature(timestamp);
    Map<String, String> _header = <String, String>{
      'id'          : id,
      'time'        : timestamp,
      'token'       : signature,
      'Content-Type': 'application/json; charset=UTF-8',
    };
    return _header;
  }
}