import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/day_converter.dart';
import 'package:sobatku/helper/loginAlert.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/helper/toastNotification.dart';
import 'package:sobatku/model/dokter.dart';
import 'package:sobatku/model/dokter_favorit.dart';
import 'package:sobatku/model/jadwal_dokter.dart';
import 'package:sobatku/model/spesialisasi.dart';
import 'package:sobatku/service/cuti_service.dart';
import 'package:sobatku/service/dokter_favorit_service.dart';
import 'package:sobatku/service/dokter_service.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:group_button/group_button.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/spesialisasi_service.dart';
import 'package:sobatku/service/transaksi_service.dart';

import 'jadwal_dokter.dart';

class DaftarDokter extends StatefulWidget {
  @override
  State createState() => _DaftarDokterState();
}

class _DaftarDokterState extends State<DaftarDokter> {
 
  late DokterService doctorService;
  late JadwalService jadwalService;
  late DokterFavoritService dokterFavoritService;
  late PasienService pasienService;
  late TransaksiService transaksiService;
  late CutiService cutiService;
  late SpesialisasiService spesialisasiService;
  TextEditingController _searchController = TextEditingController();
  List<Dokter> daftarDokter = List.empty(growable: true);
  List<String> listDokterFavorit = List.empty(growable: true);
  List<Dokter> tempDaftarDokter = List.empty(growable: true);
  List<Spesialisasi> daftarSpesialisasi = List.empty(growable: true);
  Future<List<Dokter>>? _dokterData;
  late bool user =false;
  String idUser = "";
  int selectedIndex = 11;

