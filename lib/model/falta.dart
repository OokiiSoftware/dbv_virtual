import '../util/util.dart';
import 'model.dart';

class Falta extends ItemModel2 {

  String justificativa = '';
  int data = 0;

  Falta({this.justificativa = '', this.data = 0});

  Falta.fromJson(Map? map) :
        justificativa = map?['justificativa'] ?? '',
        data = map?['data'] ?? 0;

  static Map<String, Falta> fromJsonList(Map? map) {
    Map<String, Falta> items = {};

    map?.forEach((key, value) {
      items[key] = Falta.fromJson(value);
    });

    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'justificativa': justificativa,
    'data': data,
  };


  // Formato mês-dia
  @override
  String get id {
    if (data == 0) return '';

    return Formats.convertTime(data);
  }

  DateTime get datetime => DateTime.fromMillisecondsSinceEpoch(data);

  String get dataText {
    var sp = Formats.convertTime(data).split('-');

    int mes = int.parse(sp[0]);
    int dia = int.parse(sp[1]);

    var diaS = dia.toString();
    if (diaS.length == 1) diaS = '0$dia';

    return '$diaS de ${Formats.intToMes(mes)}';
  }

  Falta copy() => Falta.fromJson(toJson());

  @override
  int get ano => datetime.year;
}