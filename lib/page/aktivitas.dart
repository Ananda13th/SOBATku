import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/model/transaksi_resp.dart';
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

  @override
  void initState() {
    super.initState();
    transaksiService = TransaksiService();
    _dataFuture = _getService();
  }

  _getService() async {
    await getUserPrefs();
    return transaksiService.getTransaksi(user[2]);
  }

  @override
  Widget build(BuildContext context) {
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
                            return Center(
                              child: Text("Error"),
                            );
                          } else if (snapshot.hasData){
                            List<TransaksiResp> response = snapshot.data;
                            List<TransaksiResp> aktif =  List.empty(growable: true);
                            DateTime now = DateTime.now();
                            response.forEach((element) {
                              String date =  DateFormat("yyyy-MM-dd").format(DateTime.parse(element.tanggal).add(Duration(hours: 7)));
                              element.tanggal = date;
                              if(!DateTime.parse(element.tanggal).isBefore(now))
                                aktif.add(element);
                            });
                            return _buildListAktivitas(aktif, "aktif");
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
              Column(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(image:
                      DecorationImage(
                          image: AssetImage("assets/images/Background.png"),
                          alignment: Alignment.center,
                          fit: BoxFit.fill)),
                      child: FutureBuilder(
                        future: _dataFuture,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if(snapshot.hasError) {
                            print(snapshot);
                            return Center(
                              child: Text("Error"),
                            );
                          } else if (snapshot.hasData) {
                            List<TransaksiResp> response = snapshot.data;
                            List<TransaksiResp> riwayat = List.empty(growable: true);
                            DateTime now = DateTime.now();
                            response.forEach((element) {
                              String date =  DateFormat("yyyy-MM-dd").format(DateTime.parse(element.tanggal).add(Duration(hours: 7)));
                              element.tanggal = date;
                              if(DateTime.parse(element.tanggal).isBefore(now))
                                riwayat.add(element);
                            });
                            return _buildListAktivitas(riwayat, "riwayat");
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
          return Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pasien", style: TextStyle(fontSize: 12)),
                        Text(tResp.namaPasien, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Dokter", style: TextStyle(fontSize: 12)),
                        Text(tResp.namaDokter, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Spesialis", style: TextStyle(fontSize: 12)),
                        Text(tResp.spesialis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Waktu", style: TextStyle(fontSize: 12)),
                        Text(DateFormat("dd-MM-yyy").format(DateTime.parse(tResp.tanggal)) + " " + tResp.waktu, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                      ],
                    )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("No. Antrian", style: TextStyle(fontSize: 12)),
                    Text(tResp.antrian, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                    tipe == "aktif" ?
                    InkWell(
                      onTap: (){_buildQr(context, tResp);},
                      child: QrImage(
                        data: tResp.kodeJadwal + "." + tResp.antrian + "." + tResp.nomorRm,
                        version: QrVersions.auto,
                        size: 75.0,
                      ),
                    ) :
                    Container(
                        height: 75,
                        child: Column(
                          children: [
                            Text("Kode Booking : "),
                            Center(child: Text(tResp.kodeJadwal + "." + tResp.antrian + "." + tResp.nomorRm, style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        )
                    )
                  ]
                ),
              )
            ],
          );
        }
    );
  }

  Future<void> getUserPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = prefs.getStringList("user")!;
    setState(() {});
  }

  Future<void> _buildQr(BuildContext context, TransaksiResp tResp) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 250,
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
  }
  
}
