
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class ToastNotification {
  // static Color color = Color.fromARGB(255,11,128,75);
  static ToastFuture showNotification (String text, BuildContext buildContext, Color color) {
    return showToast(
      text,
      context: buildContext,
      textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
      backgroundColor: color,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.center,
      animDuration: Duration(seconds: 1),
      duration: Duration(seconds: 2),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }
}