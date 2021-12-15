import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sobatku/helper/url_helper.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/model/user.dart';

class UserService {
  var baseUrl = URL.urlAddress;

  Future<User?> getUser(String noHp, String password) async {
      String _finalUrl = baseUrl + "user/$noHp/$password";
      final response = await http.get(
          Uri.parse(_finalUrl),
          headers: URL.createHeader(),
      );
      if(response.statusCode == 200) {
          final data = json.decode(response.body);
          List<dynamic> array = data['data'];
          if(array.length == 0)
            return null;
          else
            return User.fromJson(data['data'][0]);
      } else {
       throw Exception();
      }
  }

  Future<bool> createUser(User newUser) async {
    final response = await http.post(
        Uri.parse(baseUrl + "user"),
        headers: URL.createHeader(),
        body: json.encode(newUser)
    );
    if(response.statusCode == 200) {
        return true;
    } else {
        throw Exception("Failed");
    }
  }

  Future<String> updateUser(String id, String email, String password) async {
    final response = await http.put(
        Uri.parse(baseUrl + "user/$id/$email/$password"),
        headers: URL.createHeader(),
    );
    if(response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['message'];
    } else {
      return "Terjadi Kesalahan";
    }
  }

  Future<String> resetPassword(String nomorHp, String password) async {
    final response = await http.put(
      Uri.parse(baseUrl + "user/$nomorHp/$password"),
      headers: URL.createHeader(),
    );
    if(response.statusCode == 200) {
      return "Berhasil Mengirim Password Ke Nomor Anda, Harap Tunggu";
    } else {
      return "Terjadi Kesalahan";
    }
  }

  Future<String> sendOtp(String noHp) async {
    final response = await http.get(
      Uri.parse(baseUrl + "verifikasi/otp/create/$noHp"),
      headers: URL.createHeader(),
    );
    if(response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['message'];
    } else {
      return "Terjadi Kesalahan";
    }
  }

  Future<String> resendOtp(String noHp) async {
    final response = await http.put(
      Uri.parse(baseUrl + "verifikasi/resend/$noHp"),
      headers: URL.createHeader(),
    );
    if(response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['message'];
    } else {
      return "Terjadi Kesalahan";
    }
  }

  Future<String> verifyOtp(String noHp, String kodeOtp) async {
    final response = await http.put(
      Uri.parse(baseUrl + "verifikasi/otp/verify/$noHp/$kodeOtp"),
      headers: URL.createHeader(),
    );
    if(response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['message'];
    } else {
      return "Terjadi Kesalahan";
    }
  }

  Future<String> saveToFirebase(String id, Pasien pasien, String fcm) async {
    Map<String, String> body = <String, String>{
      'idUser'      : id,
      'namaPasien'  : pasien.namaPasien,
      'noRm'        : pasien.nomorRm,
      'fcmToken'    : fcm,
    };

    final response = await http.post(
        Uri.parse(baseUrl + "user/add/firebase"),
        headers: URL.createHeader(),
        body: json.encode(body)
    );

    if(response.statusCode == 200) {
      return "Berhasil";
    } else {
      return "Terjadi Kesalahan";
    }
  }

  Future<String> deleteFromFirebase(String id, String namaPasien) async {
    final response = await http.delete(
        Uri.parse(baseUrl + "user/delete/firebase/$id/$namaPasien"),
        headers: URL.createHeader(),
    );
    if(response.statusCode == 200) {
      return "Berhasil";
    } else {
      return "Terjadi Kesalahan";
    }
  }

}