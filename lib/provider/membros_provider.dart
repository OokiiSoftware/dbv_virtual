import '../service/service.dart';
import '../model/model.dart';
import '../util/util.dart';
import 'provider.dart';

class MembrosProvider extends ProviderBase1<Membro> {

  MembrosProvider._();
  factory MembrosProvider() => i;
  static final MembrosProvider i = MembrosProvider._();

  @override
  String get pathKey => 'membros';

  @override
  Future<void> add(Membro value) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child(value.id)
        .set(value.toJson());

    super.add(value);
  }

  @override
  Future<void> remove(Membro value) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child(value.id)
        .delete();

    super.remove(value);
  }


  Future<void> addAll(List<Membro> values) async {
    verificarInternet();

    Map<String, Membro> items = {};

    for (var value in values) {
      items[value.id] = value;
    }

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .update(Util.mapObjectToJson(items));

    data.addAll(items);
    notifyListeners();
    saveLocal();
  }


  List<Membro> query(String value) {
    value = Util.toQuery(value);

    List<Membro> items = [];

    for (var item in list) {
      final textQuery = Util.toQuery(item.nomeUsuario);
      if (textQuery.contains(value)) {
        items.add(item);
      }
    }

    return items;
  }

  @override
  Future<void> refresh() async {
    verificarInternet();

    final res = await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .get();

    data.clear();
    data.addAll(Membro.fromJsonList(res.value));

    notifyListeners();
    saveLocal();
  }

  void setSelectedAll(bool value) {
    for (var e in list) {
      e.selected = value;
    }
  }

  @override
  Map<String, Membro> fromJsonList(Map? map) {
    return Membro.fromJsonList(map);
  }
}