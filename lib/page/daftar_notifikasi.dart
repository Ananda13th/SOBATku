import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/model/notifikasi.dart';
import 'package:sobatku/service/notifikasi_service.dart';

class DaftarNotifikasi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DaftarNotifikasiState();
  }
}

class _DaftarNotifikasiState extends State<DaftarNotifikasi> {
  late NotifikasiService notifikasiService;
  late Future<List<Notifikasi>> futureNotif;
  List<String> user = ["","",""];

  @override
  void initState() {
    super.initState();
    notifikasiService = NotifikasiService();
    getUserPrefs().then((value) {
      setState(() {
        user=value!;
        futureNotif = notifikasiService.getNotifList(user[2].toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Daftar Notifikasi"),
          backgroundColor: Constant.color
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: Container(
              decoration: BoxDecoration(image:
              DecorationImage(
                  image: AssetImage("assets/images/Background.png"),
                  alignment: Alignment.center,
                  fit: BoxFit.fill)),
              child: FutureBuilder<List<Notifikasi>>(
                future: notifikasiService.getNotifList(user[2]),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.hasError) {
                    print(snapshot);
                    return Center(
                      child: Text("Error"),
                    );
                  } else if (snapshot.hasData){
                    List<Notifikasi> response = snapshot.data;
                    return _buildListView(response);
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
    );
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  Widget _buildListView(List<Notifikasi> response) {

    return ListView.separated(
      separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.black, thickness: 2),
      itemCount: response.length,
      itemBuilder: (context, index) {
        Notifikasi tResp = response[index];
        return Row(
          children: <Widget>[
            Flexible(
            child: Container(
              child: ListTile(
                  title: Text(tResp.judul),
                  subtitle: Text(tResp.berita)
                ),
              )
            )
          ],
        );
      }
    );
  }

  Future<List<String>?> getUserPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList("user");
    return data;
  }

}
