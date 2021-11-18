import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/page/sign_in.dart';

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
                                        child: Text("Lanjut Ke Aplikasi"),
                                      ),
                                    ),
                                  ),
                                  // ),
                                  onPressed: () {
                                   tampilDialog(context);
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

  Future<void> tampilDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atur Ulang Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Untuk Pengguna Lama'),
                Text('Harap Atur Ulang Password'),
                Text('Untuk Masuk ke Aplikasi'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                    new MaterialPageRoute(builder: (context) => new SignIn()));
              },
            ),
          ],
        );
      },
    );
  }
}