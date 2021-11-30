import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/day_converter.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/helper/toastNotification.dart';
import 'package:sobatku/model/jadwal_dokter.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/model/spesialisasi.dart';
import 'package:sobatku/model/transaksi_req.dart';
import 'package:sobatku/page/sign_in.dart';
import 'package:sobatku/service/bpjs_service.dart';
import 'package:sobatku/service/cuti_service.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/spesialisasi_service.dart';
import 'package:sobatku/service/transaksi_service.dart';

typedef void IntCallback(int id);

class JadwalSpesifik extends StatefulWidget {
  JadwalSpesifik({Key? key, required this.dataJadwalDokter, required this.tanggalDipilih, required this.listSpesialisasi, required this.idSpesialisasi, required this.namaSpesialisasi}) : super(key: key);
  final List<JadwalDokter> dataJadwalDokter;
  final DateTime tanggalDipilih;
  final List<Spesialisasi> listSpesialisasi;
  final String idSpesialisasi;
  final String namaSpesialisasi;


  @override
  State<StatefulWidget> createState() {
    return JadwalSpesifikState();
  }
}

class JadwalSpesifikState extends State<JadwalSpesifik> {

  //DropDown Value
  List<DropdownMenuItem<String>> itemList = [];
  List<String> jamJadwal = [];
  String dropdownvalue = "-PILIH SPESIALISASI-";
  final txtController = TextEditingController();
  //Kalender Value
  var now = DateTime.now();
  late String datePickedFormatted;
  late String dayInNumber;
  //Service
  late SpesialisasiService spesialisasiService;
  late TransaksiService transaksiService;
  late JadwalService jadwalService;
  late PasienService pasienService;
  late CutiService cutiService;
  late BpjsService bpjsService;

  late List<Spesialisasi> daftarSpesialisasi;
  late List<JadwalDokter> listJadwal;
  late String kodeSpesialisasi;
  late List<Pasien> daftarPasien;
  late bool isUserExist = false;
  late String idUser;
  //Dummy Index
  late int selectedIndex = 11;
  late DateTime dateTime;


