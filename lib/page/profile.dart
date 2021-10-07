import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/page/tambah_pasien.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/user_service.dart';

import '../main.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  static final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  late PasienService pasienService;
  late UserService userService;
  late Future<List<Pasien>> dataFuturePasien;

  TextEditingController pwController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController noBpjsController = TextEditingController();

  List<String> user = ["","",""];

  @override
  void initState() {
    super.initState();
    pasienService = PasienService();
    userService = UserService();
    dataFuturePasien = getPasien();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(child: Text("Profil")),
          backgroundColor: Constant.color
      ),
        body: Container(
          decoration: BoxDecoration(image:
          DecorationImage(
              image: AssetImage("assets/images/Background.png"),
              alignment: Alignment.center,
              fit: BoxFit.cover)),
          child: Column(
            children: <Widget>[
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: ClipPath(
                  child: Column(
                    children: [
                      Container(
                          height: 100,
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                  child: SizedBox(
                                    child: ListTile(
                                      title: Text(user[1]),
                                      subtitle: Text(user[0]),
                                    ),
                                  )
                              ),
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Alert(
                                        context: context,
                                        title: "Ubah Data Pengguna",
                                        content: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                controller: emailController..text,
                                                decoration: InputDecoration(
                                                  icon: Icon(Icons.email),
                                                  labelText: "Email",
                                                ),
                                                validator: (String? value) {
                                                  if (value == null || value.isEmpty)
                                                    return 'Mohon Isikan Alamat Email';
                                                  if(!EmailValidator.validate(value))
                                                    return 'Alamat Email Tidak Valid';
                                                  return null;
                                                },
                                              ),
                                              TextFormField(
                                                controller: pwController,
                                                obscureText: true,
                                                decoration: InputDecoration(
                                                  icon: Icon(Icons.password),
                                                  labelText: "Kata Sandi",
                                                ),
                                                validator: (String? value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Mohon Isikan Password';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        buttons: [
                                          DialogButton(
                                            onPressed: () =>
                                            {
                                              if (!_formKey.currentState!.validate()) {
                                                print("Gagal"),
                                                showToast('Harap Isi Semua Data',
                                                  context: context,
                                                  textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
                                                  backgroundColor: Colors.red,
                                                  animation: StyledToastAnimation.scale,
                                                  reverseAnimation: StyledToastAnimation.fade,
                                                  position: StyledToastPosition.center,
                                                  animDuration: Duration(seconds: 1),
                                                  duration: Duration(seconds: 4),
                                                  curve: Curves.elasticOut,
                                                  reverseCurve: Curves.linear,
                                                )
                                              } else {
                                                print("Sukses"),
                                                userService.updateUser(user[2], emailController.text, pwController.text).then((value) {
                                                  showToast(value,
                                                    context: context,
                                                    textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
                                                    backgroundColor: Constant.color,
                                                    animation: StyledToastAnimation.scale,
                                                    reverseAnimation: StyledToastAnimation.fade,
                                                    position: StyledToastPosition.center,
                                                    animDuration: Duration(seconds: 1),
                                                    duration: Duration(seconds: 4),
                                                    curve: Curves.elasticOut,
                                                    reverseCurve: Curves.linear,
                                                  );
                                                  updateUSer(emailController.text);}),
                                                Navigator.pop(context), rebuild(setState)
                                              }
                                            },
                                            child: Text(
                                              "Simpan",
                                              style: TextStyle(color: Colors.white, fontSize: 20),
                                            ),
                                          )
                                        ]).show();
                                  }),
                            ],
                          ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  SharedPreferenceHelper.logOut().then((value) =>  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new MyApp())));
                                },
                                child: Text("Keluar"),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Constant.color))
                              )
                          )
                        ],
                      )
                    ],
                  ),
                  clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3))),
                ),
              ),
              SizedBox(height: 10,),
              Text("Daftar Pasien", style: TextStyle(fontSize: 32)),
              Flexible(
                child: Container(
                  color: Colors.transparent,
                  child: FutureBuilder<List<Pasien>>(
                    future: dataFuturePasien,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if(snapshot.hasError) {
                        print(snapshot);
                        return Center(
                          child: Text("Terjadi Kesalahan"),
                        );
                      } else if (snapshot.hasData){
                          List<Pasien> patients = snapshot.data;
                          return _buildListView(patients);
                      } else {
                        return Center(
                          child: Container(),
                        );
                      }
                    },
                  ),
                ),
              )
            ],
      ),
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constant.color,
        onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TambahPasien())).then((value) => onGoBack(value));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  Widget _buildListView(List<Pasien> patients) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.grey[400]),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          Pasien patient = patients[index];
          return Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Placeholder(),
                ),
              ),
              Flexible(
                child: Container(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(patient.namaPasien),
                    subtitle: Text(patient.nomorRm),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              noBpjsController.text = patient.nomorBpjs;
                              Alert(
                                  context: context,
                                  title: "Ubah Data Pasien",
                                  content: Column(
                                    children: <Widget>[
                                      TextField(
                                        controller: noBpjsController..text,
                                        decoration: InputDecoration(
                                          icon: Icon(Icons.account_circle),
                                          labelText: "Nomor BPJS",
                                        ),
                                      ),
                                    ],
                                  ),
                                  buttons: [
                                    DialogButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "Simpan",
                                        style: TextStyle(color: Colors.white, fontSize: 20),
                                      ),
                                    )
                                  ]).show();
                            }),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            pasienService.deletePairing(user[2], patient.nomorRm).then((value) {
                              print(value);
                              rebuild(setState);
                            });
                          })
                      ],
                    )
                  ),
                )
              )
            ],
          );
        }
    );
  }

  Future<void> updateUSer(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("user", [email,user[1],user[2]]);
  }

  void rebuild(setState) {
    setState(() {
      dataFuturePasien = pasienService.getPairing(user[2]);
      user[0] = emailController.text;
    });
  }

  Future<void> getUserPrefs() async {
    SharedPreferenceHelper.getUser().then((value) {
      setState(() {
        user=value!;
        emailController.text = user[0];
      });
    });
  }

  Future<List<Pasien>> getPasien() async {
    await getUserPrefs();
    return pasienService.getPairing(user[2]);
  }
}
