import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/day_converter.dart';
import 'package:sobatku/helper/loginAlert.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/model/dokter.dart';
import 'package:sobatku/model/dokter_favorit.dart';
import 'package:sobatku/model/jadwal_dokter.dart';
import 'package:sobatku/model/spesialisasi.dart';
import 'package:sobatku/service/cuti_service.dart';
import 'package:sobatku/service/dokter_favorit_service.dart';
import 'package:sobatku/service/dokter_service.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:sobatku/service/spesialisasi_service.dart';
import 'package:group_button/group_button.dart';

import 'jadwal_dokter.dart';

class DaftarDokterLazy extends StatefulWidget {
  @override
  State createState() => _DaftarDokterLazyState();
}

class _DaftarDokterLazyState extends State<DaftarDokterLazy> {
  List<String> listDokterFavorit =[""];
  late DokterService doctorService;
  late SpesialisasiService spesialisasiService;
  late DokterFavoritService dokterFavoritService;
  late JadwalService jadwalService;
  late CutiService cutiService;
  TextEditingController _searchController = TextEditingController();
  late List<Dokter> daftarDokter = List.empty(growable: true);
  late List<Dokter> tempDaftarDokter = List.empty(growable: true);
  List<Spesialisasi> daftarSpesialisasi = List.empty(growable: true);
  Future<List<Dokter>>? _dokterData;
  late bool user =false;
  String idUser = "";
  int selectedIndex = 11;

  int currentLength = 0;
  final int increment = 5;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    doctorService = DokterService();
    cutiService = CutiService();
    jadwalService = JadwalService();
    spesialisasiService = SpesialisasiService();
    dokterFavoritService = DokterFavoritService();
    _dokterData = doctorService.getDokter();
    _loadMore();

    spesialisasiService.getSpesialisasi().then((value) {
      setState(() {
        daftarSpesialisasi= value;
      });
    });

    checkUserExist().then((value) {
      if (value) {
        getFavorit();
        setState(() {
          _dokterData!.then((value) {
            setState(() {
              print(value.length);
              tempDaftarDokter = List.from(value);
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
            tempDaftarDokter = List.from(value);
          });
        });
      }
    });
  }



  Future _loadMore() async {
    setState(() {
      isLoading = true;
    });
    
    await new Future.delayed(const Duration(seconds: 1));

    doctorService.getDokterLazy(increment, currentLength).then((value) {
      setState(() {
        value.forEach((element) {
          daftarDokter.add(element);
        });
        isLoading = false;
        currentLength = daftarDokter.length;
      });
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
          child: LazyLoadScrollView(
              isLoading: isLoading,
              onEndOfPage: () => _loadMore(),
              child: _buildListDokter(daftarDokter)
          ),
        ),
      )
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
      daftarDokter = tempDaftarDokter.where((element) => element.namaDokter.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  /*------------ Menampilkan Detail Dokter ------------*/

  Future<void> _buildDetailDokterDialog(BuildContext context, JadwalService scheduleService, Dokter dokter) async {
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
                            List<JadwalDokter> listJadwalDokter = snapshot.data;
                            if(listJadwalDokter.length == 0) {
                              return Center(
                                  child: Container(
                                      width: 300,
                                      height: MediaQuery.of(context).size.height*45/100,
                                      child: Center(child: Text("Belum Ada Jadwal"))
                                  )
                              );
                            }
                            return _buildListJadwal(listJadwalDokter, dokter);
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
              );}
        );
      },
    );
  }

  /*------------ Menampilkan Jadwal Dokter ------------*/

  Widget _buildListJadwal(List<JadwalDokter> jadwalDokter, Dokter dokter) {

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

    String tanggal = "";

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
                  if(jadwal.hari < now.weekday)
                    tanggal = dayList[jadwal.hari + 7];
                  else
                    tanggal = dayList[jadwal.hari];
                  return Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Flexible(
                              child: SizedBox(
                                child: ListTile(
                                  title: Center(
                                      child: Column(
                                        children: [
                                          Text(
                                              DayConverter.convertToDay(jadwal.hari),
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                          ),
                                          Text(
                                              jadwal.hari < now.weekday ? listTanggalFormatTampil[jadwal.hari + 7] : listTanggalFormatTampil[jadwal.hari]
                                          )
                                        ],
                                      )
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                      _buttonView(jadwal, tanggal, dokter, context)
                    ],
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonView (JadwalDokter jadwalDokter, String tanggal, Dokter dokter, BuildContext context) {
    List<String> value = [];
    value = jadwalDokter.jadwalPraktek.map((e) => e.jam).toList();
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
        onSelected: (int index, bool isSelected) {
          List<JadwalDokter> data = [jadwalDokter];
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JadwalSpesifik(dataJadwalDokter: data, tanggalDipilih: DateTime.parse(tanggal), listSpesialisasi: daftarSpesialisasi, idSpesialisasi: dokter.kodeSpesialisasi, namaSpesialisasi: dokter.spesialisasi),)
          );
          // _buildPasienListDialog(context, jadwalDokter, jadwalDokter.jadwalPraktek[index].jam);
        },
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
        onSelected: (int index, bool isSelected) {LoginAlert.alertBelumLogin(context);},
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