  @override
  void initState() {
    super.initState();
    /** Inisialisasi Data Dari main.dart **/
    listJadwal = widget.dataJadwalDokter;
    dayInNumber = DayConverter.convertToNumber(DateFormat('EEEE').format(widget.tanggalDipilih)).toString();
    txtController.text =  datePickedFormatted = DateFormat('dd-MM-yyyy').format(widget.tanggalDipilih);
    daftarSpesialisasi = widget.listSpesialisasi;
    kodeSpesialisasi = widget.idSpesialisasi;
    dropdownvalue = widget.namaSpesialisasi;
    dateTime = widget.tanggalDipilih;



    /** Inisialisasi Service **/
    transaksiService = TransaksiService();
    jadwalService =JadwalService();
    pasienService = PasienService();
    cutiService = CutiService();
    bpjsService = BpjsService();

    /** Ambil Data Bila User Sudah Ada **/
    SharedPreferenceHelper.checkUserExist().then((value) {
      setState(() {
        isUserExist = value;
      });
    });

    /** Convert Data Ke DropdownMenuItem **/
    daftarSpesialisasi.forEach((spesialisasi) {
      itemList.add(DropdownMenuItem(
          child: Text(spesialisasi.namaSpesialisasi),
          value: spesialisasi.namaSpesialisasi)
      );
    });

    cekJadwalCuti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Daftar Dokter")),
        body: Container(
          decoration: BoxDecoration(image:
          DecorationImage(
              image: AssetImage("assets/images/Background.png"),
              alignment: Alignment.center,
              fit: BoxFit.fill)),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: filterBar(context)
              ),
              Flexible(
                child: ListView.builder(
                    itemCount: listJadwal.length,
                    itemBuilder: (context, index) {
                      /** MELAKUKAN CEK PADA TABEL DAFTAR CUTI BILA ADA JADWAL PRAKTIK OLEH DOKTER YANG SEDANG CUTI**/
                      JadwalDokter jadwalDokter = listJadwal[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration:  BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 4,
                                offset: Offset(4, 8), // Shadow position
                              ),
                            ],
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: Row(
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
                                  child: ListTile(
                                    title: Column(
                                      children: [
                                        Text(jadwalDokter.nama, style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                                        SizedBox(height: 5),
                                        /** TAMPIL DAFTAR PRAKTIK DOKTER PADA TOMBOL **/
                                        _buttonView(jadwalDokter, context)
                                      ],
                                    )
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
            ],
          ),
        )
    );
  }

  Widget _buttonView (JadwalDokter jadwalDokter, BuildContext context) {
    List<String> value = [];
    value = jadwalDokter.jadwalPraktek.map((e) => e.jam).toList();
    /** BILA USER SUDAH LOGIN, MAKA TOMBOL AKAN BERWARNA HIJAU**/
    if(isUserExist) {
      return GroupButton(
          selectedColor: Constant.color,
          selectedTextStyle:TextStyle(color: Colors.white),
          spacing: 10,
          textAlign: TextAlign.center,
          direction: Axis.horizontal,
          unselectedColor:  Colors.lightGreen[300],
          borderRadius: BorderRadius.circular(30),
          isRadio: true,
          buttons: value.toList(),
          onSelected: (int index, bool isSelected) {
            _buildPasienListDialog(context, jadwalDokter, jadwalDokter.jadwalPraktek[index].jam);
          }
      );
    } else {
      /** BILA USER BELUM LOGIN, MAKA TOMBOL AKAN BERWARNA ABU-ABU**/
      return GroupButton(
        selectedColor: Colors.grey[300],
        selectedTextStyle: TextStyle(color: Colors.black),
        spacing: 10,
        textAlign: TextAlign.center,
        direction: Axis.horizontal,
        unselectedColor: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
        isRadio: true,
        buttons: value,
        onSelected: (int index, bool isSelected) {
          _buildAlert(context);
        },
      );
    }
  }

  /*------------ Menampilkan Pasien Dan Metode Pembayaran Sebelum Daftar ------------*/

  Future<void> _buildPasienListDialog(BuildContext context, JadwalDokter jadwalDokter, String jam) async {
    final now = DateTime.now();
    List<String> data = ["Asuransi", "Umum", "BPJS"];
    List<String> value = ["2", "3", "9"];
    String kodeJadwal = "";
    String tipe = "";
    String noRm = "";
    String noBpjs = "";
    bool cuti = false;

    /** PEMBUATAN KODE JADWAL **/

    final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
    /** MEMBUAT DAFTAR TANGGAL SAMPAI 15 HARI KEDEPAN **/
    List dayList = List.generate(15, (index) => index)
        .map((value) => DateFormat('dd')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();

    /** MEMBUAT DAFTAR TAHUN DAN BULAN SAMPAI 15 HARI KEDEPAN **/
    List yearMonthList = List.generate(15, (index) => index)
        .map((value) => DateFormat('yyMM')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();

    if(jadwalDokter.hari < now.weekday) {
      kodeJadwal = jadwalDokter.kodeDokter + "." + yearMonthList[jadwalDokter.hari+7] + dayList[jadwalDokter.hari + 7] + jam.substring(0, 2);
    }
    else {
      kodeJadwal = jadwalDokter.kodeDokter + "." + yearMonthList[jadwalDokter.hari] + dayList[jadwalDokter.hari] + jam.substring(0, 2);
    }
    print("Kode Jadwal : "+kodeJadwal);

    /** CEK ADA ATAU TIDAK KODE JADWAL PADA TABEL CUTI**/

    await cutiService.cekCuti(kodeJadwal).then((value) {
      cuti = value;
    });

    if(cuti == true) {
      ToastNotification.showNotification('Maaf Dokter Sedang Cuti', context, Colors.red);
    }
    else
    if (isUserExist) {
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
                /** TAMPIL DIALOG UNTUK PILIH PEMBAYARAN & PASIEN **/
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
                                                    noBpjs = patient.nomorBpjs;
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
                                                            ),
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
                            height: 20
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 80,
                                child: GroupButton(
                                    selectedColor: Constant.color,
                                    selectedTextStyle: TextStyle(color: Colors.white),
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
                            )
                          ],
                        ),
                        SizedBox(
                            height: 20
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Constant.color)),
                                    onPressed: () {
                                      print(noRm);
                                      TransaksiReq transaksi = new TransaksiReq(
                                          kodeJadwal: kodeJadwal,
                                          kodeDokter: jadwalDokter.kodeDokter,
                                          nomorRm: noRm,
                                          tipe: tipe);
                                      if(tipe == "9") {
                                        bpjsService.cekRujukan(noBpjs).then((value) {
                                          print(value);
                                          if (value.toString() != "Rujukan Tidak Ada") {
                                            transaksiService.createTransaksi(transaksi, idUser).then((value) {
                                              Color color = Constant.color;
                                              if (value != "Antrian berhasil dibuat.")
                                                color = Colors.red;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: color,
                                                  content: Text(
                                                    value,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white)
                                                  )
                                                )
                                              );
                                              Future.delayed(Duration(seconds: 3), () {Navigator.pop(context);});
                                            });
                                          }
                                          else {
                                            ToastNotification.showNotification(value.toString(), context, Colors.red);
                                          }
                                        });
                                      }
                                      else {
                                        transaksiService.createTransaksi(transaksi, idUser).then((value) {
                                          Color color = Constant.color;
                                          if (value != "Antrian berhasil dibuat.")
                                            color = Colors.red;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: color,
                                                  content: Text(
                                                      value,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white)
                                                  )
                                              )
                                          );
                                        });
                                      }
                                    },
                                    child: Text("Daftar")
                                ),
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
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
                                    onPressed: () {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      } else {
                                        SystemNavigator.pop();
                                      }
                                    },
                                    child: Text("Batal", style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)
                                    )
                                ),
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

  /*------------ Fungsi Tampil Filter ------------*/

  Widget filterBar(BuildContext context) {
    return Row(
      children: [
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
                jadwalService.getJadwalDokter(kodeSpesialisasi.toString(),dayInNumber).then((value) {
                  setState(() {
                    listJadwal = value;
                    cekJadwalCuti();
                  });
                });
              });
            },
            isExpanded: true,
          )
        ),
        Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
              child: InkWell(
                onTap: (){showCalendar(context);},
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    border: InputBorder.none,
                    labelText: 'Pilih Tanggal',
                  ),
                  enabled: false,
                  controller: txtController..text,
                ),
              ),
            )
        )
      ],
    );
  }

  /*------------ Fungsi Tampil Kalendar ------------*/

  showCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      cancelText: "Batal",
      confirmText: "OK",
      context: context,
      initialDate: dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 7)));
    if(picked != null && picked != now) {
      setState(() {
        txtController.text = DateFormat('dd-MM-yyyy').format(picked);
        datePickedFormatted = DateFormat('dd-MM-yyyy').format(picked);
        dateTime = picked;
        dayInNumber = DayConverter.convertToNumber(DateFormat('EEEE').format(picked)).toString();
        jadwalService.getJadwalDokter(kodeSpesialisasi.toString(), dayInNumber).then((value) {
          setState(() {
            listJadwal = value;
            cekJadwalCuti();
          });
        });
      });
    }
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
                            child: Center(child: const Text('Masuk'))
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

  Future<void> cekJadwalCuti() async {
    listJadwal.forEach((jadwalDokter) {
      for (int test = 0; test < jadwalDokter.jadwalPraktek.length; test++) {
        cutiService.cekCuti(jadwalDokter.kodeDokter + "." + DateFormat("yyMMdd").format(dateTime) + jadwalDokter.jadwalPraktek[test].jam.substring(0, 2)).then((value) {
          if (value)
            if (mounted)
              setState(() {
                /** Tambah keterangan cuti bila ditemukan jadwal pada tabel jadwal_cuti **/
                jadwalDokter.jadwalPraktek[test].jam =
                    jadwalDokter.jadwalPraktek[test].jam.substring(0, 5) +
                        "\n(Dokter Cuti)";
              });
        });
      }
    });
  }


}







