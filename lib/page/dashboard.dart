import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:sizer/sizer.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/model/banner.dart';
import 'package:sobatku/page/daftar_dokter.dart';
import 'package:sobatku/page/daftar_favorit.dart';
import 'package:sobatku/page/daftar_notifikasi.dart';
import 'package:sobatku/page/detail_banner.dart';
import 'package:sobatku/service/banner_service.dart';
import 'package:sobatku/service/dokter_favorit_service.dart';
import 'package:sobatku/service/jadwal_dokter_service.dart';
import 'package:sobatku/service/spesialisasi_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeViewState();
  }
}

class HomeViewState extends State<HomeView> {
  List<String> listDokterFavorit =[""];
  int currentIndex = 0;
  late BannerService bannerService;
  late DokterFavoritService dokterFavoritService;
  late SpesialisasiService spesialisasiService;
  late JadwalService jadwalService;
  BannerModel temp = new BannerModel(url: "https://c.tenor.com/I6kN-6X7nhAAAAAj/loading-buffering.gif", urlDetailBanner:"", deskripsi: "", keterangan: "");
  late List<String> listBannerPromoTest = ["assets/images/promo1.jpeg","assets/images/promo2.jpeg", "assets/images/promo3.jpeg", "assets/images/promo4.jpeg", "assets/images/promo5.jpeg", "assets/images/promo6.jpeg"];
  late List<String> listBannerTest = ["assets/images/Banner.png"];
  late List<BannerModel> listBanner = [temp];
  List<BannerModel> listBannerUtama = [];
  List<BannerModel> listBannerPromo = [];
  List<BannerModel> listBannerBerita = [];
  final CarouselController _controller = CarouselController();




  @override
  void initState() {
    super.initState();
    bannerService = BannerService();
    dokterFavoritService = DokterFavoritService();
    bannerService.getBanner().then((value) {
      setState(() {
        listBanner = value;
        listBanner.forEach((element) {
          if(element.keterangan == "Banner")
            listBannerUtama.add(element);
          if(element.keterangan == "Promo")
            listBannerPromo.add(element);
          if(element.keterangan == "Berita")
            listBannerBerita.add(element);
        });
      });
    });
    getFavorit();
  }

