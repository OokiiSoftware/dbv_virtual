import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

SharedPref get pref => SharedPref.pref;

class SharedPref {
  late SharedPreferences _pref;

  static SharedPref pref = SharedPref();

  void setString(String key, String? value) => _pref.setString(key, value ?? '');
  void setInt(String key, int? value) => _pref.setInt(key, value ?? 0);
  void setDouble(String key, double? value) => _pref.setDouble(key, value ?? 0);
  void setBool(String key, bool? value) => _pref.setBool(key, value ?? false);
  void setListString(String key, List<String>? value) => _pref.setStringList(key, value ?? []);
  void setObject(String key, Map<String, dynamic>? value) => _pref.setString(key, jsonEncode(value ?? ''));

  String getString(String key, {String def = ''}) => _pref.getString(key) ?? def;
  int getInt(String key, {int def = 0}) => _pref.getInt(key) ?? def;
  double getDouble(String key, {double def = 0}) => _pref.getDouble(key) ?? def;
  bool getBool(String key, {bool def = false}) => _pref.getBool(key) ?? def;
  List<String>? getListString(String key, {List<String>? def}) => _pref.getStringList(key) ?? def;
  Map<String, dynamic>? getObject(String key, {Map<String, dynamic>? def}) {
    if (contains(key)) {
      return jsonDecode(_pref.getString(key) ?? '') ?? def;
    }
    return def;
  }

  void remove(String key) => _pref.remove(key);

  bool contains(String key) => _pref.containsKey(key);

  Future<void> clear() async => await _pref.clear();

  Future<void> load() async {
    _pref = await SharedPreferences.getInstance();
  }
}

class PrefKey {
  static const listMode = 'listMode';

  static const userEmail = 'trfgioij';
  static const userCodigo = 'egeilkijt';
  static const userAno = 'iufergef';

  static const userLogin = 'urfdsdfge';
  static const userSenha = 'uiuoerfgf';

  static const userEmailInstane = 'trfgioifj';
  static const userSenhaInstane = 'egeilkdijt';
  static const userAnoInstane = 'iufergesf';

  static const administrativo = 'sdgfhferth';
  static const biblioteca = 'biblioteca';
  static const databaseVersion = 'databaseVersion_3';
  static const app = 'app';
  static const eventosShowAll = 'dfhgdsrty';
  static const starsCount = 're56768if';
}