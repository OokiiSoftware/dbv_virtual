import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/model.dart';
import '../provider/provider.dart';
import '../util/logs.dart';

class VersionControlProvider extends IProvider {

  static VersionControlProvider i = VersionControlProvider();

  static late PackageInfo packageInfo;
  void Function(bool)? onNewVersion;

  String get path => 'version';

  final Map<String, AppVersao> _data = {};
  Map _versions = {};

  String get appName => packageInfo.appName;
  String get version => packageInfo.version;
  String get versionCod => packageInfo.buildNumber;

  List<AppVersao> get list => _data.values.toList();


  Future<void> addVerion(String pack, String version, bool important) async {
    await FirebaseProvider.i.database
        .child(path)
        .child(pack)
        .child(version)
        .set(important);

    if (!_data.containsKey(pack)) {
      _data[pack] = AppVersao(key: pack);
    }

    _data[pack]?.versions[version] = important;
    notifyListeners();
  }

  Future<void> removeVerion(String pack, String version) async {
    await FirebaseProvider.i.database
        .child(path)
        .child(pack)
        .child(version).delete();

    _data[pack]?.versions.remove(version);
    notifyListeners();
  }


  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  Future<void> verificarVersion() async {
    if (!Platform.isAndroid) return;
    if (InternetProvider.i.disconnected) return;

    try {
      final res = await FirebaseProvider.i.database
          .child(path)
          .child(_versionPath)
          .get();

      if (res.value is! Map) return;

      _versions = res.value;

      int localVer = int.parse(packageInfo.buildNumber);

      bool atualizacaoImportante = false;
      bool novaVersao = false;

      _versions.forEach((version, importante) {
        int newVer = int.parse(version);

        if (newVer.compareTo(localVer) > 0) {
          novaVersao = true;

          if (!atualizacaoImportante && importante) {
            atualizacaoImportante = importante;
          }
        }
      });

      if (novaVersao) {
        onNewVersion?.call(atualizacaoImportante);
      }
    } catch(e) {
      const Log('VersionControlProvider').e('verificarVersion', e);
    }
  }

  void irParaPlayStory() {
    try {
      final pack = packageInfo.packageName;
      launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=$pack'));
    } catch(e) {
      Log.snack('Erro ao ir para a loja', isError: true);
      const Log('VersionControlProvider').e('irParaPlayStory', e);
    }
  }

  String get _versionPath => packageInfo.packageName.replaceAll('.', '');

  Future<void> load() async {
    final res = await FirebaseProvider.i.database
        .child(path).get();

    Map? map = res.value;
    map?.forEach((key, value) {
      Map<String, bool> items = {};
      value?.forEach((key, value) {
        items[key] = value;
      });

      _data[key] = AppVersao(
        key: key,
        versions: items,
      );
    });

    notifyListeners();
  }

  @override
  void saveLocal() {}

  @override
  void loadLocal() {}

  @override
  Future<void> close() async {}
}