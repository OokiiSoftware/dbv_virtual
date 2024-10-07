import '../model/model.dart';
import '../service/firebase/firebase_database.dart';
import '../util/util.dart';
import 'provider.dart';

class EditEspecialidadesProvider extends ProviderBase1<EspecialidadeSolicitacao> {

  EditEspecialidadesProvider._();
  factory EditEspecialidadesProvider() => i;
  static final EditEspecialidadesProvider i = EditEspecialidadesProvider._();

  @override
  String get pathKey => 'especialidades_pendentes';


  @override
  Future<void> add(EspecialidadeSolicitacao value) async {
    verificarInternet();
    verificarId(value);

    final ref1 = FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child(value.id)
        .child('dados');
    final ref2 = FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child(value.id)
        .child('especialidades');

    await Future.wait([
      ref1.set(value.dados.toJson()),
      ref2.update(Util.mapObjectToJson(value.especialidades)),
    ]);

    if (data.containsKey(value.id)) {
      data[value.id]!.especialidades.addAll(value.especialidades);
    } else {
      data[value.id] = value;
    }
    notifyListeners();
    saveLocal();
  }

  @override
  Future<void> remove(EspecialidadeSolicitacao value) async {
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

  Future<void> removeEsp(Especialidade value, [String? uid]) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child(uid!)
        .child('especialidades')
        .child(value.id)
        .delete();

    data[uid]?.especialidades.remove(value.id);
    notifyListeners();
    saveLocal();
  }

  Future<void> removeDados(String uid) async {
    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child(uid)
        .child('dados').delete();

    data.remove(uid);
    notifyListeners();
    saveLocal();
  }

  Future<void> loadFromId(String uid) async {
    if (loadedOnline) return;
    await refreshFromId(uid);
    loadedOnline = true;
  }

  Future<void> refreshFromId(String uid) async {
    verificarInternet();

    final res = await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child(uid)
        .get();

    data.clear();
    if (res.value == null) return;

    final esp = EspecialidadeSolicitacao.fromJson(res.value);
    esp.dados.membroId = uid;
    data[esp.id] = esp;

    notifyListeners();
    saveLocal();
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
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey).get();

    data.clear();
    data.addAll(fromJsonList(res.value));

    notifyListeners();
    saveLocal();
  }

  Future<void> addAll(Map<String, EspecialidadeSolicitacao> values, String uid) async {
    verificarInternet();

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child(uid)
        .update(Util.mapObjectToJson(values));

    data.addAll(values);
    notifyListeners();
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
  Map<String, EspecialidadeSolicitacao> fromJsonList(Map? map) {
    return EspecialidadeSolicitacao.fromJsonList(map);
  }

}
