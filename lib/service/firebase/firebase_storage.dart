import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'firebase_base.dart';

class FirebaseStorage extends FirebaseBase {

  static String _url = '';
  static String get _endPoint => 'firebasestorage.googleapis.com';

  static const double _kMaxFileSize = 1.0;

  @override
  String get key => 'Storage';

  @override
  String get url => _url;

  @override
  Map<String, String> get headers => {
    'Authorization': 'Bearer $token',
  };

  @override
  Map<String, dynamic> get queryParameters => {
    'name': path,
  };

  @override
  Uri get uri => Uri(
    scheme: 'https',
    host: _endPoint,
    path: 'v0/b/$_url/o',
    queryParameters: queryParameters,
  );



  FirebaseStorage.initialize(String url) {
    FirebaseStorage._url = url.replaceAll('gs://', '');
    FirebaseStorage.instance = this;
  }
  static late FirebaseStorage instance;

  FirebaseStorage(List<String> paths) {
    localPath.addAll(paths);
  }

  FirebaseStorage child(String path) {
    return FirebaseStorage([...localPath + path.split('/')]);
  }


  Future<Uint8List?> getData() async {
    var res = await http.get(Uri.parse(await getDownloadURL()), headers: headers);
    return res.bodyBytes;
  }

  Future<FirebaseStorage> putData(Uint8List value, {bool ignoreSize = false}) async {
    if (!ignoreSize && value.length > _kMaxFileSize * 1024 * 1024) {
      throw 'Tamanho máximo para arquivos é de $_kMaxFileSize Mb';
    }

    var res = await http.post(uri, body: value, headers: headers);
    if (semPermisao(res)) {
      if (await relogin()) {
        res = await http.post(uri, body: value, headers: headers);
      }
    }

    verificarErro(res);
    return this;
  }

  Future<String> getDownloadURL() async {
    var res = await http.get(uri, headers: headers);

    if (semPermisao(res)) {
      if (await relogin()) {
        res = await http.get(uri, headers: headers);
      }
    }

    verificarErro(res);

    final data = jsonDecode(res.body);
    final token = data['downloadTokens'];

    return uri.replace(
      path: 'v0/b/$url/o/${localPath.join('%2F')}',
      query: 'alt=media&token=$token',
    ).toString();
  }

}