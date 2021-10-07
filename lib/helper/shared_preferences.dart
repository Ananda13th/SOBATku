import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {

  static Future<bool> checkUserExist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? _user = prefs.getBool('userExist');
    if(_user == true)
      return true;
    else
      return false;
  }

  static Future<List<String>?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList('user');
    return data;
  }

  static Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("user", ["","",""]);
    prefs.setBool("userExist", false);
  }

  static Future<void> addFavorite(List<String> favorite) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("favorite", favorite);
  }

  static Future<List<String>?> getFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getStringList('favorite') != null) {
      List<String>? data = prefs.getStringList('favorite');
      return data;
    }
    else {
      List<String>? data = [""];
      return data;
    }
  }
}