import 'package:dbv_virtual/util/util.dart';
import 'package:flutter/material.dart';
import '../model/model.dart';
import '../service/service.dart';
import 'provider.dart';

abstract class IProvider extends ChangeNotifier {
  final log = const Log('IProvider');

  bool loadedOnline = false;
  bool loadedLocal = false;

  String get clubeId => FirebaseProvider.i.clubeId;

  void verificarInternet() {
    if (InternetProvider.i.disconnected) throw 'Sem conexão com a internet';
  }

  void verificarId(ItemModel value) {
    if (value.id.isEmpty) throw 'id inválido';
  }

  void saveLocal();
  void loadLocal();

  Future<void> close();
}

abstract class _ProviderBase<I> extends IProvider {

  String get pathKey;

  final List<int> anosList = [];

  void saveLocalAnos() {
    database.child('${pathKey}_anos').set([...anosList]);
  }
  void loadLocalAnos() {
    try {
      final res = database.child('${pathKey}_anos').get(def: []);
      anosList.clear();
      for (var value in res.value) {
        anosList.add(value);
      }
      notifyListeners();
    } catch(e) {
      log.e('loadLocalAnos', e);
    }
  }

  Map<String, I> fromJsonList(Map? map);

  @override
  Future<void> close() async {
    anosList.clear();
  }
}

abstract class ProviderBase1<I extends ItemModel> extends _ProviderBase<I> {

  final Map<String, I> data = {};

  List<I> get list => data.values.toList();

  Future<void> add(I value) async {
    data[value.id] = value;
    notifyListeners();
    saveLocal();
  }

  Future<void> remove(I value) async {
    data.remove(value.id);
    notifyListeners();
    saveLocal();
  }

  Future<void> loadOnline() async {
    if (loadedOnline) return;
    await refresh();
    loadedOnline = true;
  }

  Future<void> refresh();

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
  Future<void> close() async {
    data.clear();
    loadedOnline = false;
    super.close();
  }
}

abstract class ProviderBase2<I extends ItemModel2> extends _ProviderBase<I> {

  final Map<String, Map<String, I>> data = {};

  List<Map<String, I>> get list => data.values.toList();

  Future<void> add(I value, String uid) async {
    verificarInternet();
    verificarId(value);

    final ano = value.ano;

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child('$ano')
        .child(uid)
        .child(value.id)
        .set(value.toJson());

    if (!data.containsKey(uid)) {
      data[uid] = {};
    }

    if (!anosList.contains(ano)) {
      anosList.add(ano);
    }

    data[uid]![value.id] = value;
    notifyListeners();
    saveLocal();
  }

  Future<void> remove(I value, String uid) async {
    verificarInternet();
    final ano = value.ano;

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child('$ano')
        .child(uid)
        .child(value.id)
        .delete();

    data[uid]?.remove(value.id);
    notifyListeners();
    saveLocal();
  }

  List<I> getByUid(String uid) {
    return data[uid]?.values.toList() ?? [];
  }

  Future<void> loadOnline(int ano) async {
    if (loadedOnline) return;
    await _loadAnos();
    await refresh(ano);
    loadedOnline = true;
  }

  Future<void> refresh(int ano) async {
    verificarInternet();

    final res = await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child('$ano')
        .get();

    data.clear();

    Map map = res.value;
    map.forEach((key, value) {
      data[key] = fromJsonList(value);
    });

    notifyListeners();
    saveLocal();
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

  @override
  void saveLocal() {
    data.forEach((key, value) {
      value.forEach((key2, value) {
        database.child(pathKey)
            .child('${value.ano}')
            .child(key)
            .child(key2)
            .set(value.toJson());
      });
    });
  }

  @override
  void loadLocal([int ano = 0]) {
    if (loadedLocal) return;
    loadLocalAnos();
    try {
      final res = database.child(pathKey).child('$ano').get(def: {});

      Map map = res.value;
      map.forEach((key, value) {
        data[key] = fromJsonList(value);
      });

      notifyListeners();
    } catch(e) {
      log.e('loadLocal', e);
    }

    loadedLocal = true;
  }

  @override
  Future<void> close() async {
    data.clear();
    loadedOnline = false;
    super.close();
  }
}