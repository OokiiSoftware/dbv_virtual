import '../service/service.dart';
import '../model/model.dart';
import '../util/util.dart';
import 'provider.dart';

class AgendaProvider extends ProviderBase1<Evento> {

  AgendaProvider._();
  static AgendaProvider i = AgendaProvider._();
  factory AgendaProvider() => AgendaProvider.i;

  @override
  String get pathKey => 'agenda_v2';

  @override
  Future<void> add(Evento value) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child('${value.from!.year}')
        .child(value.id)
        .set(value.toJson());

    super.add(value);
  }

  @override
  Future<void> remove(Evento value) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child('${value.from!.year}')
        .child(value.id)
        .delete();

    super.remove(value);
  }

  Future<void> addAll(List<Evento> values) async {
    verificarInternet();

    Map<int, Map<String, Evento>> anos = {};
    for (var value in values) {
      final ano = value.from!.year;
      if (!anos.containsKey(ano)) {
        anos[ano] = {};
      }
      anos[ano]![value.id] = value;
    }

    for (var ano in anos.keys) {
      await FirebaseProvider.i.database
          .child(ChildKeys.clubes)
          .child(clubeId)
          .child(pathKey)
          .child('$ano')
          .update(Util.mapObjectToJson(anos[ano]!));
    }

    for (var value in values) {
      data[value.id] = value;
    }
    notifyListeners();
    saveLocal();
  }


  @override
  Future<void> loadOnline([int ano = 0]) async {
    if (loadedOnline) return;
    await Future.wait([
      _loadAnos(),
      refresh(ano),
    ]);
    loadedOnline = true;
  }

  @override
  Future<void> refresh([int ano = 0]) async {
    verificarInternet();
    
    final res = await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child('$ano')
        .get();

    data.clear();
    data.addAll(Evento.fromJsonList(res.value));

    notifyListeners();
    saveLocal();
  }


  @override
  void saveLocal() {
    data.forEach((key, value) {
      var ano = value.from!.year;
      database.child(pathKey)
          .child('$ano')
          .child(key)
          .set(value.toJson());
    });
  }

  @override
  void loadLocal([int ano = 0]) {
    if (loadedLocal) return;
    loadLocalAnos();

    try {
      final res = database.child(pathKey)
          .child('$ano')
          .get();

      data.addAll(Evento.fromJsonList(res.value));
      notifyListeners();
    } catch(e) {
      log.e('loadLocal', e);
    }

    loadedLocal = true;
  }

  @override
  Map<String, Evento> fromJsonList(Map<dynamic, dynamic>? map) {
    return Evento.fromJsonList(map);
  }


  Future<void> _loadAnos() async {
    verificarInternet();

    final res = await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .get(DatabaseQuery(
      key: 'shallow',
      value: 'true',
      isParametro: true,
    ));

    Map map = res.value;

    for (var value in map.keys) {
      final ano = int.parse(value);
      if (!anosList.contains(ano)) {
        anosList.add(ano);
      }
    }

    notifyListeners();
    saveLocalAnos();
  }

  List<Evento> getByMother(int mes) {
    return list.where((e) => e.from!.month == mes).toList();
  }

  Map<String, List<Evento>> groupByMonth() {
    Map<String, List<Evento>> items = {};

    final list = data.values.toList();
    list.sort((a, b) => a.from!.month.compareTo(b.from!.month));

    for (var event in list) {
      if (!items.containsKey(event.month)) {
        items[event.month] = [];
      }

      items[event.month]!.add(event);
    }

    return items;
  }

}