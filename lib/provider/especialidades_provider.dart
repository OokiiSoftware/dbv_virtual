import '../model/model.dart';
import '../util/util.dart';
import '../res/res.dart';
import 'provider.dart';

class EspecialidadesProvider extends ProviderBase1<Especialidade> {

  EspecialidadesProvider._();
  factory EspecialidadesProvider() => i;
  static final EspecialidadesProvider i = EspecialidadesProvider._();

  @override
  String get pathKey => 'especialidades_v2';

  @override
  Future<void> loadOnline() async {
    if (loadedOnline) return;
    await refresh();
    loadedOnline = true;
  }

  @override
  Future<void> refresh() async {
    verificarInternet();

    final res = await FirebaseProvider.i.database
        .child(PrefKey.app)
        .child(pathKey)
        .child('lista').get();

    data.clear();
    data.addAll(fromJsonList(res.value));

    notifyListeners();
    saveLocal();
  }

  Future<void> addAll(Map<String, Especialidade> values) async {
    verificarInternet();

    await FirebaseProvider.i.database
        .child(PrefKey.app)
        .child(pathKey)
        .child('lista')
        .update(Util.mapObjectToJson(values));

    data.addAll(values);
    notifyListeners();
  }

  Future<void> addAllRequisitos(Map<String, String> values) async {
    verificarInternet();

    await FirebaseProvider.i.database
        .child(PrefKey.app)
        .child(pathKey)
        .child('requisitos')
        .update(values);

    notifyListeners();
  }


  List<Especialidade> query(String value) {
    value = Util.toQuery(value);

    List<Especialidade> items = [];

    for (var item in list) {
      final textQuery = Util.toQuery(item.nome);
      if (textQuery.contains(value)) {
        items.add(item);
      }
    }

    items.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    return items;
  }


  List<EspecialidadeArea> get areas {
    List<String> keys = [];
    List<EspecialidadeArea> items = [];

    for (var item in list) {
      if (!keys.contains(item.area)) {
        keys.add(item.area);
        items.add(EspecialidadeArea(
          id: item.idName.substring(0, 2),
          nome: item.area,
          color: Tema.i.especialidadeColor(item.area),
          borderColor: Tema.i.especialidadeBorderColor(item.area),
          lightText: Tema.i.especialidadeLightText(item.area),
        ));
      }
    }

    return items;
  }

  Future<Especialidade?> getById(String id, [bool forceUpdate = false]) async {
    verificarInternet();

    final item = data[id];
    try {
      if (item == null) throw 'Especialidade não encontrada';

      if (item.text.isNotEmpty && !forceUpdate) return item;

      final res = await FirebaseProvider.i.database
          .child(PrefKey.app)
          .child(pathKey)
          .child('requisitos')
          .child(id).get();

      item.text = res.value ?? '';

      notifyListeners();
      saveLocal();
    } catch(e) {
      log.e('EspecialidadesProvider', 'getById', id, e);
    }
    return item;
  }

  Future<Map<String, Especialidade>> getAllRequisitos() async {
    verificarInternet();

    try {
      final res = await FirebaseProvider.i.database
          .child(PrefKey.app)
          .child(pathKey)
          .child('requisitos')
          .get();

      Map map = res.value;
      map.forEach((key, value) {
        data[key]?.text = value.toString();
      });

      notifyListeners();
      saveLocal();
    } catch(e) {
      log.e('EspecialidadesProvider', 'getAllRequisitos', e);
    }
    return data;
  }

  List<Especialidade> getAllByType(String type) {
    return list.where((e) => e.area == type).toList();
  }

  void unselectAll() {
    for (var value in data.values) {
      value.selected = false;
    }
  }

  void setSelecteds(List<String> values) {
    for (var key in values) {
      data[key]?.selected = true;
    }
  }

  @override
  void saveLocal() {
    Map<String, dynamic> items = {};

    data.forEach((key, value) {
      items[key] = value.toJson();
    });

    database.child(pathKey).set(items);
  }

  @override
  void loadLocal() {
    if (loadedLocal) return;
    try {
      final res = database.child(pathKey).get();
      data.addAll(fromJsonList(res.value));
      notifyListeners();
    } catch(e) {
      log.e('loadLocal', e);
    }

    loadedLocal = true;
  }

  @override
  Map<String, Especialidade> fromJsonList(Map? map) {
    return Especialidade.fromJsonList(map);
  }

}
