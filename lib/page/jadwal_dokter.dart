import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/day_converter.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/model/jadwal_dokter.dart';
import 'package:sobatku/model/pasien.dart';
import 'package:sobatku/model/spesialisasi.dart';
import 'package:sobatku/model/transaksi_req.dart';
import 'package:sobatku/page/sign_in.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:sobatku/service/pasien_service.dart';
import 'package:sobatku/service/spesialisasi_service.dart';
import 'package:sobatku/service/transaksi_service.dart';

typedef void IntCallback(int id);

class ScheduleView extends StatefulWidget {
  ScheduleView({Key? key, required this.data, required this.date, required this.listSpesialisasi, required this.idSpesialisasi, required this.namaSpesialisasi}) : super(key: key);
  final List<JadwalDokter> data;
  final DateTime date;
  final List<Spesialisasi> listSpesialisasi;
  final int idSpesialisasi;
  final String namaSpesialisasi;


  @override
  State<StatefulWidget> createState() {
    return ScheduleViewState();
  }
}

class ScheduleViewState extends State<ScheduleView> {

  //DropDown Value
  List<DropdownMenuItem<String>> itemList = [];
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

  late List<Spesialisasi> daftarSpesialisasi;
  late List<JadwalDokter> listJadwal;
  late int idSpesialisasi;
  late List<Pasien> daftarPasien;
  late bool isUserExist = false;
  late String idUser;
  late int selectedIndex = 11;
  late DateTime dateTime;

  @override
  void initState() {
    super.initState();
    //Inisialisasi Data Dari main.dart
    listJadwal = widget.data;
    dayInNumber = DayConverter.convertToNumber(DateFormat('EEEE').format(widget.date)).toString();
    txtController.text =  datePickedFormatted = DateFormat('dd-MM-yyyy').format(widget.date);
    daftarSpesialisasi = widget.listSpesialisasi;
    idSpesialisasi = widget.idSpesialisasi;
    dropdownvalue = widget.namaSpesialisasi;
    dateTime = widget.date;

    //Inisialisasi Service
    transaksiService = TransaksiService();
    jadwalService =JadwalService();
    pasienService = PasienService();

    //Ambil Data Bila User Sudah Ada
    SharedPreferenceHelper.checkUserExist().then((value) {
      setState(() {
        isUserExist = value;
      });
    });

    //Convert Data Ke DropdownMenuItem
    daftarSpesialisasi.forEach((spesialisasi) {
      itemList.add(DropdownMenuItem(
          child: Text(spesialisasi.namaSpesialisasi),
          value: spesialisasi.namaSpesialisasi)
      );
    });
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
              filterBar(context),
              ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int i) => Divider(color: Colors.grey[400]),
                  itemCount: listJadwal.length,
                  itemBuilder: (context, index) {
                    JadwalDokter jadwalDokter = listJadwal[index];
                    return InkWell(
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
                                    Text(jadwalDokter.nama, style: TextStyle(fontSize: 20)),
                                    SizedBox(height: 5),
                                    _buttonView(jadwalDokter, context)
                                  ],
                                )
                              ),
                            )
                          )
                        ],
                      ),
                    );
                  }
              ),
            ],
          ),
        )
    );
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
                      idSpesialisasi = spesialisasi.idSpesialisasi;
                  });
                  jadwalService.getJadwalDokter(idSpesialisasi.toString(),dayInNumber).then((value) {
                    setState(() {
                      listJadwal = value;
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
        jadwalService.getJadwalDokter(idSpesialisasi.toString(), dayInNumber).then((value) {
          setState(() {
            listJadwal = value;
          });
        });
      });
    }
  }


  Widget _buttonView (JadwalDokter schedule, BuildContext context) {
    List<String> value = [];
    value = schedule.jadwalPraktek.map((e) => e.jam).toList();
    if(isUserExist) {
      return GroupButton(
        selectedColor: Constant.color,
        selectedTextStyle:TextStyle(color: Colors.white),
        spacing: 10,
        direction: Axis.horizontal,
        unselectedColor:  Colors.lightGreen[300],
        borderRadius: BorderRadius.circular(30),
        isRadio: true,
        buttons: value.reversed.toList(),
        onSelected: (int index, bool isSelected) {_buildPasienListDialog(context, schedule, schedule.jadwalPraktek[index].jam);}
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

  /*------------ Menampilkan Pasien Dan Metode Pembayaran Sebelum Daftar ------------*/

  Future<void> _buildPasienListDialog(BuildContext context, JadwalDokter jadwalDokter, String jam) async {
    final now = DateTime.now();
    List<String> data = ["Asuransi", "Umum", "BPJS"];
    List<String> value = ["2", "3", "9"];
    String kodeJadwal = "";
    String tipe = "";
    String noRm = "";
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
    List dayList = List.generate(15, (index) => index)
        .map((value) => DateFormat('dd')
        .format(firstDayOfWeek.add(Duration(days: value))))
        .toList();
    if(jadwalDokter.hari < now.weekday || now.compareTo(dateTime) == -1)
      kodeJadwal = jadwalDokter.kodeDokter + "." + DateFormat('yyMM').format(now) + dayList[jadwalDokter.hari+7] + jam.substring(0,2);
    else
      kodeJadwal = jadwalDokter.kodeDokter + "." + DateFormat('yyMM').format(now) + dayList[jadwalDokter.hari] + jam.substring(0,2);
    print(kodeJadwal);
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
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Constant.color)),
                                    onPressed: () {
                                      TransaksiReq transaksi = new TransaksiReq(
                                          kodeJadwal: kodeJadwal,
                                          kodeDokter: jadwalDokter.kodeDokter,
                                          nomorRm: noRm,
                                          tipe: tipe);
                                      transaksiService.createTransaksi(
                                          transaksi, idUser).then((value) {
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
}







