import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../constant/color.dart';

abstract class ApplicationSnackBar {
  static showSnackBarWithMessage(
      {required BuildContext context,
      required String title,
      required String message,
      required bool isValid,
      required Function() onDone}) async {
    return Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      messageText: Text(
        message,
        style:
            Theme.of(context).textTheme.caption?.copyWith(color: Colors.white),
      ),
      title: title,
      duration: const Duration(seconds: 2),
      backgroundGradient: (isValid)
          ? const LinearGradient(stops: [
              0.3,
              1
            ], colors: [
              Color(ApplicationColor.primarycolor),
              Color(ApplicationColor.deepBlueBtn)
            ])
          : null,
      backgroundColor: (!isValid)
          ? const Color(ApplicationColor.sure)
          : const Color(ApplicationColor.deepBlueBtn),
      boxShadows: const [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3.0, 3.0),
          blurRadius: 3,
        )
      ],
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    )..show(context).then(onDone());
  }
}
