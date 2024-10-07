import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../util/util.dart';

class InternetProvider extends ChangeNotifier {

  InternetProvider._();
  factory InternetProvider() => i;
  static final InternetProvider i = InternetProvider._();

  final _net = InternetConnection();

  void Function()? onConnect;
  void Function()? onDisconnect;

  bool connected = false;
  bool get disconnected => !connected;

  Future<void> init() async {
    _net.onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          connected = true;
          onConnect?.call();
          break;
        case InternetStatus.disconnected:
          connected = false;
          onDisconnect?.call();
          break;
      }
      notifyListeners();
    });

    connected = await _net.hasInternetAccess;
  }

  static void showMsgNoConnect() {
    Log.snack('Sem conexão com a internet', isError: true);
  }
}