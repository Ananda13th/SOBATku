// @dart=2.9

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/page/aktivitas.dart';
import 'package:sobatku/page/dashboard.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:sobatku/page/jadwal_dokter.dart';
import 'package:sobatku/page/profile.dart';
import 'package:sobatku/page/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/spesialisasi_service.dart';
import 'helper/day_converter.dart';
import 'helper/local_notification.dart';
import 'model/jadwal_dokter.dart';
import 'model/pasien.dart';
import 'model/spesialisasi.dart';
import 'package:android_autostart/android_autostart.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  messageHandler();
  // initAutoStart();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ); // To turn off landscape mode
  runApp(App());
}

class App extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'SobatKu',
      theme: ThemeData(
          primaryColor: Constant.color,
          accentColor: Constant.color,
          buttonColor: Constant.color,
      ),
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new MyApp()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroScreen()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: CircularProgressIndicator()
      ),
    );
  }
}

/*------------ Bottom Navigation & Main Screen ------------*/

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<MyApp> {

  //DropDown Value
  List<DropdownMenuItem<String>> itemList = [];
  String dropdownvalue = "-PILIH SPESIALISASI-";
  //Kalender Value
  final txtController = TextEditingController();
  var now = DateTime.now();
  DateTime datePicked;
  String dayInNumber, datePickedFormatted;
  //Service
  PasienService pasienService;
  SpesialisasiService spesialisasiService;
  JadwalService jadwalService;
  
  int idSpesialisasi;
  List<Spesialisasi> daftarSpesialisasi;
  int _currentIndex = 0;
  List<String> user;

  final List<Widget> _children = [
    HomeView(),
    HomeView(),
    HomeView(),
    Aktivitas(),
    SignIn(),
  ];

  @override
  void initState() {

    super.initState();
    //Inisialisasi Service
    jadwalService = JadwalService();
    spesialisasiService = SpesialisasiService();
    pasienService = PasienService();

    //Convert Data Ke DropdownMenuItem
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

    //Cek Apakah User Sudah Login
    SharedPreferenceHelper.checkUserExist().then((value) {
      if(value == true) {
        SharedPreferenceHelper.getUser().then((value) {
          setState(() {
            user = value;
            _children[4] = Profile();
            pasienService.getPairing(user[2]).then((value) {
              value.forEach((element) {
                  _saveToFirebase(user[2], element);
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
          BottomNavigationBarItem(label: "Utama", icon: new Icon(Icons.home)),
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
    if(index == 1) {
      showToast(
        "Maaf, Fitur Belum Tersedia",
        context: context,
        textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
        backgroundColor: Constant.color,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: StyledToastPosition.center,
        animDuration: Duration(seconds: 1),
        duration: Duration(seconds: 4),
        curve: Curves.elasticOut,
        reverseCurve: Curves.linear,
      );
    }
    if(index!=2) {
      setState(() {_currentIndex = index;});
    }
    if(index !=0) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                    idSpesialisasi = spesialisasi.idSpesialisasi;
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
                                List<JadwalDokter>  data = await jadwalService.getJadwalDokter(idSpesialisasi.toString(), dayInNumber);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScheduleView(data: data, date: datePicked, listSpesialisasi: daftarSpesialisasi, idSpesialisasi: idSpesialisasi, namaSpesialisasi: dropdownvalue),
                                  )
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                                decoration: BoxDecoration(
                                  color:  Constant.color,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20.0),
                                      bottomRight: Radius.circular(20.0)),
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
    final DateTime picked = await showDatePicker(
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
}

/*------------ Tampilan Intro ------------*/

class IntroScreen extends StatelessWidget {
  final List<String> images = ["assets/images/Akun Dr Oen 1.png","assets/images/Akun Dr Oen 2.png","assets/images/Akun Dr Oen 3.png","assets/images/Akun Dr Oen 4.png"];
  @override
  Widget build(BuildContext context) {
    double _left = MediaQuery.of(context).size.width/2-90;
    double _top = MediaQuery.of(context).size.height/2+150;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: new Swiper(
              loop: false,
              itemCount: images.length,
              pagination: new SwiperPagination(),
              itemBuilder: (BuildContext context, int index) {
                if(index == 3) {
                  return Container(
                    decoration: BoxDecoration(image:
                    DecorationImage(
                        image: AssetImage(images[index]),
                        alignment: Alignment.center,
                        fit: BoxFit.cover)),
                    child: Stack(
                        children: [
                          Positioned(
                            left: _left,
                            top: _top,
                            child: Center(
                              child: MaterialButton(
                                textColor: Colors.white,
                                elevation: 8.0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color:  Constant.color
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("LANJUT KE APLIKASI"),
                                    ),
                                  ),
                                ),
                                // ),
                                onPressed: () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new MyApp()));
                                },
                              ),
                            ),
                          ),
                        ]
                    ),
                  );
                }
                return new Image.asset(
                  images[index],
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                );
              },
            )
        )
      ),
    );
  }
}

/*------------ Fungsi Firebase ------------*/

_saveToFirebase(String idUser, Pasien pasien) async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  // Delete Semua Pasien Dahulu Agar Tidak Tertimpa Dengan Pasien Lama Yang Sudah Dihapus
  var collection = await _db.collection("user").doc(idUser).collection("pasien").get();
  for(var doc in collection.docs) {
    doc.reference.delete();
  }

  //Insert Data Pasien Baru
  String fcmToken = await _fcm.getToken();

  if(fcmToken != null) {

    var tokenRef = _db
        .collection('user')
        .doc(idUser)
        .collection('pasien')
        .doc(pasien.namaPasien);

    await tokenRef.set({
      'token' : fcmToken,
      'no_rm'  : pasien.nomorRm,
      'createAt' : FieldValue.serverTimestamp(),
    });

    await _db.collection("user").doc(idUser).set({
      'createAt' : FieldValue.serverTimestamp(),
    });
  }
}

Future<void> messageHandler() async {

  await Firebase.initializeApp();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    LocalNotification.showNotification(event);
  });

}

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

/*------------ Ambil Informasi Perangkat ------------*/

getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print(androidInfo.manufacturer);
  return androidInfo.manufacturer;
}

/*------------ Ambil Informasi Perangkat ------------*/

Future<void> initAutoStart() async {
  try {
    //check auto-start availability.
    var test = await isAutoStartAvailable;
    print(test);
    //if available then navigate to auto-start setting page.
    if (test) await getAutoStartPermission();
  } on PlatformException catch (e) {
    print(e);
  }
}

















