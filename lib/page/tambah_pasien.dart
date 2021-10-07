import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/service/pasien_service.dart';

import '../main.dart';

class TambahPasien extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TambahPasienState();
  }
}

class TambahPasienState extends State<TambahPasien> {
  TextEditingController noRmField = TextEditingController();
  TextEditingController noBpjsField = TextEditingController();
  TextEditingController noKtpField = TextEditingController();
  TextEditingController namaField = TextEditingController();

  late PasienService pasienService;
  late String userId;

  @override
  void initState() {
    super.initState();
    pasienService = PasienService();

    SharedPreferenceHelper.getUser().then((value) {
      setState(() {
        userId = value![2];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Daftar Pasien Baru"),
            backgroundColor: Constant.color,
          ),
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
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 175, 16, 5),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // TextFormField(
                          //   autovalidateMode: AutovalidateMode.onUserInteraction,
                          //   controller: namaField,
                          //   decoration: const InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     icon: Icon(Icons.person),
                          //     labelText: 'Nama Belakang Pasien',
                          //   ),
                          //   validator: (String? value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Mohon Isikan Nama Belakang Pasien';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          // SizedBox(height: 5),
                          // TextFormField(
                          //   controller: noBpjsField,
                          //   keyboardType: TextInputType.number,
                          //   autovalidateMode: AutovalidateMode.always,
                          //   decoration: const InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     icon: Icon(Icons.confirmation_number),
                          //     labelText: 'Nomor BPJS',
                          //   ),
                          //   validator: (String? value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Mohon Isikan Data';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          // SizedBox(height: 5),
                          // TextFormField(
                          //   controller: noKtpField,
                          //   keyboardType: TextInputType.number,
                          //   autovalidateMode: AutovalidateMode.always,
                          //   decoration: const InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     icon: Icon(Icons.confirmation_num_outlined),
                          //     labelText: 'Nomor KTP',
                          //   ),
                          //   validator: (String? value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Mohon Isikan Data';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          // SizedBox(height: 5),
                          TextFormField(
                            controller: noRmField,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.credit_card),
                              labelText: 'Nomor Rekam Medis',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon Isikan Nomor Rekam Medis Pasien';
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
                                      );
                                    } else {
                                      pasienService.searchPasien(noRmField.text).then(
                                        (value) {
                                          if(value == false) {
                                            Pasien pasien = new Pasien(namaPasien: namaField.text, nomorBpjs: noBpjsField.text, nomorKtp: noKtpField.text, nomorRm: noRmField.text);
                                            pasienService.createPasien(pasien).then(
                                              (value) {
                                                if(value == "Success") {
                                                  pasienService.createPairing(noRmField.text, userId);
                                                  Navigator.of(context).pushReplacement(
                                                      new MaterialPageRoute(builder: (context) => new MyApp())
                                                  );
                                                }
                                              }
                                            );
                                          }
                                          else if(value == true){
                                            pasienService.createPairing(noRmField.text, userId).then((value) => print(value));
                                            Navigator.of(context).pushReplacement(
                                                new MaterialPageRoute(builder: (context) => new MyApp()));
                                          }
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
              )
          )
      ),
    );
  }
}
