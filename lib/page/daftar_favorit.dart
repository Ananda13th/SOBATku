import 'package:cached_network_image/cached_network_image.dart';
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

class FavoriteList extends StatefulWidget {
  @override
  State createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  List<String> favorite = List.empty(growable: true);
  late DokterService doctorService;
  late JadwalService jadwalService;
  late PasienService pasienService;
  late SpesialisasiService spesialisasiService;
  late DokterFavoritService dokterFavoritService;
  late TransaksiService transaksiService;
  late CutiService cutiService;
  late List<Dokter> doctors;
  List<Dokter> tempDoctorData = List.empty(growable: true);
  Future<List<Dokter>>? _doctorData;
  List<Spesialisasi> daftarSpesialisasi = List.empty(growable: true);
  late bool user =false;
  late String idUser;
  int selectedIndex = 11;

  @override
  void initState() {
    super.initState();
    doctorService = DokterService();
    pasienService = PasienService();
    jadwalService = JadwalService();
    spesialisasiService = SpesialisasiService();
    transaksiService = TransaksiService();
    cutiService = CutiService();
    _doctorData = doctorService.getDokter();

    spesialisasiService.getSpesialisasi().then((value) {
      setState(() {
        daftarSpesialisasi= value;
      });
    });

    checkUserExist().then((value) {
      setState(() {
        user = value;
        if(value) {
          SharedPreferenceHelper.getFavorite().then((value) {
            setState(() {
              favorite = value!;
              _doctorData!.then((dataList) {
                  dataList.forEach((data) {
                    if(favorite.contains(data.idDokter.toString()))
                      tempDoctorData.add(data);
                  });
              });
            });
          });
        }
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
          title: Text("Daftar Dokter Favorit"),
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
          child: FutureBuilder<List<Dokter>>(
            future: _doctorData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError) {
                return Center(
                  child: Text("Terjadi Kesalahan")
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

  Widget _buildListDokter(List<Dokter> daftarDokter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.transparent),
              itemCount: daftarDokter.length,
              itemBuilder: (context, index) {
                Dokter dokter = daftarDokter[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
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
                            width: 100,
                            height: 100,
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
                                  title: Text(dokter.namaDokter, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
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
          ),
        )
      ],
    );
  }

  /*------------ Menampilkan Detail Dokter ------------*/

  Future<void> _buildDetailDokterDialog(BuildContext context, JadwalService scheduleService,  List<JadwalDokter> listJadwalDokter, Dokter dokter) async {
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
                        ),
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


  /*------------ Fungsi Shared Preference Ambil Data User ------------*/

  Future<bool> checkUserExist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? _user = prefs.getBool('userExist');
    if(_user == true)
      return true;
    else
      return false;
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
  /*------------ Menampilkan Pasien Dan Metode Pembayaran Sebelum Daftar ------------*/

  // Future<void> _buildPasienListDialog(BuildContext context, JadwalDokter jadwalDokter, String jam) async {
  //   final now = DateTime.now();
  //   List<String> data = ["Asuransi", "Umum", "BPJS"];
  //   List<String> value = ["2", "3", "9"];
  //   String kodeJadwal = "";
  //   String tipe = "";
  //   String noRm = "";
  //   bool cuti = false;
  //   final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
  //   List dayList = List.generate(15, (index) => index)
  //       .map((value) => DateFormat('dd')
  //       .format(firstDayOfWeek.add(Duration(days: value))))
  //       .toList();
  //
  //   List yearMonthList = List.generate(15, (index) => index)
  //       .map((value) => DateFormat('yyMM')
  //       .format(firstDayOfWeek.add(Duration(days: value))))
  //       .toList();
  //
  //   if(jadwalDokter.hari < now.weekday) {
  //     kodeJadwal = jadwalDokter.kodeDokter + "." + yearMonthList[jadwalDokter.hari+7] + dayList[jadwalDokter.hari + 7] + jam.substring(0, 2);
  //   }
  //   else {
  //     kodeJadwal = jadwalDokter.kodeDokter + "." + DateFormat('yyMM').format(now) + dayList[jadwalDokter.hari] + jam.substring(0, 2);
  //   }
  //   print("Kode Jadwal : "+kodeJadwal);
  //
  //   await cutiService.cekCuti(kodeJadwal).then((value) {
  //     cuti = value;
  //   });
  //
  //   if(cuti == true) {
  //     ToastNotification.showNotification('Maaf Dokter Sedang Cuti', context, Colors.red);
  //   }
  //   else
  //   if (user) {
  //     SharedPreferenceHelper.getUser().then((value) {
  //       setState(() {
  //         idUser = value![2];
  //       });
  //     });
  //     await showDialog(
  //       context: context,
  //       builder: (context) {
  //         return Scaffold(
  //             backgroundColor: Colors.transparent,
  //             body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
  //               return AlertDialog(
  //                   contentPadding: EdgeInsets.zero,
  //                   content:
  //                   Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Container(
  //                               height: 40,
  //                               color: Constant.color,
  //                               child: Center(
  //                                 child: Text("Pilih Pasien",
  //                                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       FutureBuilder(
  //                         future: pasienService.getPairing(idUser),
  //                         builder: (BuildContext context,
  //                             AsyncSnapshot snapshot) {
  //                           if (snapshot.hasError) {
  //                             return Center(
  //                               child: Text("Error"),
  //                             );
  //                           }
  //                           else if (snapshot.hasData) {
  //                             List<Pasien> patients = snapshot.data;
  //                             return Container(
  //                               width: MediaQuery.of(context).size.width,
  //                               height: 180,
  //                               child: ListView.separated(
  //                                   separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.black, thickness: 1, height: 5),
  //                                   itemCount: patients.length,
  //                                   itemBuilder: (context, index) {
  //                                     Pasien patient = patients[index];
  //                                     return Row(
  //                                       children: <Widget>[
  //                                         Flexible(
  //                                           child: InkWell(
  //                                             onTap: () {
  //                                               setState(() {
  //                                                 selectedIndex = index;
  //                                                 noRm = patient.nomorRm;
  //                                               });
  //                                             },
  //                                             child: Container(
  //                                               width: MediaQuery.of(context).size.width,
  //                                               child: ListTile(
  //                                                 title: Padding(
  //                                                   padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
  //                                                   child: Center(
  //                                                     child: Text(
  //                                                       patient.namaPasien,
  //                                                       style: TextStyle(
  //                                                         color:  selectedIndex == index ? Constant.color : Colors.black,
  //                                                         fontWeight: FontWeight.bold
  //                                                       )
  //                                                     )
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                           )
  //                                         )
  //                                       ],
  //                                     );
  //                                   }
  //                               ),
  //                             );
  //                           }
  //                           else {
  //                             return Center(
  //                               child: Container(),
  //                             );
  //                           }
  //                         },
  //                       ),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Container(
  //                               height: 40,
  //                               color: Constant.color,
  //                               child: Center(
  //                                 child: Text("Pilih Pembayaran",
  //                                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                           height: 10
  //                       ),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Container(
  //                               height: 80,
  //                               child: Padding(
  //                                 padding: const EdgeInsets.only(left: 10, right: 10),
  //                                 child: GroupButton(
  //                                     selectedColor: Constant.color,
  //                                     selectedTextStyle: TextStyle(
  //                                         color: Colors.white),
  //                                     spacing: 10,
  //                                     direction: Axis.horizontal,
  //                                     unselectedColor: Colors.grey[300],
  //                                     borderRadius: BorderRadius.circular(30),
  //                                     isRadio: true,
  //                                     buttons: data,
  //                                     onSelected: (int index, bool isSelected) {
  //                                       tipe = value[index];
  //                                     }
  //                                 ),
  //                               ),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                       SizedBox(
  //                           height: 10
  //                       ),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(8.0),
  //                               child: ElevatedButton(
  //                                   style: ButtonStyle(
  //                                       backgroundColor: MaterialStateProperty.all<
  //                                           Color>(Constant.color)),
  //                                   onPressed: () {
  //                                     TransaksiReq transaksi = new TransaksiReq(
  //                                         kodeJadwal: kodeJadwal,
  //                                         kodeDokter: jadwalDokter.kodeDokter,
  //                                         nomorRm: noRm,
  //                                         tipe: tipe);
  //                                     transaksiService.createTransaksi(
  //                                         transaksi, idUser).then(
  //                                             (value) {
  //                                           Color color = Constant.color;
  //                                           if (value != "Antrian berhasil dibuat.")
  //                                             color = Colors.red;
  //                                           ScaffoldMessenger.of(context)
  //                                               .showSnackBar(
  //                                               SnackBar(
  //                                                   duration: Duration(seconds: 2),
  //                                                   backgroundColor: color,
  //                                                   content: Text(value,
  //                                                       style: TextStyle(
  //                                                           fontSize: 16,
  //                                                           fontWeight: FontWeight
  //                                                               .bold,
  //                                                           color: Colors.white))
  //                                               )
  //                                           );
  //                                           Future.delayed(
  //                                               Duration(seconds: 3), () {
  //                                             // 5 seconds over, navigate to Page2.
  //                                             Navigator.pop(context);
  //                                           });
  //                                         }
  //                                     );
  //                                   },
  //                                   child: Text("Daftar")),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(8.0),
  //                               child: ElevatedButton(
  //                                   style: ButtonStyle(
  //                                       backgroundColor: MaterialStateProperty.all<
  //                                           Color>(Colors.grey)),
  //                                   onPressed: () {
  //                                     if (Navigator.canPop(context)) {
  //                                       Navigator.pop(context);
  //                                     } else {
  //                                       SystemNavigator.pop();
  //                                     }
  //                                   },
  //                                   child: Text("Batal", style: TextStyle(
  //                                       color: Colors.white,
  //                                       fontWeight: FontWeight.bold))),
  //                             ),
  //                           )
  //                         ],
  //                       )
  //                     ],
  //                   )
  //               );
  //             }
  //           )
  //         );
  //       },
  //     );
  //   }
  // }
}

