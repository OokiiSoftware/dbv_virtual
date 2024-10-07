import 'model.dart';

class AppVersao extends ItemModel {

  @override
  String get id => '';
  final String key;
  final Map<String, bool> versions = {};

  AppVersao({
    this.key = '',
    Map<String, bool>? versions,
  }) {
    if (versions != null) this.versions.addAll(versions);
  }

  @override
  Map<String, dynamic> toJson() => {};

}