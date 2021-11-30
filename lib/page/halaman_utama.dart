import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_version/new_version.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/day_converter.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/helper/toastNotification.dart';
import 'package:sobatku/model/jadwal_dokter.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/model/spesialisasi.dart';
import 'package:sobatku/page/dummy_card.dart';
import 'package:sobatku/page/profile.dart';
import 'package:sobatku/page/sign_in.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/spesialisasi_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sobatku/service/user_service.dart';
import 'aktivitas.dart';
import 'dashboard.dart';
import 'jadwal_dokter.dart';
import 'package:firebase_core/firebase_core.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<MyApp> {
  final newVersion = NewVersion(
    iOSId: 'com.droensoba.sobatku',
    /** Ambil di android manifest **/
    androidId: 'com.droensoba.sobatku',
  );

  /// DropDown Value
  List<DropdownMenuItem<String>> itemList = [];
  String dropdownvalue = "-PILIH SPESIALISASI-";
  /// Kalender Value
  final txtController = TextEditingController();
  var now = DateTime.now();
  late DateTime datePicked;
  late String dayInNumber, datePickedFormatted;
  /// Service
  late UserService userService;
  late PasienService pasienService;
  late SpesialisasiService spesialisasiService;
  late JadwalService jadwalService;

  late String kodeSpesialisasi;
  late List<Spesialisasi> daftarSpesialisasi;
  int _currentIndex = 0;
  late List<String> user;

  final List<Widget> _children = [
    HomeView(),
    DummyCard(),
    HomeView(),
    Aktivitas(),
    SignIn(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    /** CEK VERSI PADA PLAYSTORE **/
    newVersion.showAlertIfNecessary(context: context);
    /** Inisialisasi Service **/
    jadwalService = JadwalService();
    spesialisasiService = SpesialisasiService();
    pasienService = PasienService();
    userService = UserService();

    /** Convert Data Ke DropdownMenuItem **/
    spesialisasiService.getSpesialisasi().then((value) {
      setState(() {
        daftarSpesialisasi = value;
        value.forEach((element) {
          itemList.add(DropdownMenuItem(
              child: Text(element.namaSpesialisasi),
              value: element.namaSpesialisasi)
          );
        });
      });
    });

    /** Cek Apakah User Sudah Login **/
    SharedPreferenceHelper.checkUserExist().then((isUserExist) async {
      if(isUserExist == true) {
        SharedPreferenceHelper.getUser().then((userData) {
          setState(() {
            user = userData!;
            _children[4] = Profile();
            /** AMBIL DATA PAIRING PASIEN DENGAN USER DI TABEL PAIRING **/
            pasienService.getPairing(user[2]).then((value) {
              value.forEach((pasien) {
                /** TAMBAH DATA TIAP PASIEN KE FIREBASE **/
                _saveToFirebase(user[2], pasien);
              });
            });
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      resizeToAvoidBottomInset: false,
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Constant.color,
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(label: "Beranda", icon: new Icon(Icons.home)),
          BottomNavigationBarItem(label: "Kartu RM", icon: new Icon(Icons.credit_card)),
          BottomNavigationBarItem(label: "", icon: new Icon(Icons.task, color:  Constant.color)),
          BottomNavigationBarItem(label: "Aktivitas", icon: new Icon(Icons.list_alt)),
          BottomNavigationBarItem(label: "Profil", icon: new Icon(Icons.person))
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: 20),
        child: SizedBox(
          height: 86,
          width: 86,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(width: 5.0, color: Colors.white),
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
                primary:  Constant.color,
              ),
              onPressed: () {showSearchDialog();},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/icons/Daftar_Periksa.png", scale: 1.5),
                ],
              )
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void onTabTapped(int index) {
    if(index!=2) {
      setState(() {_currentIndex = index;});
    }
    if(index !=0 && index !=1) {
      SharedPreferenceHelper.checkUserExist().then((value){
        if(value == false)
          _currentIndex = 4;
        else if(value == true)
          _currentIndex = index;
      });
    }
  }

  Future<void> showSearchDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            contentPadding: EdgeInsets.only(top: 10.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            children: [
              StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return Column (
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Pilih Tanggal & Poli",
                          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(color: Constant.color),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: SearchableDropdown.single(
                              items: itemList,
                              displayClearIcon: false,
                              isCaseSensitiveSearch: false,
                              value: dropdownvalue,
                              hint: "Pilih Spesialisasi",
                              searchHint: "Pilih Spesialisasi",
                              onChanged: (value) {
                                setState(() {
                                  dropdownvalue = value;
                                  daftarSpesialisasi.forEach((spesialisasi) {
                                    if(spesialisasi.namaSpesialisasi == dropdownvalue)
                                      kodeSpesialisasi = spesialisasi.kodeSpesialisasi;
                                  });
                                });
                              },
                              isExpanded: true,
                            )
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                              child: InkWell(
                                onTap: (){showCalendar(context);},
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Pilih Tanggal',
                                  ),
                                  enabled: false,
                                  controller: txtController,
                                ),
                              ),
                            )
                        ),
                        IconButton(
                            onPressed: (){showCalendar(context);},
                            icon: Icon(Icons.calendar_today_outlined))
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap:() async {
                              List<JadwalDokter>  data = await jadwalService.getJadwalDokter(kodeSpesialisasi.toString(), dayInNumber);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JadwalSpesifik(dataJadwalDokter: data, tanggalDipilih: datePicked, listSpesialisasi: daftarSpesialisasi, idSpesialisasi: kodeSpesialisasi, namaSpesialisasi: dropdownvalue),
                                  )
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                              decoration: BoxDecoration(
                                color:  Constant.color,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Text(
                                "Cari",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                );
              }
              ),
            ]
        );
      },
    );
  }

  showCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        cancelText: "Batal",
        confirmText: "OK",
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 7)));
    if(picked != null && picked != now) {
      setState(() {
        datePicked = picked;
        txtController.text = DateFormat('dd-MM-yyyy').format(picked);
        datePickedFormatted = DateFormat('dd-MM-yyyy').format(picked);
        dayInNumber = DayConverter.convertToNumber(DateFormat('EEEE').format(picked)).toString();
      });
    }
  }

  _saveToFirebase(String idUser, Pasien pasien) async {
    await Firebase.initializeApp();
    FirebaseMessaging _fcm = FirebaseMessaging.instance;
    String? fcmToken = await _fcm.getToken();
    userService.saveToFirebase(idUser, pasien, fcmToken.toString());
  }
}


// _saveToFirebase(String idUser, Pasien pasien) async {
//   await Firebase.initializeApp();
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   /** HAPUS SEMUA PASIEN PADA ID USER TERSEBUT UNTUK MENGHINDARI DUPLIKAT DATA & UPDATE DEVICE TOKEN**/
//   var collection = await _db.collection("user").doc(idUser).collection("pasien").get();
//   for(var doc in collection.docs) {
//     doc.reference.delete();
//   }
//
//   /** TAMBAH SEMUA PASIEN PADA ID USER TERSEBUT **/
//   String? fcmToken = await _fcm.getToken();
//
//   if(fcmToken != null) {
//
//     var tokenRef = _db
//         .collection('user')
//         .doc(idUser)
//         .collection('pasien')
//         .doc(pasien.namaPasien);
//
//     await tokenRef.set({
//       'token' : fcmToken,
//       'no_rm'  : pasien.nomorRm,
//       'createAt' : FieldValue.serverTimestamp(),
//     });
//
//     await _db.collection("user").doc(idUser).set({
//       'createAt' : FieldValue.serverTimestamp(),
//     });
//   }
// }
