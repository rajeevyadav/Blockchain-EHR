import 'package:flutter/material.dart';
import 'package:patient/widgets/custom_button.dart';

import 'custom_text.dart';

class CustomAlertDialog extends StatelessWidget {
  final bool success;
  final String message;
  CustomAlertDialog({this.success, this.message});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: Container(
        height: height * 0.33,
        width: width * 0.33,
        child: Image.asset(
          success ? 'assets/success.png' : 'assets/error.png',
          fit: BoxFit.contain,
        ),
      ),
      content: CustomText(
        message,
        alignment: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      actionsPadding: EdgeInsets.all(10),
      actions: [
        CustomButton(
          'Dismiss',
          () {
            Navigator.of(context).pop();
          },
          backgroundcolor: Colors.black,
        )
      ],
    );
  }
}
