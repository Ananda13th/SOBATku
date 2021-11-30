import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/helper/toastNotification.dart';
import 'package:sobatku/service/bpjs_service.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'halaman_utama.dart';


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
  TextEditingController noBpjsController = TextEditingController();

  late PasienService pasienService;
  late BpjsService bpjsService;
  late String userId;

  @override
  void initState() {
    super.initState();
    pasienService = PasienService();
    bpjsService = BpjsService();

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
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: namaField,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.person),
                              labelText: 'Nama Belakang Pasien',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon Isikan Nama Belakang Pasien';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 5),
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
                                      ToastNotification.showNotification('Harap Isi Semua Data', context, Colors.red);
                                    } else {
                                      /** CARI PASIEN PADA DATABASE, KEMBALIAN SERVICE BERUPA NOMOR BPJS PASIEN **/
                                      pasienService.searchPasien(noRmField.text, namaField.text).then(
                                        (noBpjsPasien) {
                                          if(noBpjsPasien == false) {
                                            ToastNotification.showNotification('Pasien Tidak Ditemukan', context, Colors.red);
                                          }
                                          else {
                                            /** BUAT PAIRING ANTARA PASIEN DAN USER **/
                                            setState(() {
                                              noBpjsController.text = noBpjsPasien;
                                            });
                                            Alert(
                                              context: context,
                                              title: "Cek Nomor BPJS Pasien",
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
                                                    pasienService.createPairing(noRmField.text, userId);
                                                    ToastNotification.showNotification("Berhasil Menambah Pasien", context, Constant.color);
                                                    Future.delayed(Duration(seconds: 2)).then((value) =>
                                                        Navigator.of(context).pushReplacement(
                                                            new MaterialPageRoute(builder: (context) => new MyApp()))
                                                    );
                                                  },
                                                  child: Text(
                                                    "Lewati dan Simpan",
                                                    style: TextStyle(color: Colors.white, fontSize: 16, ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                DialogButton(
                                                  onPressed: () {
                                                    /** CEK STATUS KEAKTIFAN BPJS **/
                                                    bpjsService.cekAtivasi(noBpjsController.text).then((value) {
                                                      if (value == "aktif") {
                                                        pasienService.createPairing(noRmField.text, userId);
                                                        /** BILA AKTIF, NOMOR BPJS AKAN DIUPDATE **/
                                                        pasienService.updateNoBpjs(noBpjsController.text, noRmField.text).then((value) {
                                                          if (value) {
                                                            ToastNotification.showNotification("Berhasil Menambah Pasien", context, Constant.color);
                                                            Future.delayed(Duration(seconds: 2)).then((value) =>
                                                                Navigator.of(context).pushReplacement(
                                                                    new MaterialPageRoute(builder: (context) => new MyApp()))
                                                            );
                                                          }
                                                          else
                                                            ToastNotification.showNotification("Gagal Menambah Pasien", context, Colors.red);
                                                        });
                                                      }
                                                      else
                                                        ToastNotification.showNotification("Nomor BPJS "+ value.toString(), context, Colors.red);
                                                    });
                                                  },
                                                  child: Text(
                                                    "Simpan",
                                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                                  ),
                                                )
                                              ]
                                            ).show();
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
