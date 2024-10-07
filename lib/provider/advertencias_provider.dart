import '../model/model.dart';
import 'provider.dart';

class AdvertenciasProvider extends ProviderBase2<Advertencia> {

  AdvertenciasProvider._();
  static AdvertenciasProvider i = AdvertenciasProvider._();
  factory AdvertenciasProvider() => AdvertenciasProvider.i;

  @override
  String get pathKey => 'advertencias';

  @override
  Map<String, Advertencia> fromJsonList(Map<dynamic, dynamic>? map) {
    return Advertencia.fromJsonList(map);
  }

}