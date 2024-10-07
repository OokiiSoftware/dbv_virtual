import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class FirebaseBase {
  static String _token = '';

  static Future<bool> Function() _onAuthExpired = () async => false;

  String get key;
  final List<String> localPath = [];

  String get path => localPath.join('/');

  @protected
  String get token => _token;
  String get url;

  Map<String, String>? get headers => null;
  Map<String, dynamic> get queryParameters;
  String? get queryPath => null;

  @protected
  Future<bool> Function() get relogin => _onAuthExpired;

  Uri get uri => Uri(
    scheme: 'https',
    host: url,
    path: queryPath,
    queryParameters: queryParameters,
  );

  Future<void> delete() async {
    var res = await http.delete(uri, headers: headers);
    if (semPermisao(res)) {
      if (await relogin()) {
        res = await http.delete(uri, headers: headers);
      }
    }
    verificarErro(res);
  }


  @protected
  void verificarErro(http.Response res) {
    if (res.body.toLowerCase().contains('permission denied')) {
      throw 'Sua sessão expirou';
    }

    if (res.body.toLowerCase().contains('error')) {
      throw {
        '\n\tkey': key,
        '\n\turl': uri.toString(),
        '\n\tpath': path,
        '\n\tdata': res.body,
      };
    }
  }

  @protected
  bool semPermisao(http.Response res) {
    return res.body.toLowerCase().contains('permission denied');
  }

  //region static methods

  static void setToken(String value) {
    _token = value;
  }

  static void authExpiredListner(Future<bool> Function() value) {
    _onAuthExpired = value;
  }

  //endregion

}