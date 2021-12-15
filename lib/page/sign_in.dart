import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/toastNotification.dart';
import 'package:sobatku/page/sign_up.dart';
import 'package:sobatku/service/user_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'halaman_utama.dart';
import 'konfirmasi_otp.dart';

class SignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignInState();
  }
}

class SignInState extends State<SignIn> {
  TextEditingController noHpField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  late UserService userService;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userService = UserService();
    setSharedPreferences();
  }

  Future setSharedPreferences() async {
    prefs = await _prefs;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container (
          decoration: BoxDecoration(
              image: DecorationImage(
              image: AssetImage("assets/images/Login_Kosongan.png"),
              alignment: Alignment.center,
              fit: BoxFit.cover
            )
          ),
          child: Center(
            child: Container(
              height: 330,
              width: 400,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child:
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.phone,
                        controller: noHpField,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Padding(
                            padding: EdgeInsets.fromLTRB(8, 6, 8, 8),
                            child: Text("+62",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                          prefixIconConstraints:
                          BoxConstraints(minWidth: 0, minHeight: 0),
                          icon: Icon(Icons.phone_android),
                          labelText: 'Nomor HP',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon Isikan Nomor HP';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        controller: passwordField,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          icon: Icon(Icons.password),
                          labelText: 'Kata Sandi',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon Isikan Kata Sandi';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 41),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(text: 'Atur Ulang Password? ', style: TextStyle(color: Colors.black)),
                                TextSpan(
                                    text: 'Klik Disini',
                                    style: TextStyle(color: Constant.color, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Alert(
                                        title: "Reset Password",
                                        context: context,
                                        content: Form(
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: 20,
                                              ),
                                              TextFormField(
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                keyboardType: TextInputType.phone,
                                                controller: noHpField,
                                                decoration: const InputDecoration(
                                                  hintText: "Isikan Nomor Yang HP Terdaftar",
                                                  border: OutlineInputBorder(),
                                                  prefixIcon: Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text("+62",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold)),
                                                  ),
                                                  prefixIconConstraints:
                                                  BoxConstraints(minWidth: 0, minHeight: 0),
                                                  labelText: 'Nomor HP',
                                                ),
                                                validator: (String? value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Mohon Isikan Nomor HP';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        buttons: [
                                          DialogButton(
                                            onPressed: (){
                                              String noHp = noHpField.text;
                                              if(noHpField.text.substring(0,1) == "0")
                                                noHp.replaceFirst(RegExp('0'), "+62");
                                              else
                                                noHp = "+62" + noHpField.text;
                                              userService.sendOtp(noHp);
                                              Navigator.of(context).pushReplacement(
                                                  new MaterialPageRoute(builder: (context) => new TampilanKonfirmasiPin(noHp, "reset")));
                                            },
                                            child: Text(
                                              "Atur Ulang Password",
                                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ]).show();
                                    }
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (){
                                  if (!_formKey.currentState!.validate()) {
                                    ToastNotification.showNotification('Harap Isi Semua Data', context, Colors.red);
                                  } else {
                                    String noHp = noHpField.text;
                                    if(noHpField.text.substring(0,1) == "0")
                                        noHp.replaceFirst(RegExp('0'), "+62");
                                    else
                                      noHp = "+62" + noHpField.text;
                                    userService.getUser(noHp, passwordField.text).then((value) {
                                      if (value != null) {
                                        List<String> data = [
                                          value.nomorHp,
                                          value.namaUser,
                                          value.idUser.toString(),
                                          value.email
                                        ];
                                        prefs.setStringList("user", data);
                                        prefs.setBool("userExist", true);
                                        Navigator.pushReplacement(
                                            context, MaterialPageRoute(builder: (context) => new MyApp()));
                                      } else {
                                        ToastNotification.showNotification('Pengguna Tidak Ditemukan', context, Colors.red);
                                      }
                                    });
                                  }
                                },
                                child: Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Constant.color)),
                              ),
                            )
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: 'Belum Punya Akun? ', style: TextStyle(color: Colors.black)),
                            TextSpan(
                              text: 'Daftar Disini',
                              style: TextStyle(color: Constant.color, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => new SignUp()));
                              }
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        )
      ),
    );
  }
}
