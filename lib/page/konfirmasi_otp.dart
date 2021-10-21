import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/helper/shared_preferences.dart';
import 'package:sobatku/page/sign_in.dart';
import 'package:sobatku/service/user_service.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class TampilanKonfirmasiPin extends StatefulWidget {
  final String? phoneNumber;
  TampilanKonfirmasiPin(this.phoneNumber);

  @override
  _TampilanKonfirmasiPinState createState() =>
      _TampilanKonfirmasiPinState();
}

class _TampilanKonfirmasiPinState extends State<TampilanKonfirmasiPin> {
  late UserService userService;
  late String bannedDate;
  bool showCountdown = false;
  TextEditingController textEditingController = TextEditingController();
  int clicked = 0;

  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 61;
  @override
  void initState() {
    userService = UserService();
    errorController = StreamController<ErrorAnimationType>();
    SharedPreferenceHelper.getBannedDate().then((value) {
      setState(() {
        bannedDate = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {},
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/Background.png"),
                  alignment: Alignment.center,
                  fit: BoxFit.cover
              )
          ),
          child: ListView(
            children: <Widget>[
              // SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Verifikasi Nomor HP',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: TextSpan(
                      text: "Kode Dikirim Ke Nomor ",
                      children: [
                        TextSpan(
                            text: "${widget.phoneNumber}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                      style: TextStyle(color: Colors.black54, fontSize: 15)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 30),
                    child: PinCodeTextField(
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Constant.color,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obscureText: false,
                      obscuringCharacter: '*',
                      blinkWhenObscuring: true,
                      animationType: AnimationType.fade,
                      validator: (v) {
                        if (v!.length < 6) {
                          return "Harap Masukan Kode OTP Yang Benar";
                        } else {
                          return null;
                        }
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                      ),
                      cursorColor: Colors.black,
                      animationDuration: Duration(milliseconds: 300),
                      errorAnimationController: errorController,
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      boxShadows: [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black12,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {
                        print("Completed");
                      },
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          currentText = value;
                        });
                      },
                      enablePinAutofill: true,
                      beforeTextPaste: (text) {
                        print("Allowing to paste $text");
                        return true;
                      },
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  hasError ? "*Please fill up all the cells properly" : "",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              showCountdown ?
              Center(
                child: CountdownTimer(
                  textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  endTime: endTime,
                  onEnd: () {
                    WidgetsBinding.instance!.addPostFrameCallback((_){
                      setState(() {
                        showCountdown = false;
                      });
                    });
                  },
                ),
              )
             :
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Tidak Menerima Kode Verifikasi? ",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      if(clicked == 3 || bannedDate == DateFormat("dd-MM-yyyy").format(DateTime.now()))
                        showToast('Maaf, Sudah Melebihi Batas Permintaan Kode.\nSilahkan Hubungi Pusat Informasi',
                          context: context,
                          textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
                          backgroundColor: Colors.red,
                          animation: StyledToastAnimation.scale,
                          reverseAnimation: StyledToastAnimation.fade,
                          position: StyledToastPosition.center,
                          animDuration: Duration(seconds: 1),
                          duration: Duration(seconds: 4),
                          curve: Curves.elasticOut,
                          reverseCurve: Curves.linear,
                        );
                      else {
                        userService.resendOtp(widget.phoneNumber.toString()).then((value) => snackBar(value));
                        WidgetsBinding.instance!.addPostFrameCallback((_){
                          setState(() {
                            endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 61;
                            showCountdown = true;
                            clicked++;
                            if(clicked == 3)
                              SharedPreferenceHelper.addBannedDate();
                          });
                        });
                      }
                    },
                    child: Text(
                      "Kirim Ulang",
                      style: TextStyle(
                          color: Constant.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    )
                  )
                ],
              ),
              SizedBox(
                height: 14,
              ),
              Container(
                margin:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                child: ButtonTheme(
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      formKey.currentState!.validate();
                      // conditions for validating
                      if (currentText.length != 6 ) {
                        errorController!.add(ErrorAnimationType.shake); // Triggering error shake animation
                        setState(() => hasError = true);
                      } else {
                        userService.verifyOtp(widget.phoneNumber.toString(), currentText).then((value) {
                          if(value == "Kode OTP Salah") {
                            errorController!.add(ErrorAnimationType.shake);
                            textEditingController.clear();
                            setState(() {
                              hasError = true;
                              snackBar(value);
                            });
                          } else {
                            setState(() {
                              hasError = false;
                              snackBar(value);
                            });
                            Future.delayed(Duration(seconds: 3)).then( (value) =>
                                Navigator.of(context).pushReplacement(
                                    new MaterialPageRoute(builder: (context) => new SignIn()))
                            );
                          }
                        });
                      }
                    },
                    child: Center(
                        child: Text(
                          "Verifikasi Kode OTP".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Constant.color,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.shade200,
                          offset: Offset(1, -2),
                          blurRadius: 5),
                      BoxShadow(
                          color: Colors.green.shade200,
                          offset: Offset(-1, 2),
                          blurRadius: 5)
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}