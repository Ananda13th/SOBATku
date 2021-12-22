import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    precacheImage(AssetImage("assets/images/error_picture.jpg"), context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Center(child: Text("Daftar Kartu Pasien")),
          backgroundColor: Constant.color
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: new AssetImage("assets/images/Background.png")
          ),
        ),
        child: FutureBuilder<List<Pasien>>(
            future: dataFuturePasien,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError) {
                return Container(
                  decoration:  BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(4, 8), // Shadow position
                      ),
                    ],
                  ),
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
                List<Pasien> patients = snapshot.data;
                return _buildCardList(patients);
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
      );
  }

  Widget _buildCardList(List<Pasien> daftarPasien) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.grey[400]),
        itemCount: daftarPasien.length,
        itemBuilder: (context, index) {
          Pasien pasien = daftarPasien[index];
          return Row(
            children: <Widget>[
              Flexible(
                  child: Container(
                    height: 240,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {return DetailScreen(pasien: pasien);
                          }));
                        },
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
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                                    image: new AssetImage("assets/images/dummy_card.jpg")
                                ),
                              ),
                              child: Column(
                                children: [
                                  ClipPath(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          topLeft: Radius.circular(15)
                                        ),
                                        gradient:
                                        LinearGradient(
                                            colors: Constant.color.toString() == "Color(0xff1f8d91)" ?
                                            [Color.fromARGB(255, 162, 217, 212), Constant.color] :
                                            [Color(0xFFc2e59c), Constant.color]
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              height: 45,
                                              width: 50,
                                              child: Image.asset("assets/images/LogoRs.png", width: 45, height: 45,)
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                Container(
                                                    width: 200,
                                                    child: Text("RUMAH SAKIT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.left)),
                                                Container(
                                                    width: 200,
                                                    child: Text("Dr. OEN SOLO BARU", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.left)),
                                                Container(
                                                    width: 200,
                                                    child: Text("Komplek Perumahan Solo Baru, Grogol", style: TextStyle(fontSize: 10), textAlign: TextAlign.left)),
                                                Container(
                                                    width: 200,
                                                    child: Text("Sukoharji, Jawa Tengah PO Box 130 Solo", style: TextStyle(fontSize: 10), textAlign: TextAlign.left)),
                                                Container(
                                                    width: 200,
                                                    child: Text("Telp: 0271-620220 Fax 0271-622555", style: TextStyle(fontSize: 10), textAlign: TextAlign.left)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
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
                                                child:  Text("Nama Pasien ", style: TextStyle(fontSize: 14), textAlign: TextAlign.left,),
                                            ),
                                            Container(
                                                width: 110,
                                                child: Text("Nomor RM ", style: TextStyle(fontSize: 14), textAlign: TextAlign.left,),
                                            ),
                                            Container(
                                                width: 110,
                                                child: Text("Jenis Kelamin ", style: TextStyle(fontSize: 14), textAlign: TextAlign.left,)
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(" :  ", style: TextStyle(fontSize: 14), textAlign: TextAlign.left,),
                                          Text(" :  ", style: TextStyle(fontSize: 14), textAlign: TextAlign.left,),
                                          Text(" :  ", style: TextStyle(fontSize: 14), textAlign: TextAlign.left,)
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
                                    height: 40,
                                    width: 200,
                                    child: SfBarcodeGenerator(
                                      value: pasien.nomorRm
                                    )
                                  ),
                                ],
                              ),
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
//
// class ClipPathClass extends CustomClipper<Path> {
//   var path = new Path();
//   @override
//   Path getClip(Size size) {
//
//     var path = new Path();
//     path.lineTo(0, size.height); //start path with this if you are making at bottom
//
//     var firstStart = Offset(size.width / 5, size.height);
//     //fist point of quadratic bezier curve
//     var firstEnd = Offset(size.width / 2.25, size.height - 50.0);
//     //second point of quadratic bezier curve
//     path.quadraticBezierTo(firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);
//
//     var secondStart = Offset(size.width - (size.width / 3.24), size.height - 50);
//     //third point of quadratic bezier curve
//     var secondEnd = Offset(size.width, size.height - 10);
//     //fourth point of quadratic bezier curve
//     path.quadraticBezierTo(secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);
//
//     path.lineTo(size.width, 0); //end with this path if you are making wave at bottom
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return false; //if new instance have different instance than old instance
//     //then you must return true;
//   }
// }

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key, required this.pasien}) : super(key: key);
  final Pasien pasien;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            height: 300,
            width: 540,
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
                          fit: BoxFit.cover,
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
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Container(
                                    alignment: Alignment.topLeft,
                                    height: 45,
                                    width: 170,
                                    child: Image.asset("assets/images/LogoRs.png", width: 45, height: 45,)
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Text("Kartu Pasien", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Center(child: Text("RS Dr. Oen Solo Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                children: [
                                  Container(
                                    width: 150,
                                    child:  Text("Nama Pasien ", style: TextStyle(fontSize: 18), textAlign: TextAlign.left,),
                                  ),
                                  Container(
                                    width: 150,
                                    child: Text("Nomor RM ", style: TextStyle(fontSize: 18), textAlign: TextAlign.left,),
                                  ),
                                  Container(
                                      width: 150,
                                      child: Text("Jenis Kelamin ", style: TextStyle(fontSize: 18), textAlign: TextAlign.left,)
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(" :  ", style: TextStyle(fontSize: 18), textAlign: TextAlign.left,),
                                Text(" :  ", style: TextStyle(fontSize: 18), textAlign: TextAlign.left,),
                                Text(" :  ", style: TextStyle(fontSize: 18), textAlign: TextAlign.left,)
                              ],
                            ),
                            Column(
                              mainAxisAlignment:MainAxisAlignment.start,
                              children: [
                                Container(
                                    width: 200,
                                    child: Text(pasien.namaPasien, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left)
                                ),
                                Container(
                                    width: 200,
                                    child: Text(pasien.nomorRm, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left)
                                ),
                                pasien.jenisKelamin == "L" ?
                                Container(
                                    width: 200,
                                    child: Text("Laki-Laki", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left)
                                ) :
                                Container(
                                    width: 200,
                                    child: Text("Perempuan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left)
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                        Container(
                          height: 50,
                          width: 240,
                          child: SfBarcodeGenerator(
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
        ),
      ),
    );
  }
}
