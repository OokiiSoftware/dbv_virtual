import 'model.dart';

class Classe extends ItemModel {

  @override
  String get id {
    if (url.isEmpty) {
      return name.replaceAll(' ', '');
    }
    return url
        .replaceAll('/', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll(':', '');
  }

  String name = '';
  String url = '';
  int items = 0;
  double percent = 0;

  final List<Atividade> atividades = [];

  Classe({
    this.name = '',
    this.url = '',
    this.items = 0,
    this.percent = 0,
  });
  
  Classe.fromJson(Map? map) :
        name = map?['name'] ?? '',
        url = map?['url'] ?? '',
        items = map?['items'] ?? 0,
        percent = map?['percent'] ?? 0 {
    List atv = map?['atividades'] ?? [];
    for (var value in atv) {
      atividades.add(Atividade.fromJson(value));
    }
  }

  static Map<String, Classe> fromJsonList(Map? map) {
    Map<String, Classe> items = {};

    map?.forEach((key, value) {
      items[key] = Classe.fromJson(value);
    });

    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'items': items,
    'percent': percent,
    'atividades': _atividadesToJson(),
  };

  List<Map> _atividadesToJson() {
    List<Map> items = [];
    for (var e in atividades) {
      items.add(e.toJson());
    }
    return items;
  }

  @override
  String toString() => toJson().toString();

}