import '../model/model.dart';
import '../service/service.dart';
import 'provider.dart';

class PagamentosTaxaProvider extends ProviderBase1<Pagamentos> {

  PagamentosTaxaProvider._();
  factory PagamentosTaxaProvider() => i;
  static final PagamentosTaxaProvider i = PagamentosTaxaProvider._();

  @override
  String get pathKey => 'pagamentos';

  Pagamentos getByUid(String uid) {
    return data[uid] ?? Pagamentos();
  }


  Future<void> addPagamento(Pagamento value, String uid) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child('${value.ano}')
        .child(uid)
        .child(value.id)
        .set(value.toJson());

    if (!data.containsKey(uid)) {
      data[uid] = Pagamentos();
    }

    data[uid]!.items.remove(value.id);
    data[uid]!.items[value.id] = value;
    notifyListeners();
    saveLocal();
  }

  Future<void> removePagamento(Pagamento value, String uid) async {
    verificarInternet();
    verificarId(value);

    await FirebaseProvider.i.database
        .child(ChildKeys.clubes)
        .child(clubeId)
        .child(pathKey)
        .child('${value.ano}')
        .child(uid)
        .child(value.id)
        .delete();

    data[uid]?.items.remove(value.id);
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
    data.addAll(Pagamentos.fromJsonList(res.value));

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

    anosList.clear();
    Map map = res.value;

    for (var value in map.keys) {
      final ano = int.parse(value);
      if (!anosList.contains(ano)) {
        anosList.add(ano);
      }
    }

    notifyListeners();
    saveLocal();
  }


  @override
  void saveLocal() {
    data.forEach((key, value) {
      database.child(pathKey)
          .child('${value.ano}')
          .child(key)
          .set(value.toJson());
    });
  }

  @override
  void loadLocal([int ano = 0]) {
    if (loadedLocal) return;
    loadLocalAnos();

    try {
      final res = database
          .child(pathKey)
          .child('$ano')
          .get();

      data.addAll(Pagamentos.fromJsonList(res.value));
      notifyListeners();
    } catch(e) {
      log.e('loadLocal', e);
    }

    loadedLocal = true;
  }

  @override
  Map<String, Pagamentos> fromJsonList(Map? map) {
    return Pagamentos.fromJsonList(map);
  }
}