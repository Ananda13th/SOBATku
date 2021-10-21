import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/day_converter.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/model/dokter.dart';
import 'package:sobatku/model/dokter_favorit.dart';
import 'package:sobatku/model/jadwal_dokter.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/model/transaksi_req.dart';
import 'package:sobatku/page/sign_in.dart';
import 'package:sobatku/service/cuti_service.dart';
import 'package:sobatku/service/dokter_favorit_service.dart';
import 'package:sobatku/service/dokter_service.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:group_button/group_button.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/transaksi_service.dart';

class DoctorList extends StatefulWidget {
  @override
  State createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  List<String> listDokterFavorit =[""];
  late DokterService doctorService;
  late JadwalService jadwalService;
  late DokterFavoritService dokterFavoritService;
  late PasienService pasienService;
  late TransaksiService transaksiService;
  late CutiService cutiService;
  TextEditingController _searchController = TextEditingController();
  late List<Dokter> daftarDokter;
  late List<Dokter> tempDaftarDokter;
  Future<List<Dokter>>? _dokterData;
  late bool user =false;
  String idUser = "";
  int selectedIndex = 11;


  @override
  void initState() {
    super.initState();
    doctorService = DokterService();
    pasienService = PasienService();
    jadwalService = JadwalService();
    cutiService = CutiService();
    dokterFavoritService = DokterFavoritService();
    transaksiService = TransaksiService();
    _dokterData = doctorService.getDokter();
    checkUserExist().then((value) {
      if (value) {
        getFavorit();
        setState(() {
          _dokterData!.then((value) {
            setState(() {
              daftarDokter = value;
              tempDaftarDokter = List.from(daftarDokter);
            });
          });
          user = value;
          SharedPreferenceHelper.getUser().then((value) {
            idUser = value![2];
          });
        });
      }
      else {
        _dokterData!.then((value) {
          setState(() {
            daftarDokter = value;
            tempDaftarDokter = List.from(daftarDokter);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Daftar Dokter"),
          backgroundColor: Constant.color,
        ),
        body:
        Container(
          decoration: BoxDecoration(image:
          DecorationImage(
              image: AssetImage("assets/images/Background.png"),
              alignment: Alignment.center,
              fit: BoxFit.fill)),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<List<Dokter>>(
            future: _dokterData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError) {
                return Center(
                  child: Text("Terjadi Kesalahan"),
                );
              }
              else if (snapshot.hasData){
                return _buildListDokter(tempDaftarDokter);
              }
              else {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/loading.gif"),
                          alignment: Alignment.center,
                          fit: BoxFit.scaleDown
                      )
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  /*------------ Fungsi Tampil List Dokter ------------*/

  Widget _buildListDokter(List<Dokter> doctors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Dokter...',
              ),
              onChanged: onCariDokter,
            ),
          )
        ),
        Container(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height*80/100,
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.grey[400]),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              Dokter dokter = doctors[index];
              return Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset("assets/images/profileAvatar.png"),
                    ),
                  ),
                  Flexible(
                      child: SizedBox(
                        child: InkWell(
                          child: ListTile(
                            trailing: user? IconButton(
                              onPressed: (){
                                if(listDokterFavorit.contains(dokter.idDokter.toString())) {
                                  setState(() {
                                    dokterFavoritService.deleteDokterFavorit(int.parse(idUser), dokter.idDokter);
                                    listDokterFavorit.remove(dokter.idDokter.toString());
                                    SharedPreferenceHelper.addFavorite(listDokterFavorit);
                                  });
                                }
                                else {
                                  DokterFavorit dokterFavorit = DokterFavorit(idDokter: dokter.idDokter, idUser: int.parse(idUser));
                                  setState(() {
                                    dokterFavoritService.addDokterFavorit(dokterFavorit);
                                    listDokterFavorit.add(dokter.idDokter.toString());
                                    SharedPreferenceHelper.addFavorite(listDokterFavorit);
                                  });
                                }
                              },
                              icon: Icon(
                                  Icons.favorite,
                                  color: listDokterFavorit.contains(dokter.idDokter.toString()) ? Colors.red : Colors.grey,
                              )
                            ) : Icon(Icons.favorite),
                            title: Text(dokter.namaDokter, style: TextStyle(fontSize: 20)),
                            subtitle: Text(dokter.spesialisasi, style: TextStyle(fontSize: 16)),
                        ),
                          onTap: (){_buildDetailDokterDialog(context, jadwalService, dokter);},
                      ),
                    )
                  )
                ],
              );
            }
          ),
        )
      ],
    );
  }

  /*------------ Fungsi Search Dokter ------------*/

  onCariDokter(String value) {
    setState(() {
      tempDaftarDokter = daftarDokter.where((element) => element.namaDokter.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  /*------------ Menampilkan Detail Dokter ------------*/

  Future<void> _buildDetailDokterDialog(BuildContext context, JadwalService scheduleService, Dokter dokter) async {
    await showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 150,
                  width: 150,
                  child: Image.asset("assets/images/profileAvatar.png"),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      color: Constant.color,
                      child: Center(
                        child: Text(
                            dokter.namaDokter,
                            style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 24)
                        )
                      )
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(dokter.spesialisasi, style:TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              Text("Jadwal Praktek", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              FutureBuilder<List<JadwalDokter>>(
                future: scheduleService.getJadwalDokterById(dokter.kodeDokter),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.hasData){
                    List<JadwalDokter> schedules = snapshot.data;
                    if(schedules.length == 0) {
                      return Center(
                        child: Container(
                          width: 300,
                          height: MediaQuery.of(context).size.height*45/100,
                          child: Center(child: Text("Belum Ada Jadwal"))
                        )
                      );
                    }
                    return _buildListJadwal(schedules);
                  } else {
                    return Center(
                      child: Container(
                        width: 300,
                        height: 290,
                        child: Center(child: Text("Terjadi Kesalahan"))
                      )
                    );
                  }
                }
              ),
            ],
          ),
        );
      },
    );
  }

  /*------------ Menampilkan Jadwal Dokter ------------*/

  Widget _buildListJadwal(List<JadwalDokter> jadwalDokter) {
   return SingleChildScrollView(
     child: Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height*45/100,
          width: 300,
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.grey[400]),
            itemCount: jadwalDokter.length,
            itemBuilder: (context, index) {
              JadwalDokter jadwal = jadwalDokter[index];
              return Column(
                children: [
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: SizedBox(
                          child: ListTile(
                            title: Center(
                              child: Text(
                                DayConverter.convertToDay(jadwal.hari),
                                style: TextStyle(fontWeight: FontWeight.bold)
                              )
                            ),
                          ),
                        )
                      )
                    ],
                  ),
                  _buttonView(jadwal, context)
                ],
              );
            }
          ),
        ),
      ],
    ),
   );
  }

  Widget _buttonView (JadwalDokter schedule, BuildContext context) {
    List<String> value = [];
    value = schedule.jadwalPraktek.map((e) => e.jam).toList();
    if(user) {
      return GroupButton(
        selectedColor: Constant.color,
        selectedTextStyle:TextStyle(color: Colors.white),
        spacing: 10,
        direction: Axis.horizontal,
        unselectedColor: Colors.lightGreen[300],
        borderRadius: BorderRadius.circular(30),
        isRadio: true,
        buttons: value,
        onSelected: (int index, bool isSelected) {_buildPasienListDialog(context, schedule, schedule.jadwalPraktek[index].jam);},
      );
    } else {
      return GroupButton(
        selectedColor: Colors.grey[300],
        selectedTextStyle: TextStyle(color: Colors.black),
        spacing: 10,
        direction: Axis.horizontal,
        unselectedColor: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
        isRadio: true,
        buttons: value,
        onSelected: (int index, bool isSelected) {_buildAlert(context);},
      );
    }
  }

  /*------------ Fungsi Shared Preference Ambil Data User ------------*/

  Future<bool> checkUserExist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? _user = prefs.getBool('userExist');
    if(_user == true)
      return true;
    else
      return false;
  }

  Future<String> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? _user = prefs.getStringList("user");
    return _user![2];
  }

  /*------------ Alert Bila Belum Login ------------*/

  Future<void> _buildAlert(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Center(child: const Text('Harap Masuk Dahulu')),
          children: <Widget>[
              Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: (){ Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => new SignIn()));},
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Constant.color)),
                            child: Center(child: const Text('MASUK', style: TextStyle(fontWeight: FontWeight.bold)))
                          ),
                        )
                      )
                    ],
                  ),
                ],
              )
          ],
        );
      },
    );
  }

  /*------------ Menampilkan Pasien Dan Metode Pembayaran Sebelum Daftar ------------*/

  Future<void> _buildPasienListDialog(BuildContext context, JadwalDokter jadwalDokter, String jam) async {
    final now = DateTime.now();
    List<String> data = ["Asuransi", "Umum", "BPJS"];
    List<String> value = ["2", "3", "9"];
    String kodeJadwal = "";
    String tipe = "";
    String noRm = "";
    bool cuti = false;
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
    List dayList = List.generate(15, (index) => index)
        .map((value) => DateFormat('dd')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();
    if(jadwalDokter.hari < now.weekday) {
      kodeJadwal = jadwalDokter.kodeDokter + "." + DateFormat('yyMM').format(now) + dayList[jadwalDokter.hari + 7] + jam.substring(0, 2);
    }
    else {
      kodeJadwal = jadwalDokter.kodeDokter + "." + DateFormat('yyMM').format(now) + dayList[jadwalDokter.hari] + jam.substring(0, 2);
    }
    print("Kode Jadwal : "+kodeJadwal);

    await cutiService.cekCuti(kodeJadwal).then((value) {
      cuti = value;
    });

    if(cuti == true) {
      showToast("Maaf, Dokter Sedang Cuti",
          context: context,
          textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
          backgroundColor: Colors.red,
          animation: StyledToastAnimation.scale,
          reverseAnimation: StyledToastAnimation.fade,
          position: StyledToastPosition.center,
          animDuration: Duration(seconds: 1),
          duration: Duration(seconds: 4),
          curve: Curves.elasticOut,
          reverseCurve: Curves.linear);
    }
    else
    if (user) {
      SharedPreferenceHelper.getUser().then((value) {
        setState(() {
          idUser = value![2];
        });
      });
      await showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content:
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                color: Constant.color,
                                child: Center(
                                  child: Text("Pilih Pasien",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        FutureBuilder(
                          future: pasienService.getPairing(idUser),
                          builder: (BuildContext context,
                              AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text("Error"),
                              );
                            }
                            else if (snapshot.hasData) {
                              List<Pasien> patients = snapshot.data;
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                height: 180,
                                child: ListView.separated(
                                    separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.black, thickness: 1, height: 5),
                                    itemCount: patients.length,
                                    itemBuilder: (context, index) {
                                      Pasien patient = patients[index];
                                      return Row(
                                        children: <Widget>[
                                          Flexible(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedIndex = index;
                                                  noRm = patient.nomorRm;
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                child: ListTile(
                                                  title: Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                                    child: Center(
                                                      child: Text(
                                                        patient.namaPasien,
                                                        style: TextStyle(
                                                          color:  selectedIndex == index ? Constant.color : Colors.black,
                                                          fontWeight: FontWeight.bold
                                                        )
                                                      )
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          )
                                        ],
                                      );
                                    }
                                ),
                              );
                            }
                            else {
                              return Center(
                                child: Container(),
                              );
                            }
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                color: Constant.color,
                                child: Center(
                                  child: Text("Pilih Pembayaran",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: 10
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 80,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: GroupButton(
                                      selectedColor: Constant.color,
                                      selectedTextStyle: TextStyle(
                                          color: Colors.white),
                                      spacing: 10,
                                      direction: Axis.horizontal,
                                      unselectedColor: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(30),
                                      isRadio: true,
                                      buttons: data,
                                      onSelected: (int index, bool isSelected) {
                                        tipe = value[index];
                                      }
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                            height: 10
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<
                                            Color>(Constant.color)),
                                    onPressed: () {
                                      print(kodeJadwal);
                                      TransaksiReq transaksi = new TransaksiReq(
                                          kodeJadwal: kodeJadwal,
                                          kodeDokter: jadwalDokter.kodeDokter,
                                          nomorRm: noRm,
                                          tipe: tipe);
                                      transaksiService.createTransaksi(
                                          transaksi, idUser).then(
                                              (value) {
                                            Color color = Constant.color;
                                            if (value != "Antrian berhasil dibuat.")
                                              color = Colors.red;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                SnackBar(
                                                    duration: Duration(seconds: 2),
                                                    backgroundColor: color,
                                                    content: Text(value,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors.white))
                                                )
                                            );
                                            Future.delayed(
                                                Duration(seconds: 3), () {
                                              // 5 seconds over, navigate to Page2.
                                              Navigator.pop(context);
                                            });
                                          }
                                      );
                                    },
                                    child: Text("Daftar")),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<
                                            Color>(Colors.grey)),
                                    onPressed: () {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      } else {
                                        SystemNavigator.pop();
                                      }
                                    },
                                    child: Text("Batal", style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                );
              }
              )
          );
        },
      );
    }
  }

  /*------------ Ambil Daftar Dokter Favorit ------------*/

  getFavorit() async {
    await SharedPreferenceHelper.getUser().then((value) {
      idUser = value![2];
    });
    dokterFavoritService.getDokterfavorit(idUser).then((value){
      value.forEach((element) {
        setState(() {
          listDokterFavorit.add(element.idDokter.toString());
          SharedPreferenceHelper.addFavorite(listDokterFavorit);
        });
      });
    });
  }

}

