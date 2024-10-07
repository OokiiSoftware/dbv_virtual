import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageProvider {

  static final StorageProvider i = StorageProvider();

  String localPath = '';

  Future<void> init() async {
    var dir = await getApplicationCacheDirectory();
    dir = Directory(dir.path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    Directory('${dir.path}$pathDiv${StoragePath.especialidades}').create();
    Directory('${dir.path}$pathDiv${StoragePath.imagens}').create();

    localPath = dir.path;
  }

  String get pathDiv {
    return Platform.isAndroid ? '/' : '\\';
  }


  File file(List<String> path) => File(localPath + pathDiv + path.join(pathDiv));

  Future<String> createFolder(String name) async {
    final dir = Directory(localPath + pathDiv + name);
    await dir.create(recursive: true);
    return dir.path + pathDiv;
  }

  Future<void> deleteFolder(String name) async {
    final dir = Directory(localPath + pathDiv + name);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  String fileName(String path) {
    return path.replaceAll('/', pathDiv).split(pathDiv).last;
  }
  String fileExt(String path) {
    return fileName(path).split('.').last;
  }
}

class StoragePath {
  static const imagens = 'imagens';
  static const especialidades = 'especialidades';
}