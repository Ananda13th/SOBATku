import 'package:flutter/material.dart';
import 'package:sobatku/page/sign_in.dart';
import 'constant.dart';

class LoginAlert {
  static Future<void> alertBelumLogin(BuildContext context) async {
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
                              child: Center(child: const Text('MASUK', style: TextStyle(fontWeight: FontWeight.bold)))
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
}