  @override
  void initState() {
    super.initState();
    /// INISIALISASI SERVICE ///
    doctorService = DokterService();
    pasienService = PasienService();
    jadwalService = JadwalService();
    spesialisasiService = SpesialisasiService();
    cutiService = CutiService();
    dokterFavoritService = DokterFavoritService();
    transaksiService = TransaksiService();
    _dokterData = doctorService.getDokter();
    spesialisasiService.getSpesialisasi().then((value) {
      setState(() {
        daftarSpesialisasi= value;
      });
    });

    /// CEK BILA USER SUDAH PERNAH LOGIN ///
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
    precacheImage(AssetImage("assets/images/error_picture.jpg"), context);
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
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Background.png"),
              alignment: Alignment.center,
              fit: BoxFit.fill
            )
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<bool>(
            future: checkConnectivity(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasData) {
                if(snapshot.data == true)
                  return _buildListDokter(tempDaftarDokter);
                else
                  return Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/error_picture.jpg",
                          fit: BoxFit.contain),
                          Text("Maaf, Terjadi Kesalahan", style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 26)),
                          Text("*Harap Cek Koneksi Internet Anda", style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  );
              }
              return Container();
            }
          )
        ),
      ),
    );
  }

  /// ------------ Fungsi Tampil List Dokter ------------ ///

  Widget _buildListDokter(List<Dokter> daftarDokter) {
    if(daftarDokter.isEmpty)
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
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Container(
              color: Constant.color,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: _searchController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.all(0),
                    isDense: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Cari Dokter/Spesialisasi...'
                  ),
                  onChanged: onCariDokter,
                ),
              ),
            )
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.transparent,
            height: MediaQuery.of(context).size.height*80/100,
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.transparent),
              itemCount: daftarDokter.length,
              itemBuilder: (context, index) {
                Dokter dokter = daftarDokter[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    height: 100,
                    decoration:  BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 4,
                          offset: Offset(4, 8), // Shadow position
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: CachedNetworkImage(
                              imageUrl: dokter.foto,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                    backgroundImage: imageProvider,
                                  ),
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                        color : Constant.color
                                    ),
                                  ),
                              errorWidget: (context, url, error) =>   Image.asset("assets/images/profileAvatar.png"),
                            )
                          ),
                        ),
                        Flexible(
                            child: SizedBox(
                              child: InkWell(
                                child: ListTile(
                                  trailing: user? IconButton(
                                    onPressed: () {
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
                                  title: Text(dokter.namaDokter, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  subtitle: Text(dokter.spesialisasi, style: TextStyle(fontSize: 16)),
                              ),
                              onTap: () async {
                                  List<JadwalDokter> listJadwalDokter = await cekCuti(dokter);
                                  _buildDetailDokterDialog(context, jadwalService, listJadwalDokter, dokter);
                              },
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                );
              }
            ),
          )
        ],
      );
  }

  /// ------------ Fungsi Search Dokter ------------ ///

  onCariDokter(String value) {
    setState(() {
      tempDaftarDokter = daftarDokter.where((element) => element.namaDokter.toLowerCase().contains(value.toLowerCase()) || element.spesialisasi.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  /// ------------ Menampilkan Detail Dokter ------------ ///

  Future<void> _buildDetailDokterDialog(BuildContext context, JadwalService scheduleService, List<JadwalDokter> listJadwalDokter, Dokter dokter) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return  AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 150,
                      width: 150,
                      child: CachedNetworkImage(
                        imageUrl: dokter.foto,
                        imageBuilder: (context, imageProvider) =>
                            CircleAvatar(
                              backgroundImage: imageProvider,
                            ),
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color : Constant.color
                              ),
                            ),
                        errorWidget: (context, url, error) =>   Image.asset("assets/images/profileAvatar.png"),
                      )
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          color: Constant.color,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Text(
                                  dokter.namaDokter,
                                  style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 16),
                                  textAlign: TextAlign.center,
                              ),
                            )
                          )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(dokter.spesialisasi, style:TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Divider(
                    color: Colors.black,
                    thickness: 2,
                  ),
                  Text("Jadwal Praktek", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Divider(
                    color: Colors.black,
                    thickness: 2,
                  ),
                  Flexible(
                    child: FutureBuilder<List<JadwalDokter>>(
                      future: scheduleService.getJadwalDokterById(dokter.kodeDokter),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if(snapshot.hasError) {
                          return Container(
                            width: 300,
                            height: 290,
                            child: Center(child: Text("Terjadi Kesalahan")),
                          );
                        }
                        if(snapshot.hasData){
                          if(listJadwalDokter.isEmpty)
                            return Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 300,
                                child: Column(
                                  children: [
                                    Expanded(
                                        child: Center(child: Text("Belum Ada Jadwal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                              child: ElevatedButton(
                                                  onPressed: () { Navigator.pop(context); },
                                                  child: Text("Tutup"),
                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Constant.color))
                                              ),
                                            )
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          else
                            return _buildListJadwal(listJadwalDokter, dokter);
                        } else {
                          return Container(
                            width: 300,
                            height: 290,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Constant.color,
                              )
                            ),
                          );
                        }
                      }
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  /// ------------ Menampilkan Jadwal Dokter ------------ ///

  Widget _buildListJadwal(List<JadwalDokter> jadwalDokter, Dokter dokter) {
    String tanggal = "";
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
    List dayList = List.generate(15, (index) => index)
        .map((value) => DateFormat('yyyy-MM-dd')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();

    List listTanggalFormatTampil = List.generate(15, (index) => index)
        .map((value) => DateFormat('dd MMMM yyyy')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();

   return RawScrollbar(
     thumbColor: Constant.color,
     isAlwaysShown: true,
     thickness: 10,
     child: Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height*44/100,
          width: 300,
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.grey[400]),
            itemCount: jadwalDokter.length,
            itemBuilder: (context, index) {
              JadwalDokter jadwal = jadwalDokter[index];
              if(jadwal.hari < now.weekday)
                tanggal = dayList[jadwal.hari + 7];
              else
                tanggal = dayList[jadwal.hari];
              return Column(
                children: [
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          height : 35,
                          child: ListTile(
                            title: Center(
                              child: Column(
                                children: [
                                  Text(
                                    jadwal.hari < now.weekday ?  DayConverter.convertToDay(jadwal.hari) + ", "+  listTanggalFormatTampil[jadwal.hari + 7] :   DayConverter.convertToDay(jadwal.hari) + ", "+  listTanggalFormatTampil[jadwal.hari],
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                ],
                              )
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  _buttonView(jadwal, tanggal, dokter, context),
                ],
              );
            }
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); },
                  child: Text("Tutup"),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Constant.color))
                ),
              )
            )
          ],
        )
      ],
    ),
   );
  }

  Widget _buttonView (JadwalDokter jadwalDokter, String tanggal, Dokter dokter, BuildContext context) {
    List<String> value = [];
    var indexCuti = List<int>.empty(growable: true);
    value = jadwalDokter.jadwalPraktek.map((e) => e.jam).toList();

    for(int i = 0; i<value.length; i++) {
      if(value[i].contains("Cuti"))
        indexCuti.add(i);
    }

    if(user) {
      return GroupButton(
        textAlign: TextAlign.center,
        selectedColor: Constant.color,
        disabledButtons: indexCuti,
        selectedTextStyle:TextStyle(color: Colors.white),
        spacing: 10,
        direction: Axis.horizontal,
        unselectedColor: Colors.lightGreen[300],
        borderRadius: BorderRadius.circular(30),
        isRadio: true,
        buttons: value,
        onSelected: (int index, bool isSelected) {
          if(value[index].contains("Cuti"))
              ToastNotification.showNotification("Dokter Sedang Cuti", context, Colors.red);
          else {
            List<JadwalDokter> data = [jadwalDokter];
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JadwalSpesifik(
                  dataJadwalDokter: data,
                  tanggalDipilih: DateTime.parse(tanggal),
                  listSpesialisasi: daftarSpesialisasi, idSpesialisasi:
                  dokter.kodeSpesialisasi,
                  namaSpesialisasi: dokter.spesialisasi)
              )
            );
          }
        },
      );
    } else {
      return GroupButton(
        textAlign: TextAlign.center,
        selectedColor: Colors.grey[300],
        selectedTextStyle: TextStyle(color: Colors.black),
        spacing: 10,
        direction: Axis.horizontal,
        unselectedColor: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
        isRadio: true,
        buttons: value,
        onSelected: (int index, bool isSelected) {LoginAlert.alertBelumLogin(context);},
      );
    }
  }

  ///------------ Fungsi Shared Preference Ambil Data User ------------///

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

  ///------------ Ambil Daftar Dokter Favorit ------------///

  getFavorit() async {
    await SharedPreferenceHelper.getUser().then((value) {
      // Value[2] = userId
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

  Future<List<JadwalDokter>> cekCuti(Dokter dokter) async {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
    List dayList = List.generate(15, (index) => index)
        .map((value) => DateFormat('dd')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();

    /** MEMBUAT DAFTAR TAHUN DAN BULAN SAMPAI 15 HARI KEDEPAN **/
    List yearMonthList = List.generate(15, (index) => index)
        .map((value) => DateFormat('yyMM')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();

    List<JadwalDokter> listJadwalDokter = await jadwalService.getJadwalDokterById(dokter.kodeDokter);

    listJadwalDokter.forEach((jadwalDokter) {
      jadwalDokter.jadwalPraktek.forEach((jadwal) async {
        if (jadwalDokter.hari < now.weekday) {
          bool isOnShift = await cutiService.cekCuti(jadwalDokter.kodeDokter + "." + yearMonthList[jadwalDokter.hari + 7] + dayList[jadwalDokter.hari + 7] + jadwal.jam.substring(0, 2));
          if (isOnShift) {
            /** Tambah keterangan cuti bila ditemukan jadwal pada tabel jadwal_cuti **/
            jadwal.jam = jadwal.jam.substring(0, 5) + "\n(Dokter Cuti)";
          }
        }
        else {
          bool isOnShift = await cutiService.cekCuti(jadwalDokter.kodeDokter + "." + yearMonthList[jadwalDokter.hari] + dayList[jadwalDokter.hari] + jadwal.jam.substring(0, 2));
          if (isOnShift)
            /** Tambah keterangan cuti bila ditemukan jadwal pada tabel jadwal_cuti **/
            jadwal.jam = jadwal.jam.substring(0, 5) + "\n(Dokter Cuti)";
        }
      });
    });
   return listJadwalDokter;
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none)
      return false;
    else
      return true;
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => this.length > 0 ?'${this[0].toUpperCase()}${this.substring(1)}':'';
  String get toTitleCase => this.toLowerCase().replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.toCapitalized()).join(" ");
}


