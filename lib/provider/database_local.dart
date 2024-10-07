import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../provider/provider.dart';

DatabaseLocal get database => DatabaseLocal.i;

class DatabaseLocal {
  static const _databaseName = 'database.json';

  static DatabaseLocal i = DatabaseLocal();

  static File get _databaseFile => StorageProvider.i.file([_databaseName]);
  static String get databasePath => _databaseFile.path;



  static final Map<String, List<Function(Snapshot)>> _listener = {};
  static Map<String, dynamic> _data = {};

  static Future<void> clear() async {
    _data.clear();
    if (await _databaseFile.exists()) await _databaseFile.delete();
  }

  final List<String> _paths = [];

  static Timer? _timerToSave;


  DatabaseLocal child(String path) {
    return DatabaseLocal().._paths.addAll(_paths + path.split('/'));
  }

  Future<void> set(dynamic value) async {
    List<String> pathsToListener = [];
    String pathListener = '';
    bool canSave = false;

    dynamic current = _data;
    for (var key in _paths) {
      pathListener += pathListener.isEmpty ? key : '/$key';

      if (_listener.containsKey(pathListener)) {
        pathsToListener.add(pathListener);
      }

      if (!current.containsKey(key)) {
        current[key] = <String, dynamic>{};
      }

      if (key == _paths.last) {
        // print('= current[$key] = $value');
        current[key] = value;
        _callListenerAux(pathsToListener, QueryType.add);
        canSave = true;
      } else {
        final v = current[key];
        if (v is String || v is int || v is bool || v is double) {
          current[key] = <String, dynamic>{};
        }
        current = current[key];
      }
    }

    if (canSave) {
      await _save();
    }
  }

  Future<void> remove() async {
    List<String> pathsToListener = [];
    String pathListener = '';
    bool canSave = false;

    Map<String, dynamic> current = _data;
    for (var key in _paths) {
      if (!current.containsKey(key)) {
        return;
      }
      pathListener += pathListener.isEmpty ? key : '/$key';

      if (_listener.containsKey(pathListener)) {
        pathsToListener.add(pathListener);
      }

      if (key == _paths.last) {
        current.remove(key);
        _callListenerAux(pathsToListener, QueryType.remove);
        canSave = true;
      } else {
        current = current[key];
      }
    }

    if (canSave) {
      await _save();
    }
  }

  Snapshot get({dynamic def}) {
    dynamic current = _data;
    for (var key in _paths) {
      if (current is! Map || !current.containsKey(key)) {
        break;
      }

      if (key == _paths.last) {
        if (current[key] == null) break;
        return Snapshot(
          queryType: QueryType.get,
          value: current[key],
          url: path,
        );
      } else {
        current = current[key];
      }
    }
    return Snapshot(
      queryType: QueryType.get,
      value: def,
      url: path,
    );
  }

  @override
  String toString() {
    return _data.toString();
  }

  Future<void> _save() async {
    _timerToSave?.cancel();
    _timerToSave = null;
    _timerToSave = Timer(const Duration(milliseconds: 500), () {
      if (_data.isEmpty) return;

      _computeSave(_databaseFile.path, _data);
    });
  }

  String get path => _paths.join('/');

  void _callListenerAux(List<String> paths, QueryType queryType) {
    for(var path in paths) {
      if (path.contains(path)) {
        _callListener(_listener[path]!, queryType, child(path).get());
        break;
      }
    }
  }

  void addListener(Function(Snapshot) value) {
    if (!_listener.containsKey(path)) {
      _listener[path] = [];
    }
    _listener[path]!.add(value);
  }
  void removeListener(Function(Snapshot) value) {
    if (_listener.containsKey(path)) {
      _listener[path]!.remove(value);
    }
  }

  void clearListener() {
    if (_listener.containsKey(path)) {
      _listener[path]!.clear();
    }
  }

  void _callListener(List<void Function(Snapshot)> fs, QueryType queryType, Snapshot data) {
    for (var f in fs) {
      f.call(data);
    }
  }

  Future<void> load() async {
    try {
      _data = jsonDecode(await _databaseFile.readAsString());
    } catch(e) {
      _data = <String, dynamic>{};
    }
  }
}

class Snapshot {
  QueryType? queryType;
  dynamic value;

  String url;

  Snapshot({this.queryType, this.value, this.url = ''});
}
enum QueryType { add, remove, get, }

Future<String?> _computeSave(String path, dynamic data) async {
  final file = File(path);

  try {
    await file.writeAsString(jsonEncode(data));
    return null;
  } catch(e) {
    if (kDebugMode) {
      print('Database: _computeSave: ${e.toString()}');
    }
    return e.toString();
  }
}
