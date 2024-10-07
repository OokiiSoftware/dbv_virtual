import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../res/res.dart';
import '../service/service.dart';
import '../model/model.dart';
import '../util/util.dart';
import 'provider.dart';

class FirebaseProvider extends IProvider {

  static const _kDefaultAccountsCount = 100;

  final _log = const Log('FirebaseProvider');

  FirebaseProvider._();
  factory FirebaseProvider() => i;
  static final FirebaseProvider i = FirebaseProvider._();

  late FirebaseAuth auth;
  late FirebaseStorage storage;
  late FirebaseDatabase database;

  bool erroDeConexao = false;
  bool _especialLogin = false;
  bool get especialLogin => _especialLogin;
  bool get logado => auth.currentUser != null || user.codUsuario != 0;
  bool get readOnly => !Arrays.cargosElevados.contains(user.codFuncao);

  String _clubeId = '';
  @override
  String get clubeId {
    if (_clubeId.isEmpty) throw 'O ID do clube está vazio';

    return _clubeId;
  }
  Membro user = Membro();

  int _codUser = 0;
  int get codUser {
    if (_codUser == 0) {
      return user.codUsuario;
    }
    return _codUser;
  }

  Map<String, String> get headers => storage.headers;
  Map<String, String> get _env => dotenv.env;

  FirebaseOptions get _options => FirebaseOptions(
    apiKey: _env['FIREBASE_APIKEY'] ?? '',
    appId: _env['FIREBASE_APP_ID'] ?? '',
    messagingSenderId: _env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
    projectId: _env['FIREBASE_PROJECT_ID'] ?? '',
    storageBucket: _env['FIREBASE_STORAGE'] ?? '',
    databaseURL: _env['FIREBASE_DATABASE'] ?? '',
  );

  Future<void> init() async {
    try {
      await Firebase.initializeApp(options: _options);
    } catch(e) {
      _log.e('init', e);
    }

    auth = FirebaseAuth.instance;
    database = FirebaseDatabase.initialize(_options.databaseURL!);
    storage = FirebaseStorage.initialize(_options.storageBucket!);

    FirebaseBase.authExpiredListner(_requisitarNovamente);
  }

  Future<void> login(int codUser, {String? key}) async {
    verificarInternet();
    _codUser = codUser;

    if (codUser == 0) throw 'Código do usuário inválido';
    _log.d('login', 'iniciando', codUser);

    final conta = randomInt(_kDefaultAccountsCount);

    final res = await auth.signInWithEmailAndPassword(
      email: '${_env['FIREBASE_DEFAULT_USER_EMAIL']}$conta@gmail.com',
      password: '${_env['FIREBASE_DEFAULT_USER_SENHA']}$conta',
    );
    if (res.user == null) throw 'Ocorreu um erro interno de login';
    _log.d('login', 'UID', res.user!.uid);

    await _getUserToken(res.user!);

    await _onLoginSuccess(loginKey: key);

    _log.d('login', 'OK', res.user!.uid);
  }

  Future<void> relogin() async {
    await login(codUser);
  }


  Future<void> criarVariosUsuarios(int count) async {
    count += _kDefaultAccountsCount;

    for(int i = _kDefaultAccountsCount +1; i <= count; i++) {
      var email = '${_env['FIREBASE_DEFAULT_USER_EMAIL']}$i@gmail.com';
      var senha = '${_env['FIREBASE_DEFAULT_USER_SENHA']}$i';
      try {
        await createUser(email, senha);
        _log.d('criarVariosUsuarios', 'Cadastrado', i);
      } catch(e) {
        _log.e('criarVariosUsuarios', 'Erro ao cadastrar', i);
      }
    }
  }

  Future<void> createUser(String email, String senha) async {
    await auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }


  Future<void> criarIdentificador(String uid) async {
    await database.child(ChildKeys.identificadores)
        .child(uid).set(clubeId);
  }

  Future<void> criarIdentificadores(List<String> uids) async {
    Map<String, String> dados = {};
    for (var id in uids) {
      dados[id] = clubeId;
    }

    await database
        .child(ChildKeys.identificadores)
        .update(dados);
  }

