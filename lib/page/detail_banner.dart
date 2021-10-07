import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/model/banner.dart';

class DetailBanner extends StatelessWidget {

  DetailBanner({Key? key, required this.bannerModel});

  final BannerModel bannerModel;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Constant.color,
          ),
          body: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                              height: 35.h,
                              child: Image.network(bannerModel.url, fit: BoxFit.fill)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(bannerModel.deskripsi, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
