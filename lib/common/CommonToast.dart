import 'package:flutter/material.dart';
import 'package:openimis_web_app/utils/toast_helper.dart';

//Toast names similar to bootstrap
void ToastDanger(argMessage){
  ToastHelper.showToast(
      msg: argMessage,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

void ToastSuccess(argMessage){
  ToastHelper.showToast(
      msg: argMessage,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
