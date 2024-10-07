import '../../provider/provider.dart';
import '../../util/util.dart';
import '../model/model.dart';

class LivrariaProvider extends BibliotecaProviderBase {

  LivrariaProvider._();
  factory LivrariaProvider() => i;
  static final LivrariaProvider i = LivrariaProvider._();

  @override
  String get pathKey => '${PrefKey.biblioteca}/livraria';

}

class ManuaisProvider extends BibliotecaProviderBase {

  ManuaisProvider._();
  factory ManuaisProvider() => i;
  static final ManuaisProvider i = ManuaisProvider._();

  @override
  String get pathKey => '${PrefKey.biblioteca}/manuais';

}


abstract class BibliotecaProviderBase extends ProviderBase1<Livro> {

  @override
  Future<void> add(Livro value) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(PrefKey.app)
        .child(pathKey)
        .child(value.id)
        .set(value.toJson());

    super.add(value);
  }

  @override
  Future<void> remove(Livro value) async {
    verificarInternet();
    verificarId(value);

    FirebaseProvider.i.storage
        .child(PrefKey.app)
        .child(pathKey)
        .child('files')
        .child('${value.id}.pdf')
        .delete();

    FirebaseProvider.i.storage
        .child(PrefKey.app)
        .child(pathKey)
        .child('capas')
        .child('${value.id}.jpg')
        .delete();

    await FirebaseProvider.i.database
        .child(PrefKey.app)
        .child(pathKey)
        .child(value.id)
        .delete();

    super.remove(value);
  }

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
        .child(pathKey).get();

    data.clear();
    data.addAll(fromJsonList(res.value));

    notifyListeners();
    saveLocal();
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
  Map<String, Livro> fromJsonList(Map<dynamic, dynamic>? map) {
    return Livro.fromJsonList(map);
  }

}
