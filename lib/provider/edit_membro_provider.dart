import '../service/service.dart';
import '../model/model.dart';
import '../util/util.dart';
import 'provider.dart';

class EditMembrosProvider extends ProviderBase1<Membro> {

  EditMembrosProvider._();
  factory EditMembrosProvider() => i;
  static final EditMembrosProvider i = EditMembrosProvider._();

  @override
  String get pathKey => 'membros_editados';

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
    value = value.toLowerCase();

    List<Membro> items = [];

    for (var item in list) {
      if (item.nomeUsuario.toLowerCase().contains(value)) {
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

  @override
  Map<String, Membro> fromJsonList(Map? map) {
    return Membro.fromJsonList(map);
  }
}