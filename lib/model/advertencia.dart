import '../util/util.dart';
import 'model.dart';

class Advertencia extends ItemModel2 {

  @override
  String id = '';
  String descricao = '';
  String punicao = '';
  int data = 0;

  Advertencia({this.id = '', this.descricao = '', this.punicao = '', this.data = 0});

  Advertencia.fromJson(Map? map) :
        id = map?['id'] ?? '',
        descricao = map?['descricao'] ?? '',
        punicao = map?['punicao'] ?? '',
        data = map?['data'] ?? 0;

  static Map<String, Advertencia> fromJsonList(Map? map) {
    Map<String, Advertencia> items = {};

    map?.forEach((key, value) {
      items[key] = Advertencia.fromJson(value);
    });

    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'descricao': descricao,
    'punicao': punicao,
    'data': data,
  };


  String get dataText {
    var sp = Formats.convertTime(data).split('-');

    int mes = int.parse(sp[0]);
    int dia = int.parse(sp[1]);

    var diaS = dia.toString();
    if (diaS.length == 1) diaS = '0$dia';

    return '$diaS de ${Formats.intToMes(mes)}';
  }

  DateTime get datetime => DateTime.fromMillisecondsSinceEpoch(data);


  Advertencia copy() => Advertencia.fromJson(toJson());

  @override
  int get ano =>datetime.year;
}