import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/day_converter.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/model/dokter.dart';
import 'package:sobatku/model/jadwal_dokter.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/model/transaksi_req.dart';
import 'package:sobatku/page/sign_in.dart';
import 'package:sobatku/service/dokter_favorit_service.dart';
import 'package:sobatku/service/dokter_service.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:group_button/group_button.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/transaksi_service.dart';

class FavoriteList extends StatefulWidget {
  @override
  State createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  List<String> favorite =[""];
  late DokterService doctorService;
  late JadwalService jadwalService;
  late PasienService pasienService;
  late DokterFavoritService dokterFavoritService;
  late TransaksiService transaksiService;
  TextEditingController _searchController = TextEditingController();
  late List<Dokter> doctors;
  late List<Dokter> tempDoctorData;
  Future<List<Dokter>>? _doctorData;
  late bool user =false;
  late String idUser;
  int selectedIndex = 11;

  @override
  void initState() {
    super.initState();

    doctorService = DokterService();
    pasienService = PasienService();
    jadwalService = JadwalService();
    transaksiService = TransaksiService();
    _doctorData = doctorService.getDokter();
    _doctorData!.then((value) {
      setState(() {
        doctors = value;
        tempDoctorData = List.from(doctors);
      });
    });

    checkUserExist().then((value) {
      setState(() {
        user = value;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    if(user)
      SharedPreferenceHelper.getFavorite().then((value) {
        setState(() {
            favorite = value!;
        });
      });
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Daftar Dokter Favorit"),
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
            future: _doctorData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError) {
                return Center(
                  child: Text("Terjadi Kesalahan"),
                );
              }
              else if (snapshot.hasData){
                return _buildListDokter(tempDoctorData);
              }
              else {
                return Center(
                  child: Container(),
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
        Container(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height*80/100,
          child: ListView.separated(
              separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.grey[400]),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                Dokter doctor = doctors[index];
                if(favorite.contains(doctor.idDokter.toString()))
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
                                title: Text(doctor.namaDokter, style: TextStyle(fontSize: 20)),
                                subtitle: Text(doctor.spesialisasi, style: TextStyle(fontSize: 16)),
                              ),
                              onTap: (){_buildDetailDokterDialog(context, jadwalService, doctor);},
                            ),
                          )
                      )
                    ],
                  );
                else
                  return Container();
              }
          ),
        )
      ],
    );
  }

  /*------------ Menampilkan Detail Dokter ------------*/

  Future<void> _buildDetailDokterDialog(BuildContext context, JadwalService scheduleService, Dokter dokter) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                  height: 140,
                                  color: Constant.color,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Text(
                                          dokter.namaDokter,
                                          style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 24)
                                      ),
                                    ),
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
                            future: scheduleService.getJadwalDokterById(dokter.idDokter),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if(snapshot.hasData){
                                List<JadwalDokter> schedules = snapshot.data;
                                if(schedules.length == 0) {
                                  return Center(
                                      child: Container(
                                          width: 300,
                                          height: MediaQuery.of(context).size.height*50/100,
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
                  ]
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 150,
                width: 150,
                child: Image.asset("assets/images/profileAvatar.png"),
              ),
            ),
        ]
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
            height: MediaQuery.of(context).size.height*50/100,
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
        unselectedColor: Colors.lightGreen,
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
                              child: Center(child: const Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold)))
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
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
    List dayList = List.generate(15, (index) => index)
        .map((value) => DateFormat('dd')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();
    if(jadwalDokter.hari < now.weekday)
      kodeJadwal = jadwalDokter.kodeDokter + "." + DateFormat('yyMM').format(now) + dayList[jadwalDokter.hari+7] + jam.substring(0,2);
    else
      kodeJadwal = jadwalDokter.kodeDokter + "." + DateFormat('yyMM').format(now) + dayList[jadwalDokter.hari] + jam.substring(0,2);
    String noRm = "";
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
                                width: 200,
                                height: 200,
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
                                                  width: 200,
                                                  child: ListTile(
                                                    title: Padding(
                                                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                                      child: Center(
                                                          child: Text(
                                                            patient.namaPasien,
                                                            style: TextStyle(
                                                                color:  selectedIndex == index ? Constant.color : Colors.black,
                                                                fontWeight: FontWeight.bold
                                                            ),)
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
}

