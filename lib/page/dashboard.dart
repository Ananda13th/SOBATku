import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_indicator/scroll_indicator.dart';
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
import 'package:cached_network_image/cached_network_image.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeViewState();
  }
}

class HomeViewState extends State<HomeView> {
  List<String> listDokterFavorit =[""];
  ScrollController gridController = ScrollController();
  int currentIndex = 0;
  late BannerService bannerService;
  late DokterFavoritService dokterFavoritService;
  late SpesialisasiService spesialisasiService;
  late JadwalService jadwalService;
  BannerModel temp = new BannerModel(url: "https://c.tenor.com/I6kN-6X7nhAAAAAj/loading-buffering.gif", judul:"", urlDetailBanner:"", urlSumberBerita:"", deskripsi: "", keterangan: "");
  late List<String> listBannerPromoTest = ["assets/images/promo1.jpeg","assets/images/promo2.jpeg", "assets/images/promo3.jpeg", "assets/images/promo4.jpeg", "assets/images/promo5.jpeg", "assets/images/promo6.jpeg"];
  late List<String> listBannerTest = ["assets/images/Banner.png"];
  late List<BannerModel> listBanner = [temp];
  List<BannerModel> listBannerUtama = [];
  List<BannerModel> listBannerPromo = [];
  List<BannerModel> listBannerBerita = [];
  final CarouselController _controller = CarouselController();
  late ScrollController _scrollController;
  bool dibawah = false;
  double paddingFab = 45;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    bannerService = BannerService();
    spesialisasiService = SpesialisasiService();
    dokterFavoritService = DokterFavoritService();
    bannerService.getBanner().then((value) {
      if(mounted)
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

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/error_picture.jpg"), context);

    return FutureBuilder<bool>(
        future: checkConnectivity(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data == true)
              return Sizer(
                  builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
                    return GestureDetector(
                      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        body: NotificationListener<ScrollEndNotification>(
                          onNotification: (scrollEnd) {
                            var metrics;
                            metrics = scrollEnd.metrics;
                            if (metrics.atEdge) {
                              if (metrics.pixels == 0)
                                setState(() {
                                  dibawah = false;
                                });
                              else
                                setState(() {
                                  dibawah = true;
                                });
                            }
                            return true;
                          },
                          child: CustomScrollView(
                              controller: _scrollController,
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
                                          height: 17.h,
                                          width: 30.h,
                                          child: Image.asset("assets/images/LogoRSBanner.png", fit: BoxFit.scaleDown)
                                      )
                                    ],
                                  ),
                                  bottom: AppBar(
                                      backgroundColor: Constant.color,
                                      title: Container(
                                          width: 65.w,
                                          height: 3.h,
                                          /** Bila Search Bar, height:5.h **/
                                          child: Text("Selamat Datang di SOBAtku", style: TextStyle(fontSize: 18))
                                        /** FUNGSI GLOBAL SEARCH BELUM ADA **/
                                        // child: TextField(
                                        //   decoration: InputDecoration(
                                        //     hintText: "Cari Layanan...",
                                        //     contentPadding: EdgeInsets.zero,
                                        //     prefixIcon: Icon(Icons.search),
                                        //     border: OutlineInputBorder(
                                        //       borderRadius: BorderRadius.circular(20.0),
                                        //     ),
                                        //     filled: true,
                                        //     fillColor: Colors.white,
                                        //   ),
                                        // ),
                                      ),
                                      actions: [
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new DaftarNotifikasi()));
                                                },
                                                icon: Icon(Icons.notification_important)
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      new MaterialPageRoute(builder: (context) => new FavoriteList()));
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
                                        fit: BoxFit.fill)
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(height: 5,),
                                        Container(
                                            color: Colors.transparent,
                                            height: 35.h,
                                            child: buatCarousel(listBannerUtama)
                                        ),
                                        SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  color: Colors.transparent,
                                                  height: 29.h,
                                                  child: tampilanMenuGeser(context)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Center(
                                          child: ScrollIndicator(
                                            scrollController: gridController,
                                            width: 20,
                                            height: 10,
                                            indicatorWidth: 20,
                                            decoration: BoxDecoration(
                                                color: Colors.lightGreen,
                                                borderRadius: BorderRadius.all(Radius.circular(10)
                                                )
                                            ),
                                            indicatorDecoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                              color: Constant.color,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Text("Promo dan Layanan", style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 22)),
                                        SizedBox(height: 5),
                                        Container(
                                            color: Colors.transparent,
                                            height: 27.h,
                                            child: promoLayanan(listBannerPromo)
                                        ),
                                        SizedBox(height: 15),
                                        Text("Berita Kesehatan", style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 22)),
                                        SizedBox(height: 5),
                                        Container(
                                            color: Colors.transparent,
                                            height: 35.h,
                                            child: buatCarousel(listBannerBerita)
                                        ),
                                        SizedBox(height: 10),
                                        Text("Hubungi dan Ikuti Kami", style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 18)),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(child:  menuMediaSosial()),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ]
                          ),
                        ),
                        floatingActionButton: Padding(
                          padding: EdgeInsets.only(bottom: paddingFab),
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.black54,
                            onPressed: (){
                              !dibawah ?
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 500),
                              )
                                  :
                              _scrollController.animateTo(
                                _scrollController.position.minScrollExtent,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 500),
                              );
                            },
                            child: !dibawah ? Icon(Icons.keyboard_arrow_down_outlined) : Icon(Icons.keyboard_arrow_up_outlined),
                          ),
                        ),
                      ),
                    );
                  }
              );
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
    );
  }

  /// ------------ CAROUSEL ------------ ///

  Widget buatCarousel(List<BannerModel> bannerList) {
    return Column(
      children: [
        CarouselSlider(
          items: bannerList.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: InkWell(
                      onTap: (){
                        Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new DetailBanner(bannerModel: item, keterangan: 'Banner')));
                      },
                      child: item.deskripsi == "" ?
                      CachedNetworkImage(
                        imageUrl: item.url,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Center(
                            child: SizedBox(
                                height: 100,
                                width: 100,
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color : Constant.color
                                )
                            ),
                          ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ) :
                      CachedNetworkImage(
                        imageUrl: item.url,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Center(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                                color : Constant.color
                              )
                            ),
                          ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )
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
        /** INDEX BULLET CAROUSEL **/
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerList.asMap().entries.map((entry) {
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

  /// ------------ Grid Menu Geser------------ ///

  Widget tampilanMenuGeser (BuildContext context) {
    double cardHeight;
    double cardWidth = 50.w;
    if(MediaQuery.of(context).size.width < 410)
      cardHeight = 34.h;
    else
      cardHeight = 36.h;
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
      controller: gridController,
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
                          Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new DaftarDokter()));
                        if(index == 1)
                          bukaWhatsApp("Imunisasi");
                        if(index == 2)
                          bukaWhatsApp("MCU");
                        if(index == 3)
                          bukaWhatsApp("Klinik");
                        if(index == 4)
                          _launchURL("https://daftar.droensolobaru.com/booking/pribadi");
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

  /// ------------ Menu Media Sosial------------ ///

  Widget menuMediaSosial () {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, right: 5.w),
      child: Row(
        children: [
          _icon(0, text: "Web", image: "assets/icons/WEB.png"),
          SizedBox(
            width: 10.w,
          ),
          _icon(1, text: "Instagram", image: "assets/icons/IG.png"),
          SizedBox(
            width: 10.w,
          ),
          _icon(2, text: "WhatsApp", image: "assets/icons/WA.png"),
          SizedBox(
            width: 10.w,
          ),
          _icon(3, text: "Location", image: "assets/icons/LOC.png")
        ],
      ),
    );
  }

  Widget _icon(int index, {required String text, required String image}) {
    return InkResponse(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Container(
              width: 7.h,
              height: 7.h,
              child: Image.asset(image)
            ),
            Text(text, style: TextStyle(color:Colors.transparent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      onTap: (){
        if(index == 0) {
          _launchURL("https://droensolobaru.com/");
        }
        if(index == 1) {
          _launchURL("https://instagram.com/droen_solobaru/");
        }
        if(index == 2) {
          bukaWhatsApp("General");
        }
        if(index == 3) {
          _launchURL("https://www.google.com/maps/place/RS+Dr.+OEN+SOLO+BARU/@-7.606801,110.7957897,17z/data=!3m1!4b1!4m5!3m4!1s0x2e7a3e2fabec7177:0xc073cd7a8c61f913!8m2!3d-7.606801!4d110.7979784");
        }
      },
    );
  }

  Widget promoLayanan(List<BannerModel> listBanner) {
    return Container(
      width: double.infinity,
      color: Constant.color,
      child: GridView.count(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.only(top: 15),
        scrollDirection: Axis.horizontal,
        crossAxisCount: 1,
          children: List.generate(listBanner.length, (index) {
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
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4
                                )
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child:  CachedNetworkImage(
                                  imageUrl: listBanner[index].url,
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                      Center(
                                        child: SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: CircularProgressIndicator(
                                              value: downloadProgress.progress,
                                              color : Constant.color
                                            )
                                        ),
                                      ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                )
                              ),
                              // child: Image.asset(listBannerPromoTest[index]),
                            ),
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

  /// ------------ Ambil Data Dokter Favorit------------ ///

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

}

Future<bool> checkConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none)
    return false;
  else
    return true;
}

bukaWhatsApp(String kategori) async {
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

