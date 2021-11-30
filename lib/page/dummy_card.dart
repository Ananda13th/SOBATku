import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/user_service.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class DummyCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DummyCardState();
  }
}

class _DummyCardState extends State<DummyCard> {

  late PasienService pasienService;
  late UserService userService;
  late Future<List<Pasien>> dataFuturePasien;

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
          title: Center(child: Text("Kartu Rumah Sakit")),
          backgroundColor: Constant.color
      ),
      body: Container(
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
                return _buildListPasien(patients);
              } else {
                return Center(
                  child: Container(),
                );
              }
            },
          ),
        ),
      );
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
                  child: Container(
                    height: 250,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                                  image: new AssetImage("assets/images/dummy_card.jpg")
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      topLeft: Radius.circular(15)
                                    ),
                                    color: Constant.color,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Center(child: Text("Kartu Pasien", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Center(child: Text("RS Dr. Oen Solo Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment:MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        children: [
                                          Container(
                                              width: 110,
                                              child:  Text("Nama Pasien ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                                          ),
                                          Container(
                                              width: 110,
                                              child: Text("Nomor RM ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                                          ),
                                          Container(
                                              width: 110,
                                              child: Text("Jenis Kelamin ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left,)
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(" : ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                                        Text(" : ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                                        Text(" : ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left,)
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 200,
                                            child: Text(pasien.namaPasien, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left)
                                        ),
                                        Container(
                                          width: 200,
                                            child: Text(pasien.nomorRm, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left)
                                        ),
                                        pasien.jenisKelamin == "L" ?
                                        Container(
                                            width: 200,
                                            child: Text("Laki-Laki", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left)
                                        ) :
                                        Container(
                                            width: 200,
                                            child: Text("Perempuan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left)
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 25),
                                Container(
                                  height: 50,
                                    child: SfBarcodeGenerator(
                                      symbology: Code39Extended(),
                                        value: pasien.nomorRm
                                    )
                                ),
                              ],
                            ),
                          ),
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


  Future<void> getUserPrefs() async {
    SharedPreferenceHelper.getUser().then((value) {
      setState(() {
        user=value!;
      });
    });
  }

  Future<List<Pasien>> getPasien() async {
    await getUserPrefs();
    return pasienService.getPairing(user[2]);
  }

}
