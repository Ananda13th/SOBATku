import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/helper/toastNotification.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/page/tambah_pasien.dart';
import 'package:sobatku/service/bpjs_service.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/user_service.dart';
import 'halaman_utama.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  static final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  late PasienService pasienService;
  late UserService userService;
  late Future<List<Pasien>> dataFuturePasien;
  late BpjsService bpjsService;
  TextEditingController pwController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController noBpjsController = TextEditingController();

  List<String> user = ["", "", "", ""];
  bool isOnline = true;

  @override
  void initState(){
    super.initState();
    _initPackageInfo();
    pasienService = PasienService();
    userService = UserService();
    bpjsService = BpjsService();

    dataFuturePasien = getPasien();
    checkConnectivity().then((value) {
      setState(() {
        isOnline = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/error_picture.jpg"), context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(child: Text("Profil")),
          backgroundColor: Constant.color
      ),
      body: Container(
        decoration: isOnline ?
        BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Background.png"),
            alignment: Alignment.center,
            fit: BoxFit.cover
          )
        ) :
        BoxDecoration(
          color: Colors.white,
        ),
        child: FutureBuilder<bool>(
          future: checkConnectivity(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.hasData) {
              if (snapshot.data)
                return Column(
                    children: <Widget>[
                      Card(
                        color: Colors.white,
                        child: ClipPath(
                          child: Column(
                            children: [
                              Container(
                                height: 75,
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                        child: Container(
                                          child: ListTile(
                                            title: Text("Halo, " + user[1], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            subtitle: Text("Nomor HP : " + user[0], style: TextStyle(fontSize: 16)),
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
                                                      validator: (
                                                          String? value) {
                                                        if (value == null ||
                                                            value.isEmpty)
                                                          return 'Mohon Isikan Alamat Email';
                                                        if (!EmailValidator
                                                            .validate(value))
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
                                                        if (value == null ||
                                                            value.isEmpty) {
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
                                                      ToastNotification.showNotification('Harap Isi Semua Data', context, Colors.red)
                                                    }
                                                    else {
                                                      userService.updateUser(user[2], emailController.text, pwController.text).then((value) {
                                                        ToastNotification.showNotification(value, context, Constant.color);
                                                        updateUSer(emailController.text);
                                                      }),
                                                      Navigator.pop(context),
                                                      rebuild(setState)
                                                    }
                                                  },
                                                  child: Text("Simpan", style: TextStyle(color: Colors.white, fontSize: 20),
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            SharedPreferenceHelper.logOut().then((value) =>
                                              Navigator.pushReplacement(context,
                                                MaterialPageRoute(
                                                  builder: (context) => new MyApp())
                                              )
                                            );
                                          },
                                          child: Text("Keluar"),
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Constant.color))
                                        ),
                                      )
                                  )
                                ],
                              )
                            ],
                          ),
                          clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)
                            )
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          color: Colors.transparent,
                          child: FutureBuilder<List<Pasien>>(
                            future: dataFuturePasien,
                            builder: (BuildContext context,
                                AsyncSnapshot snapshot) {
                              if (snapshot.hasError) {
                                return Container(
                                  color: Colors.white,
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [
                                      Image.asset(
                                          "assets/images/error_picture.jpg",
                                          fit: BoxFit.contain),
                                      Text("Maaf, Gagal Memuat Pasien",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26)),
                                    ],
                                  ),
                                );
                              } else if (snapshot.hasData) {
                                List<Pasien> patients = snapshot.data;
                                return _buildListPasien(patients);
                              } else {
                                return Container(
                                  child: Center(
                                      child: Container(
                                        width: 150,
                                        height: 150,
                                        child: CircularProgressIndicator(
                                          color: Constant.color,
                                        ),
                                      )
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(_packageInfo.appName + " Ver " + _packageInfo.version),
                        ),
                      )
                    ]
                );
              else
                return Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/error_picture.jpg",
                          fit: BoxFit.contain),
                      Text("Maaf, Terjadi Kesalahan", style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 26)),
                      Text("*Harap Cek Koneksi Internet Anda", style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                );
            }
            else {
              return Container();
            }
          }
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TambahPasien())).then((value) {
              onGoBack(value);
            });
        },
        icon: Icon(Icons.person_add, color: Constant.color,),
        label: Text('Pasien', style: TextStyle(color: Constant.color)),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  Widget _buildListPasien(List<Pasien> daftarPasien) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.grey[400]),
        itemCount: daftarPasien.length,
        itemBuilder: (context, index) {
          Pasien pasien = daftarPasien[index];
          return Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Constant.color,
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ListTile(
                              leading: pasien.jenisKelamin.toLowerCase() == "l" ? Image.asset("assets/icons/avatar_l.png", fit: BoxFit.fill) : Image.asset("assets/icons/avatar_p.png", fit: BoxFit.contain),
                              title: Text(pasien.namaPasien, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                children: [
                                  SizedBox(height: 5),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Nomor RM : " + pasien.nomorRm, style: TextStyle(color: Colors.white, fontSize: 14))
                                  ),
                                  SizedBox(height: 5),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Nomor BPJS : " + pasien.nomorBpjs, style: TextStyle(color: Colors.white, fontSize: 14))
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ButtonBarTheme(
                            data: ButtonBarThemeData(
                              alignment: MainAxisAlignment.spaceAround
                            ),
                            child: ButtonBar(
                              children: <Widget>[
                                TextButton.icon(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  label: const Text('Ubah BPJS', style: TextStyle(color: Colors.white, fontSize: 18)),
                                  onPressed: () {
                                    noBpjsController.text = pasien.nomorBpjs;
                                    Alert(
                                        context: context,
                                        title: "Ubah Nomor BPJS Pasien",
                                        content: Column(
                                          children: <Widget>[
                                            TextField(
                                              keyboardType: TextInputType.number,
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
                                            onPressed: () {
                                              bpjsService.cekAtivasi(noBpjsController.text).then((value) {
                                                if (value == "aktif") {
                                                  pasienService.updateNoBpjs(noBpjsController.text, pasien.nomorRm).then((value) {
                                                    if (value) {
                                                      ToastNotification.showNotification("Berhasil Ubah Nomor BPJS", context, Constant.color);
                                                      Future.delayed(Duration(seconds: 3)).then((value) => Navigator.pop(context));
                                                      setState(() {
                                                        dataFuturePasien = getPasien();
                                                      });
                                                    }
                                                    else
                                                      ToastNotification.showNotification("Gagal Ubah Nomor BPJS", context, Colors.red);
                                                  });
                                                }
                                                else
                                                  ToastNotification.showNotification(value.toString(), context, Colors.red);
                                              });
                                            },
                                            child: Text(
                                              "Simpan",
                                              style: TextStyle(color: Colors.white, fontSize: 20),
                                            ),
                                          )
                                        ]).show();
                                  }
                                ),
                                TextButton.icon(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  label: const Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 18)),
                                  onPressed: () {
                                    userService.deleteFromFirebase(user[2], pasien.namaPasien);
                                    pasienService.deletePairing(user[2], pasien.nomorRm).then((value) {
                                      print(value);
                                      rebuild(setState);
                                    });
                                  }
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
      user[3] = emailController.text;
    });
  }

  Future<void> getUserPrefs() async {
    SharedPreferenceHelper.getUser().then((value) {
      setState(() {
        user=value!;
        emailController.text = user[3];
      });
    });
  }

  Future<List<Pasien>> getPasien() async {
    await getUserPrefs();
    return pasienService.getPairing(user[2]);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none)
      return false;
    else
      return true;
  }
}
