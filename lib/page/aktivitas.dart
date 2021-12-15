import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/model/transaksi_resp.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/transaksi_service.dart';

class Aktivitas extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AktivitasState();
  }
}

class _AktivitasState extends State<Aktivitas> {
  late TransaksiService transaksiService;
  late List<String> user = ["","",""];
  late Future _dataFuture;
  late PasienService pasienService;
  List<TransaksiResp> daftarTransaksi = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    transaksiService = TransaksiService();
    pasienService = PasienService();
    _dataFuture = _getService();

    _dataFuture.then((result) {
        result.forEach((pasien) {
          transaksiService.getTransaksi(pasien.nomorRm).then((value) {
            value.forEach((element) {
              setState(() {
                daftarTransaksi.add(element);
              });
            });
          });
        });
    });
  }

  _getService() async {
    await getUserPrefs();
    return pasienService.getPairing(user[2]);
    //return transaksiService.getTransaksi(user[2]);
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/error_picture.jpg"), context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Aktivitas")),
          backgroundColor: Constant.color,
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 20),
            tabs: [
              Tab(text: "Aktif"),
              Tab(text: "Riwayat"),
            ]
          ),
        ),
        body: TabBarView(
            children: [
              Column(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(image:
                      DecorationImage(
                          image: AssetImage("assets/images/Background.png"),
                          alignment: Alignment.center,
                          fit: BoxFit.cover)),
                      child: FutureBuilder(
                        future: _dataFuture,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if(snapshot.hasError) {
                            print(snapshot);
                            return Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/error_picture.jpg", fit: BoxFit.contain),
                                  Text("Maaf, Terjadi Kesalahan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                                ],
                              ),
                            );
                          } else if (snapshot.hasData){
                            List<TransaksiResp> response =daftarTransaksi;
                            List<TransaksiResp> aktif =  List.empty(growable: true);
                            DateTime now = DateTime.now();
                            response.forEach((element) {
                              String date =  DateFormat("yyyy-MM-dd").format(DateTime.parse(element.tanggal).add(Duration(hours: 7)));
                              element.tanggal = date;
                              if(!DateTime.parse(element.tanggal).isBefore(now.subtract(Duration(days: 1))))
                                aktif.add(element);
                            });
                            return _buildListAktivitas(aktif, "aktif");
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
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/Background.png"),
                          alignment: Alignment.center,
                          fit: BoxFit.fill)
                      ),
                      child: FutureBuilder(
                        future: _dataFuture,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if(snapshot.hasError) {
                            print(snapshot);
                            return Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/error_picture.jpg", fit: BoxFit.contain),
                                  Text("Maaf, Terjadi Kesalahan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                                ],
                              ),
                            );
                          } else if (snapshot.hasData) {
                            List<TransaksiResp> response = daftarTransaksi;
                            List<TransaksiResp> riwayat = List.empty(growable: true);
                            DateTime now = DateTime.now();
                            response.forEach((element) {
                              String date =  DateFormat("yyyy-MM-dd").format(DateTime.parse(element.tanggal).add(Duration(hours: 7)));
                              element.tanggal = date;
                              if(DateTime.parse(element.tanggal).isBefore(now.subtract(Duration(days: 1))))
                                riwayat.add(element);
                            });
                            return _buildListAktivitas(riwayat, "riwayat");
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
                  )
                ],
              )
            ]
        )
      ),
    );
  }

  Widget _buildListAktivitas(List<TransaksiResp> response, String tipe) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.black, thickness: 1),
        itemCount: response.length,
        itemBuilder: (context, index) {
          TransaksiResp tResp = response[index];
          return Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
            child: Container(
              height: 245,
              child: Card(
                color: tipe == "aktif" ? Constant.color.withOpacity(0.4) : Colors.grey,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Center(
                        child: Container(
                          child: Image.asset(
                            "assets/images/LogoRs.png",
                            scale: 3,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget> [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Pasien", style: TextStyle(fontSize: 13)),
                                    Text(tResp.namaPasien, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("Dokter", style: TextStyle(fontSize: 13)),
                                    Text(tResp.namaDokter, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("Spesialis", style: TextStyle(fontSize: 13)),
                                    Text(tResp.spesialis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("Tanggal", style: TextStyle(fontSize: 13)),
                                    Text(DateFormat("dd-MM-yyy").format(DateTime.parse(tResp.tanggal)), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("Jam", style: TextStyle(fontSize: 13)),
                                    Text(tResp.waktu, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                                  ],
                                )
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text("No. Antrian Anda", style: TextStyle(fontSize: 13)),

                                tipe == "aktif" ?
                                  Text(tResp.antrian, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold))
                                :
                                  Text("-", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),

                                Text("Antrian Berjalan", style: TextStyle(fontSize: 13)),

                                tipe == "aktif" ?
                                  Text(tResp.antrian, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                                :
                                  Text("-", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                                InkWell(
                                  onTap: () {
                                    _buildQr(context, tResp).then((value) => Screen.setBrightness(value));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      color: Colors.white,
                                      child: QrImage(
                                        data: tResp.kodeJadwal + "." + tResp.antrian + "." + tResp.nomorRm,
                                        version: QrVersions.auto,
                                        size: 75.0,
                                      ),
                                    ),
                                  ),
                                )
                              ]
                            ),
                          )
                        ],
                      ),
                    ),
                  ]
                ),
              ),
            ),
          );
        }
    );
  }

  Future<void> getUserPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = prefs.getStringList("user")!;
    setState(() {});
  }

  Future<double> getScreeenBrigthness() async {
    double currentBrightness = await Screen.brightness;
    return currentBrightness;
  }

  Future<double> _buildQr(BuildContext context, TransaksiResp tResp) async {
    double currentBrightness = await Screen.brightness;
    print(currentBrightness);
    Screen.setBrightness(1);
    await showDialog(
      barrierColor: Constant.color,
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height:250,
                  width: 250,
                  child: QrImage(
                    data: tResp.kodeJadwal + "." + tResp.antrian + "." + tResp.nomorRm,
                    version: QrVersions.auto,
                    errorStateBuilder: (cxt, err) {
                      return Container(
                        child: Center(
                          child: Text(
                            "Uh oh! Terjadi Kesalahan...",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(tResp.kodeJadwal + "." + tResp.antrian + "." + tResp.nomorRm)
              ],
            )
          ],
        );
      },
    );
    return currentBrightness;
  }
}
