import 'package:flutter/material.dart';
import '../../provider/provider.dart';
import '../../util/util.dart';

class Tema extends ChangeNotifier {

  static Tema i = Tema();

  String? _tintDecColor;
  String? _primaryColor;

  Color get tintDecColor {
    final color = ClubeProvider.i.clube.secondaryColor;
    int? cod = int.tryParse(color, radix: 16);
    if (cod != null) return Color(cod);

    cod = int.tryParse(_tintDecColor??'', radix: 16);
    if (cod != null) return Color(cod);

    return const Color.fromRGBO(195, 41, 14, 1);
  }

  Color get primaryColor {
    final color = ClubeProvider.i.clube.primaryColor;
    int? cod = int.tryParse(color, radix: 16);
    if (cod != null) return Color(cod);

    cod = int.tryParse(_primaryColor??'', radix: 16);
    if (cod != null) return Color(cod);


    return const Color.fromRGBO(243, 213, 0, 1);
  }

  Color get primaryColorLight => const Color.fromRGBO(243, 223, 100, 1.0);

  Color especialidadeColor(String area) {
    switch(area) {
      case 'ADRA':
        return const Color.fromRGBO(46, 46, 120, 1);
      case 'ARTES E HABILIDADES MANUAIS':
        return const Color.fromRGBO(87, 143, 204, 1);
      case 'ARTES MANUAIS':
        return const Color.fromRGBO(45, 45, 119, 1);
      case 'ATIVIDADES AGRÍCOLAS':
        return const Color.fromRGBO(88, 51, 35, 1);
      case 'ATIVIDADES MISSIONÁRIAS':
        return const Color.fromRGBO(45, 45, 119, 1);
      case 'ATIVIDADES PROFISSIONAIS':
        return const Color.fromRGBO(233, 26, 44, 1);
      case 'ATIVIDADES RECREATIVAS':
        return const Color.fromRGBO(36, 145, 64, 1);
      case 'CIÊNCIA E SAÚDE':
        return const Color.fromRGBO(83, 38, 93, 1.0);
      case 'ESTUDO DA NATUREZA':
        return const Color.fromRGBO(253, 253, 254, 1.0);
      case 'ESTUDOS DA NATUREZA':
        return const Color.fromRGBO(253, 253, 254, 1.0);
      case 'HABILIDADES DOMÉSTICAS':
        return const Color.fromRGBO(243, 234, 36, 1.0);
      case 'MESTRADO':
        return const Color.fromRGBO(46, 45, 121, 1.0);

      default: return Colors.white;
    }
  }

  Color especialidadeBorderColor(String area) {
    switch(area) {
      case 'ADRA':
        return const Color.fromRGBO(226, 231, 225, 1);
      case 'ARTES E HABILIDADES MANUAIS':
        return const Color.fromRGBO(43, 51, 54, 1);
      case 'ARTES MANUAIS':
        return const Color.fromRGBO(226, 227, 61, 1);
      case 'ATIVIDADES AGRÍCOLAS':
        return const Color.fromRGBO(235, 233, 54, 1);
      case 'ATIVIDADES MISSIONÁRIAS':
        return const Color.fromRGBO(214, 225, 214, 1);
      case 'ATIVIDADES PROFISSIONAIS':
        return const Color.fromRGBO(69, 57, 59, 1);
      case 'ATIVIDADES RECREATIVAS':
        return const Color.fromRGBO(58, 179, 161, 1.0);
      case 'CIÊNCIA E SAÚDE':
        return const Color.fromRGBO(214, 216, 205, 1.0);
      case 'ESTUDO DA NATUREZA':
        return const Color.fromRGBO(114, 181, 69, 1.0);
      case 'ESTUDOS DA NATUREZA':
        return const Color.fromRGBO(243, 233, 84, 1.0);
      case 'HABILIDADES DOMÉSTICAS':
        return const Color.fromRGBO(61, 66, 149, 1.0);
      case 'MESTRADO':
        return const Color.fromRGBO(104, 200, 207, 1.0);

      default: return Colors.white;
    }
  }

  bool especialidadeLightText(String area) {
    switch(area) {
      case 'ADRA':
      case 'ARTES E HABILIDADES MANUAIS':
      case 'ARTES MANUAIS':
      case 'ATIVIDADES AGRÍCOLAS':
      case 'ATIVIDADES MISSIONÁRIAS':
      case 'ATIVIDADES PROFISSIONAIS':
      case 'ATIVIDADES RECREATIVAS':
      case 'CIÊNCIA E SAÚDE':
      case 'MESTRADO':
        return true;
    }
    return false;
  }

  void notify() {
    notifyListeners();
  }

  void load() {
    _tintDecColor = pref.getString('_tintDecColor');
    _primaryColor = pref.getString('_primaryColor');
  }

  void saveColors(String p, String s) {
    pref.setString('_primaryColor', p);
    pref.setString('_tintDecColor', s);
  }
}