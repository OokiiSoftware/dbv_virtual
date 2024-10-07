import 'package:flutter/material.dart';

class Navigate {
  static Future<dynamic> push(BuildContext context, Widget widget, {bool fullscreenDialog = false}) async {
    return await Navigator.push(context, MaterialPageRoute(
      builder: (context) => widget,
      fullscreenDialog: fullscreenDialog,
    ));
  }
}