  getFavorit() async {
    String idUser = "";
    await SharedPreferenceHelper.getUser().then((value) => idUser = value![2]);
    dokterFavoritService.getDokterfavorit(idUser)
        .then((value){
      value.forEach((element) {
        listDokterFavorit.add(element.idDokter.toString());
        SharedPreferenceHelper.addFavorite(listDokterFavorit);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  expandedHeight: 110,
                  title: Row(
                    children: [
                     Container(
                       height: 100,
                       width: 200,
                       child: Image.asset("assets/images/LogoRSBanner.png", fit: BoxFit.scaleDown)
                     )
                    ],
                  ),
                  bottom: AppBar(
                      backgroundColor: Constant.color,
                      title: Container(
                        width: 240,
                        height: 35,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Cari Layanan...",
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      actions: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(builder: (
                                        context) => new DaftarNotifikasi()));
                              },
                              icon: Icon(Icons.notification_important)
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(builder: (
                                        context) => new FavoriteList()));
                              },
                              icon: Icon(Icons.favorite)
                            ),
                        ],
                      )
                    ]
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(image:
                    DecorationImage(
                        image: AssetImage("assets/images/Background.png"),
                        alignment: Alignment.center,
                        fit: BoxFit.fill)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child:
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            color: Colors.transparent,
                            height: 260,
                            child: _createCarousel(listBannerUtama)
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.transparent,
                                  height: 210,
                                  width: MediaQuery.of(context).size.width,
                                  child: _gridView(context)),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text("Promo dan Layanan", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 10),
                          Container(
                              color: Colors.transparent,
                              height: 200,
                              child: gridPromoLayanan(listBannerPromo)
                          ),
                          SizedBox(height: 20),
                          Text("Berita Kesehatan Terkini", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 10),
                          Container(
                              color: Colors.transparent,
                              height: 260,
                              child: _createCarousel(listBannerBerita)
                          ),
                          SizedBox(height: 20),
                          Text("Hubungi dan Ikuti Kami", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 10),
                          _buttonView(),
                        ],
                      ),
                    ),
                  ),
                )
              ]
            ),
          ),
        );
      }
    );
  }

  /*------------ Carousel ------------*/
  
  Widget _createCarousel(List<BannerModel> bannerList) {
    return Column(
      children: [
        CarouselSlider(
          items: bannerList.map((item) {
          // items: listBannerTest.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                        borderRadius:  BorderRadius.circular(15.0),
                        child: InkWell(
                          onTap: (){
                            Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new DetailBanner(bannerModel: item, keterangan: 'Banner')));
                          },
                          child: item.deskripsi == "" ? Image.network((item.url), fit: BoxFit.scaleDown) : Image.network((item.url), fit: BoxFit.fill)
                          // child: Image.asset(item, fit: BoxFit.fill),
                        )
                    )
                );
              },
            );
          }).toList(),
          carouselController: _controller,
          options: CarouselOptions(
            viewportFraction: 1,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            }
          ),
        ),
        //Index Carousel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerList.asMap().entries.map((entry) {
          //children: listBannerTest.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(currentIndex == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  /*------------ Grid Menu ------------*/

  Widget _gridView (BuildContext context) {
    double cardHeight;
    double cardWidth = 50.w;
    if(MediaQuery.of(context).size.width < 410)
      cardHeight = 34.h;
    else
      cardHeight = 35.h;
    List<String> teks = ["Jadwal Dokter", "Imunisasi", "Medical Checkup", "Klinik Online", "Periksa COVID", "Pemeriksaan Lab", "Fast Track"];
    final List<String> icons = [
      "assets/images/Jadwal_Dokter.png",
      "assets/images/DT_IMUNISASI.png",
      "assets/images/MCU.png",
      "assets/images/Klinik_Online.png",
      "assets/images/Pemeriksaan_COVID.png",
      "assets/images/Pemeriksaan_LAB.png",
      "assets/images/Fast_Track.png"];
    return GridView.count(
        shrinkWrap: true,
        childAspectRatio: cardWidth / cardHeight,
        crossAxisCount: 2,
        scrollDirection: Axis.horizontal,
        mainAxisSpacing: 5,
        crossAxisSpacing: 3,
        children: List.generate(icons.length, (index) {
          return
            Center(
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child:
                SizedBox(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: (){
                          if(index == 0)
                            Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new DoctorList()));
                          if(index == 1)
                            launchWhatsApp("Imunisasi");
                          if(index == 2)
                            launchWhatsApp("MCU");
                          if(index == 3)
                            launchWhatsApp("Klinik");
                          if(index == 4)
                            _launchURL("https://daftar.droensolobaru.com/booking/pribadi");
                          // if(index == 5)
                          //   showMenu(context);
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          child: Image.asset(icons[index]),
                        )
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(teks[index], style: TextStyle(color: Colors.black, fontSize:14, fontWeight: FontWeight.bold),)
                    ],
                  )
                )
              ),
            );
        })
    );
  }

  // Future<void> showMenu(BuildContext context) async {
  //   double cardWidth = MediaQuery.of(context).size.width / 2;
  //   double cardHeight = MediaQuery.of(context).size.height / 3.5;
  //   List<String> teks = ["Jadwal Dokter", "Imunisasi", "Medical Chekup", "Klinik Online", "Periksa COVID", "Pemeriksaan Lab", "Fast Track"];
  //   final List<String> icons = [
  //     "assets/images/Jadwal_Dokter.png",
  //     "assets/images/DT_IMUNISASI.png",
  //     "assets/images/MCU.png",
  //     "assets/images/Klinik_Online.png",
  //     "assets/images/Pemeriksaan_COVID.png",
  //     "assets/images/Pemeriksaan_LAB.png",
  //     "assets/images/Fast_Track.png",
  //   ];
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SimpleDialog(
  //         shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //         ),
  //         children: <Widget>[
  //           Container(
  //             width: 350,
  //             height: 350,
  //             child: GridView.count(
  //               childAspectRatio: cardWidth / cardHeight,
  //               crossAxisCount: 3,
  //               scrollDirection: Axis.vertical,
  //               mainAxisSpacing: 5,
  //               crossAxisSpacing: 3,
  //               children: List.generate(icons.length, (index) {
  //                 return
  //                   SizedBox(
  //                     child: Column(
  //                       children: [
  //                         InkWell(
  //                           onTap: (){
  //                             if(index == 0)
  //                               Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new DoctorList()));
  //                             if(index == 1)
  //                               launchWhatsApp("Imunisasi");
  //                             if(index == 2)
  //                               launchWhatsApp("MCU");
  //                             if(index == 3)
  //                               launchWhatsApp("Klinik");
  //                             if(index == 4)
  //                               _launchURL("https://daftar.droensolobaru.com/booking/pribadi");
  //                           },
  //                           child: Container(
  //                             width: 80,
  //                             child: index != 6 && index !=5 ? Image.asset(icons[index]) : ColorFiltered(
  //                               colorFilter: ColorFilter.mode(
  //                                 Colors.grey,
  //                                 BlendMode.saturation,
  //                               ),
  //                               child: Image.asset(icons[index]),
  //                             )
  //                           )
  //                         ),
  //                         Center(child: Text(teks[index],textAlign: TextAlign.center,style: TextStyle(color: Colors.black, fontSize:14, fontWeight: FontWeight.bold),))
  //                       ],
  //                     )
  //                   );
  //               })
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  /*------------ Menu Media Sosial------------*/
  
  Widget _buttonView () {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
      child: Row(
        children: [
          _icon(0, text: "Web", image: "assets/icons/WEB.png"),
          _icon(1, text: "Instagram", image: "assets/icons/IG.png"),
          _icon(2, text: "WhatsApp", image: "assets/icons/WA.png"),
          _icon(3, text: "Location", image: "assets/icons/LOC.png")
        ],
      ),
    );
  }

  Widget _icon(int index, {required String text, required String image}) {
    double padding;
    if(MediaQuery.of(context).size.width < 410)
      padding = MediaQuery.of(context).size.width*3.5/100;
    else
      padding = MediaQuery.of(context).size.width*3.8/100;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: InkResponse(
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              child: Image.asset(image)
            ),
            Text(text, style: TextStyle(color:Colors.transparent, fontWeight: FontWeight.bold)),
          ],
        ),
        onTap: (){
          if(index == 0) {
            _launchURL("https://droensolobaru.com/");
          }
          if(index == 1) {
            _launchURL("https://instagram.com/droen_solobaru/");
          }
          if(index == 2) {
            launchWhatsApp("General");
          }
          if(index == 3) {
            _launchURL("https://www.google.com/maps/place/RS+Dr.+OEN+SOLO+BARU/@-7.606801,110.7957897,17z/data=!3m1!4b1!4m5!3m4!1s0x2e7a3e2fabec7177:0xc073cd7a8c61f913!8m2!3d-7.606801!4d110.7979784");
          }
        },
      ),
    );
  }

  Widget gridPromoLayanan(List<BannerModel> listBanner) {
    return Container(
      width: double.infinity,
      color: Constant.color,
      child: GridView.count(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.all(20),
        scrollDirection: Axis.horizontal,
        crossAxisCount: 1,
          children: List.generate(listBanner.length, (index) {
        // children: List.generate(listBannerPromoTest.length, (index) {
          return
            Center(
              child: Container(
                  alignment: Alignment.center,
                  child:
                  SizedBox(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new DetailBanner(bannerModel: listBanner[index], keterangan: 'Promo')));
                          },
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2
                              )
                            ),
                            child: Image.network(listBanner[index].url, fit: BoxFit.contain),
                            // child: Image.asset(listBannerPromoTest[index]),
                          ),
                        ),
                      ],
                    )
                  )
              ),
            );
        })
      ),
    );
  }

}

launchWhatsApp(String kategori) async {
  String text="";
  if(kategori == "Klinik")
    text = "Halo, Saya Ingin Mendaftar Untuk Klinik Online";
  if(kategori == "Imunisasi")
    text = "Halo, Saya Ingin Mendaftar Untuk Imunisasi";
  if(kategori == "MCU")
    text = "Halo, Saya Ingin Mendaftar Untuk Medical Checkup";
  if(kategori == "General")
    text = "Halo, Saya Ingin Bertanya Mengenai Layanan di RS Dr Oen Solo Baru";
  final link = WhatsAppUnilink(
    phoneNumber: '+6282110103388',
    text: text,
  );
  await launch('$link');
}

Future<void> _launchURL(String url) async {
  final String link = url;
  if (await canLaunch(link)) {
      await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

