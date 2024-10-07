import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../provider/provider.dart';
import '../../util/util.dart';
import 'firebase_base.dart';

class FirebaseDatabase extends FirebaseBase {
  final _log = const Log('FirebaseDatabase');

  static String _url = '';
  static final Map<String, _ListenerReq> _listenReq = {};

  @override
  String get key => 'Database';

  @override
  String get url => _url;

  @override
  String? get queryPath => '${localPath.join('/')}.json';

  @override
  Map<String, dynamic> get queryParameters => {
    'auth': token,
  };


  FirebaseDatabase.initialize(String url) {
    FirebaseDatabase._url = url;
    FirebaseDatabase.instance = this;
  }
  static late FirebaseDatabase instance;

  FirebaseDatabase(List<String> paths) {
    localPath.addAll(paths);
  }

  FirebaseDatabase child(String path) {
    return FirebaseDatabase([...localPath + path.split('/')]);
  }


  Future<DataSnapshot> get([DatabaseQuery? filter]) async {
    var res = await http.get(uri.replace(
      queryParameters: {...uri.queryParameters,
        if (filter != null && filter.isParametro)
          filter.key!: filter.value!,
      }));

    if (semPermisao(res)) {
      if (await relogin()) {
        res = await http.get(uri);
      }
    }

    verificarErro(res);

    if (res.body.isEmpty || res.body == 'null') {
      return DataSnapshot();
    }

    return DataSnapshot(
      value: jsonDecode(res.body),
    );
  }

  Future<void> set(dynamic value) async {
    var res = await http.put(uri, body: jsonEncode(value));
    if (semPermisao(res)) {
      if (await relogin()) {
        res = await http.put(uri, body: jsonEncode(value));
      }
    }
    verificarErro(res);
  }

  Future<void> update(dynamic value) async {
    var res = await http.patch(uri, body: jsonEncode(value));
    if (semPermisao(res)) {
      if (await relogin()) {
        res = await http.patch(uri, body: jsonEncode(value));
      }
    }
    verificarErro(res);
  }


  void removeListener() {
    _listenReq[path]?.client?.close();
    _listenReq[path]?.response?.cancel();
    _listenReq.remove(path);
  }

  void addListener(DatabaseListener listener) async {
    _listenReq[path] = _ListenerReq(client: http.Client());

    final client = _listenReq[path]!.client;

    final req = http.Request('GET', uri);
    req.headers.addAll({'Accept': 'text/event-stream'});
    final res = await client!.send(req);

    _listenReq[path]!.response = res.stream.toStringStream().listen((event) {
      if (event.contains('keep-alive')) return;
      if (event.contains('Auth token is expired')) {
        FirebaseProvider.i.relogin();
        return;
      }

      try {
        var obj = event.substring(event.indexOf('{'), event.length -1);

        final map = jsonDecode(obj);
        String path = map['path'];
        dynamic data = map['data'];

        DatabaseEvent eventType = DatabaseEvent.none;
        if (path == '/') {
          eventType = DatabaseEvent.add;
        } else {
          if (data == null) {
            eventType = DatabaseEvent.remove;
          } else {
            eventType = DatabaseEvent.change;
          }
        }

        final snapshot = DataSnapshot(
          event: eventType,
          key: path,
          value: data,
        );

        switch(eventType) {
          case DatabaseEvent.add:
            listener.onAdd?.call(snapshot);
            break;
          case DatabaseEvent.change:
            listener.onChanged?.call(snapshot);
            break;
          case DatabaseEvent.remove:
            listener.onRemove?.call(snapshot);
            break;
          case DatabaseEvent.none:
            break;
        }
      } catch(e) {
        _log.e('addListener', [path, e]);
      }
    });
  }

}

class _ListenerReq {
  http.Client? client;
  StreamSubscription<String>? response;

  _ListenerReq({this.client});
}

class DatabaseQuery {
  String? key;
  String? value;

  /// Se true os dados são passados na url?key=value
  bool isParametro = false;

  DatabaseQuery({
    this.key,
    this.value,
    this.isParametro = false,
  });
}

class DataSnapshot {

  DatabaseEvent event;
  String? key;
  dynamic value;
  dynamic priority;
  bool get exists => value != null;

  DataSnapshot({
    this.event = DatabaseEvent.none,
    this.key,
    this.value,
    this.priority,
  });
}

class DatabaseListener {
  void Function(DataSnapshot)? onAdd;
  void Function(DataSnapshot)? onRemove;
  void Function(DataSnapshot)? onChanged;

  DatabaseListener({this.onAdd, this.onRemove, this.onChanged});
}

enum DatabaseEvent {
  add, change, remove, none
}

class ChildKeys {
  static const clubes = 'clubes';
  static const images = 'images';
  static const identificadores = 'identificadores';
}