import '../../provider/provider.dart';
import '../../model/model.dart';
import '../service/service.dart';
import '../../res/res.dart';

class ClubeProvider extends IProvider {

  ClubeProvider._();
  factory ClubeProvider() => i;
  static final ClubeProvider i = ClubeProvider._();

  String get pathKey => 'clube';

  Clube clube = Clube(nome: 'Meu Clube');


  Future<void> set(Clube value) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(value.id)
        .child(pathKey)
        .set(value.toJson());

    clube = value;
    notifyListeners();
    saveLocal();
  }

  Future<void> salvarHino(String value) async {
    verificarInternet();

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clube.id)
        .child(pathKey)
        .child('hino')
        .set(value);

    clube.hino = value;
    notifyListeners();
    saveLocal();
  }

  Future<void> setCodigo(int value) async {
    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clube.id)
        .child(pathKey)
        .child('codigo')
        .set(value);

    clube.codigo = value;
  }

  Future<void> loadOnline(String clubeId) async {
    if (loadedOnline) return;
    await refresh(clubeId);
    loadedOnline = true;
  }

  Future<void> refresh(String clubeId) async {
    verificarInternet();

    final res = await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .get();

    clube = Clube.fromJson(res.value);
    notifyListeners();
    saveLocal();
  }

  @override
  void saveLocal() {
    database.child(pathKey).set(clube.toJson());

    Tema.i.saveColors(clube.primaryColor, clube.secondaryColor);
  }

  @override
  void loadLocal() {
    if (loadedLocal) return;
    try {
      final res = database.child(pathKey).get();
      clube = Clube.fromJson(res.value);
      notifyListeners();
    } catch(e) {
      log.e('loadLocal', e);
    }

    loadedLocal = true;
  }

  @override
  Future<void> close() async {
    clube = Clube(nome: 'Meu Clube');
    loadedOnline = false;
  }
}