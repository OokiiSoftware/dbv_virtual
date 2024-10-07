import '../model/model.dart';
import 'provider.dart';

class FaltasProvider extends ProviderBase2<Falta> {

  FaltasProvider._();
  static FaltasProvider i = FaltasProvider._();
  factory FaltasProvider() => FaltasProvider.i;

  @override
  String get pathKey => 'faltas';

  @override
  Map<String, Falta> fromJsonList(Map<dynamic, dynamic>? map) {
    return Falta.fromJsonList(map);
  }

}