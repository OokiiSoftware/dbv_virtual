import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/model.dart';
import '../util/util.dart';
import '../res/res.dart';
import 'provider.dart';

class AppProvider {

  static const _log = Log('AppProvider');

  static const _kTotal = 13;
  static int _progress = 0;
  static void Function(int, int)? onProgress;

  static Future<void> initialize({void Function(int, int)? onProgress}) async {
    AppProvider.onProgress = onProgress;

    Gemini.init(apiKey: dotenv.env['GEMINI_APIKEY'] ?? '');

    VersionControlProvider.i.onNewVersion = (value) {
      Log.snack(value ? 'Atualização importante' : 'Nova versão disponível',
        persistent: value,
        actionLabel: 'Baixar',
        actionClick: VersionControlProvider.i.irParaPlayStory,
      );
    };

    Assets.loadCidades().then(_updateProgress);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(_updateProgress);

    await Future.wait([
      SharedPref.pref.load().then(_updateProgress),
      InternetProvider.i.init().then(_updateProgress),
      FirebaseProvider.i.init().then(_updateProgress),
      FastCachedImageConfig.init(clearCacheAfter: const Duration(minutes: 5)).then(_updateProgress),
    ]);

    Tema.i.load();
    _updateProgress(null);

    if (!SharedPref.pref.getBool(PrefKey.databaseVersion)) {
      SharedPref.pref.setBool(PrefKey.databaseVersion, true);

      await DatabaseLocal.clear();
    }
    _updateProgress(null);

    await DatabaseLocal.i.load().then(_updateProgress);

    _loadLocalData();
    _loadOnlineData();
  }

  static void _loadOnlineData() async {
    final fireProv = FirebaseProvider.i;

    if (InternetProvider.i.connected) {
      dynamic codUser = pref.getString(PrefKey.userCodigo, def: '0');
      codUser = int.tryParse(codUser) ?? 0;

      await CvProvider.i.init(Membro(
        emailUsuario: pref.getString(PrefKey.userEmail),
        codUsuario: codUser,
        dtNascimento: '01/01/${pref.getString(PrefKey.userAno)}',
      )).then(_updateProgress).catchError((e) {
        final erro = e.toString();
        if (erro.contains(CvLoginStatus.desativado) || erro.contains(CvLoginStatus.naoExiste)) {
          logout();
        }
        _log.e('_init', 'CvProvider', e);
      });

      await fireProv.login(codUser).then(_updateProgress).catchError((e) {
        _log.e('_init', 'FirebaseProvider', e);
      });

      await MembrosProvider.i.loadOnline().then(_updateProgress).catchError((e) {
        _log.e('_init', 'MembrosProvider', e);
      });
      await ClubeProvider.i.loadOnline(fireProv.clubeId).then(_updateProgress).catchError((e) {
        _log.e('_init', 'ClubeProvider', e);
      });

      VersionControlProvider.i.verificarVersion();

      if (!fireProv.readOnly) {
        EditMembrosProvider.i.loadOnline();
        EditEspecialidadesProvider.i.loadOnline();
      }
    }
  }

  static void _loadLocalData() {
    final ano = DateTime.now().year;

    for (var prov in _providers) {
      prov.loadLocal();
    }

    for (var prov in _providers1) {
      if (prov is AgendaProvider) {
        prov.loadLocal(ano);
      } else {
        prov.loadLocal();
      }
    }

    for (var prov in _providers2) {
      prov.loadLocal(ano);
    }
  }

  static void _updateProgress(value) {
    _progress++;
    onProgress?.call(_progress, _kTotal);
  }

  static Future<void> logout() async {
    Future.wait([
      ..._allProviders.map((e) => e.close()),
      DatabaseLocal.clear(),
      SharedPref.pref.clear(),
    ]);

    if (await Ressorces.clubeLogo.exists()) {
      await Ressorces.clubeLogo.delete();
    }
  }


  static List<IProvider> get _allProviders {
    return [
      ..._providers,
      ..._providers1,
      ..._providers2,
    ];
  }

  static List<IProvider> get _providers => [
    ClubeProvider.i,
    CvProvider.i,
    FirebaseProvider.i,
    SgcProvider.i,
  ];

  static List<ProviderBase1> get _providers1 => [
    AgendaProvider.i,
    LivrariaProvider.i,
    EditEspecialidadesProvider.i,
    EditMembrosProvider.i,
    EspecialidadesProvider.i,
    ManuaisProvider.i,
    MembrosProvider.i,
    PagamentosTaxaProvider.i,
  ];

  static List<ProviderBase2> get _providers2 => [
    AdvertenciasProvider.i,
    FaltasProvider.i,
  ];

}