  Future<void> removerIdentificador(String uid) async {
    await database.child(ChildKeys.identificadores)
        .child(uid).delete();
  }


  Future<void> _onLoginSuccess({String? loginKey}) async {
    String codUserKey = '_$codUser';

    Future<void> normalLogin() async {
      _log.d('normalLogin', 'ID', codUserKey);

      Future<String?> getClubeId() async {
        final res = await database
            .child('identificadores')
            .child(codUserKey).get();
        return res.value;
      }

      _clubeId = await getClubeId() ?? '';

      final res = await database
          .child('clubes')
          .child(clubeId)
          .child('membros')
          .child(codUserKey).get();

      if (res.value == null) throw 'ID do clube não encontrado';
      user = Membro.fromJson(res.value);

      _log.d('onLoginSuccess', 'normalLogin', 'OK', user.nomeUsuario);
      notifyListeners();
      saveLocal();
    }

    Future<void> especialLogin() async {
      _log.d('onLoginSuccess', 'especialLogin', 'loginKey', loginKey);

      final res = await database
          .child('loginKey')
          .child(loginKey!).get();

      int value = res.value ?? 0;
      _log.d('especialLogin', 'value', value);

      final codDate = DateTime.fromMillisecondsSinceEpoch(value);
      final date = DateTime.now();

      if (value == 0 || codDate.isBefore(date)) throw 'A chave informada é inválida ou já expirou';

      _especialLogin = true;

      _log.d('onLoginSuccess', 'especialLogin', loginKey);
      notifyListeners();
    }

    if (loginKey == null) {
      await normalLogin();
    } else {
      await especialLogin();
    }
  }

  void setCodUser(int value) {
    _codUser = value;
  }

  void setClubeId(String value) {
    _clubeId = value;
  }
  void registroCompleto() {
    _especialLogin = false;
    notifyListeners();
  }

  Future<void> _getUserToken(User user, [bool forceRefresh = false]) async {
    try {
      final token = await user.getIdTokenResult(forceRefresh);
      FirebaseBase.setToken(token.token ?? '');

      if (erroDeConexao) {
        erroDeConexao = false;
        notifyListeners();
      }

      _log.d('getUserToken', 'OK');
    } catch(e) {
      if (e.toString().contains('Failed host lookup')) {
        erroDeConexao = true;
        notifyListeners();
      }
    }
  }

  DateTime? _lastRelogin;

  Future<bool> _requisitarNovamente() async {
    if (_lastRelogin == null) {
      _lastRelogin = DateTime.now();
    } else {
      final now = DateTime.now();
      if (now.difference(_lastRelogin!).inSeconds < 30) {
        return false;
      }

      _lastRelogin = now;
    }

    try {
      await FirebaseProvider.i.relogin();
      _log.d('requisitarNovamente', 'OK');
      return true;
    } catch(e) {
      _log.e('_requisitarNovamente', e);
      return false;
    }
  }



  Future<String> uploadFile(List<String> path, Uint8List bytes, {bool ignoreSize = false}) async {
    final res = await storage
        .child(path.join('/'))
        .putData(bytes, ignoreSize: ignoreSize);

    return await res.getDownloadURL();
  }

  Future<void> deleteFile(List<String> path) async {
    await storage
        .child(path.join('/'))
        .delete();
  }


  @override
  void saveLocal() {
    DatabaseLocal.i.child('user').set(user.toJson());
    DatabaseLocal.i.child('clubeId').set(_clubeId);
  }

  @override
  void loadLocal() {
    if (loadedLocal) return;
    try {
      _clubeId = DatabaseLocal.i.child('clubeId').get(def: _clubeId).value;
      final res = DatabaseLocal.i.child('user').get(def: {});
      user = Membro.fromJson(res.value);
      notifyListeners();
    } catch(e) {
      log.e('loadLocal', e);
    }

    loadedLocal = true;
  }

  @override
  Future<void> close() async {
    await auth.signOut();
    FirebaseBase.setToken('');

    _especialLogin = false;
    erroDeConexao = false;
    user = Membro();
    _clubeId = '';
    setCodUser(0);

    notifyListeners();
    _log.d('logout');
  }
}
