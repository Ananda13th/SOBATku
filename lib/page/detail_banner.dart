import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/model/banner.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailBanner extends StatelessWidget {

  DetailBanner({Key? key, required this.bannerModel, required this.keterangan});

  final BannerModel bannerModel;
  /// Keterangan Ada 2, Banner atau "" ///
  final String keterangan;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Constant.color,
            title: Text(bannerModel.judul),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50.h,
                              child: GestureDetector(
                                onTap:() {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    if( keterangan == "Banner")
                                      return DetailScreen(image: bannerModel.urlDetailBanner.toString());
                                    return DetailScreen(image: bannerModel.url);
                                  }));
                                },
                                child: CachedNetworkImage(
                                  imageUrl: keterangan == "Banner" ? bannerModel.urlDetailBanner.toString() : bannerModel.url,
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
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(bannerModel.deskripsi, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,), textAlign: TextAlign.justify),
                            TextButton(
                              onPressed: (){
                                if(bannerModel.urlSumberBerita != "")
                                  _launchURL(bannerModel.urlSumberBerita.toString());
                              },
                              child: bannerModel.urlSumberBerita != "" ? Text("Lihat Selengkapnya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)) : Text(""))
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}

Future<void> _launchURL(String url) async {
  final String link = url;
  if (await canLaunch(link)) {
    await launch(url, forceWebView: true, enableJavaScript: true);
  } else {
    throw 'Could not launch $url';
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key, required this.image}) : super(key: key);
  final String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.arrow_back, color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          color: Colors.black,
          child: PhotoView.customChild(
            child: CachedNetworkImage(
              imageUrl: image,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.contain
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
            ),
            minScale: PhotoViewComputedScale.contained * 1,
          ),
        )
      ),
    );
  }
}
