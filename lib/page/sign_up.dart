import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/toastNotification.dart';
import 'package:sobatku/model/user.dart';
import 'package:sobatku/page/konfirmasi_otp.dart';
import 'package:sobatku/service/user_service.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignUpState();
  }
}

class SignUpState extends State<SignUp> {
  TextEditingController emailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  TextEditingController noHpField = TextEditingController();
  TextEditingController namaField = TextEditingController();

  static final _namaFocus = FocusNode();
  static final _noHpFocus = FocusNode();
  static final _emailFocus = FocusNode();
  static final _passwordFocus = FocusNode();

  static final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  late UserService userService;

  @override
  void initState() {
    super.initState();
    userService = UserService();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(

      appBar: AppBar(
        title: Text("Daftar User Baru"),
        backgroundColor: Constant.color,
      ),
      body: Container (
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Background.png"),
            alignment: Alignment.center,
            fit: BoxFit.cover
          )
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: screenSize.height/6,
                width: screenSize.width,
                child: Center
                  (child: Image.asset("assets/images/LogoRs.png", fit: BoxFit.scaleDown,)
                )
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            autovalidateMode: AutovalidateMode.always,
                            keyboardType: TextInputType.phone,
                            controller: noHpField,
                            focusNode: _noHpFocus,
                            decoration: const InputDecoration(
                              isDense: true,
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
                              icon: Icon(Icons.phone_android),
                              labelText: 'Nomor HP',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Wajib Diisi';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            // autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: emailField,
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _emailFocus,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.email),
                              labelText: 'Email',
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            obscureText: true,
                            controller: passwordField,
                            focusNode: _passwordFocus,
                            autovalidateMode: AutovalidateMode.always,
                            decoration: const InputDecoration(
                              hintText: "6-12 Karakter",
                              isDense: true,
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.password),
                              labelText: 'Kata Sandi',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Wajib Diisi';
                              }
                              if(value.length > 12 || value.length < 6)
                                return 'Kata Sandi 6-12 Karakter';
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: namaField,
                            focusNode: _namaFocus,
                            autovalidateMode: AutovalidateMode.always,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.person),
                              labelText: 'Nama Lengkap',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Wajib Diisi';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (){
                                    if (!_formKey.currentState!.validate()) {
                                      ToastNotification.showNotification('Harap Isi Semua Data', context, Colors.red);
                                    } else {
                                      String noHp = noHpField.text;
                                      if(noHpField.text.substring(0,1) == "0") {
                                        noHp= noHp.replaceFirst("0", "+62");
                                      }
                                      else {
                                        noHp = "+62" + noHpField.text;
                                      }
                                      User user = new User(
                                          password: passwordField.text,
                                          namaUser: namaField.text,
                                          nomorHp: noHp,
                                          email: emailField.text);
                                      userService.createUser(user).then((value) {
                                        if(value) {
                                          userService.sendOtp(noHp);
                                          Navigator.of(context).pushReplacement(
                                            new MaterialPageRoute(builder: (context) => new TampilanKonfirmasiPin(noHp, "baru")));
                                        }
                                        else
                                          ToastNotification.showNotification('Terjadi Kesalahan', context, Colors.red);
                                        }
                                      );
                                    }
                                  },
                                  child: Text("DAFTAR"),
                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Constant.color)),
                                )
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      )
    );
  }
}
