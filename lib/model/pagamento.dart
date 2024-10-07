import '../util/util.dart';
import 'item_model.dart';

class Pagamento extends ItemModel {

  @override
  String get id => '_$_id';
  int _id = 0;

  String observacao = '';
  double valor = 0;
  int ano = 0;

  Pagamento({int id = 0, this.ano = 0}) {
    _id = id;
  }

  Pagamento.fromJson(Map? map, int key) :
        _id = key,
        observacao = map?['observacao'] ?? '',
        ano = map?['ano'] ?? 0,
        valor = double.tryParse('${map?['valor']}') ?? 0;

  static Map<String, Pagamento> fromJsonList(Map? map) {
    Map<String, Pagamento> items = {};

    int pKey = 1;
    map?.forEach((key, value) {
      items[key] = Pagamento.fromJson(value, pKey);
      pKey++;
    });

    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'observacao': observacao,
    'valor': valor,
    'ano': ano,
  };

  String get mes => Formats.intToMes(_id);

  Pagamento copy() => Pagamento.fromJson(toJson(), _id);

}

class Pagamentos extends ItemModel2 {

  @override
  String get id => '$ano';

  @override
  int ano = 0;

  final Map<String, Pagamento?> items = {
    '_1': null,
    '_2': null,
    '_3': null,
    '_4': null,
    '_5': null,
    '_6': null,
    '_7': null,
    '_8': null,
    '_9': null,
    '_10': null,
    '_11': null,
    '_12': null,
  };

  Pagamentos();

  Pagamentos.fromJson(Map? map) {
    items.addAll(Pagamento.fromJsonList(map));
    for (var e in items.values) {
      if (e != null) {
        ano = e.ano;
        break;
      }
    }
  }

  static Map<String, Pagamentos> fromJsonList(Map? map) {
    Map<String, Pagamentos> items = {};

    map?.forEach((key, value) {
      items[key] = Pagamentos.fromJson(value);
    });

    return items;
  }

  @override
  Map<String, dynamic> toJson() => _pagamentosToJson();

  Map<String, dynamic> _pagamentosToJson() {
    Map<String, dynamic> values = {};
    items.forEach((key, value) {
      values[key] = value?.toJson();
    });
    return values;
  }

  int get length => items.values.where((e) => e != null && e.valor > 0).length;

  double get totalPago {
    return items.values.map((e) => e?.valor ?? 0).reduce((a, b) => a + b);
  }

}


class PagamentoSgc extends ItemModel {

  @override
  String get id => '_$codPagtoConta';

  String dtCadastro = '';
  String dtVencimento = '';
  String dtPagto = '';
  String descricao = '';
  String obs = '';

  int codPagtoConta = 0;
  int codUsuario = 0;
  int codClube = 0;
  int codTipoPagto = 0;
  int codConta = 0;

  double valor = 0;

  int? codMembro;
  String nomeMembro = '';

  String get status {
    final vencimento = Formats.stringToDateTime(dtVencimento);
    var hoje = DateTime.now();
    hoje = DateTime(hoje.year, hoje.month, hoje.day);
    if (hoje.isAfter(vencimento!) && dtPagto.isEmpty) {
      return 'Vencido';
    }

    if (dtPagto.isEmpty) return 'Não pago';

    return 'Pago';
  }

  bool selected = false;

  PagamentoSgc({
    this.dtCadastro = '',
    this.dtVencimento = '',
    this.dtPagto = '',
    this.descricao = '',
    this.obs = '',
    this.nomeMembro = '',
    this.codPagtoConta = 0,
    this.codUsuario = 0,
    this.codClube = 0,
    this.codTipoPagto = 0,
    this.codConta = 0,
    this.valor = 0,
    this.codMembro,
  });

  PagamentoSgc.fromJson(Map? map) :
        dtCadastro = map?['dt_cadastro'] ?? '',
        dtVencimento = map?['dt_vencimento'] ?? '',
        dtPagto = map?['dt_pagto'] ?? '',
        descricao = map?['descricao'] ?? '',
        obs = map?['obs'] ?? '',
        codPagtoConta = map?['cod_pagto_conta'] ?? 0,
        codUsuario = map?['cod_usuario'] ?? 0,
        codMembro = map?['cod_membro'] ?? 0,
        codClube = map?['cod_clube'] ?? 0,
        codTipoPagto = map?['cod_tipo_pagto'] ?? 0,
        codConta = map?['cod_conta'] ?? 0,
        valor = map?['valor'] ?? 0;

  static Map<String, PagamentoSgc> fromJsonList(Map? map) {
    Map<String, PagamentoSgc> items = {};

    map?.forEach((key, value) {
      items[key] = PagamentoSgc.fromJson(value);
    });

    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'dt_cadastro': dtCadastro,
    'dt_vencimento': dtVencimento,
    'dt_pagto': dtPagto,
    'descricao': descricao,
    'obs': obs,

    'cod_pagto_conta': codPagtoConta == 0 ? null : codPagtoConta,
    'cod_usuario': codUsuario,
    'cod_clube': codClube,
    'cod_tipo_pagto': codTipoPagto,
    'cod_conta': codConta,
    if (codMembro != null)
      'cod_membro': codMembro,

    'valor': valor,
  };

  PagamentoSgc copy({
    String? dtCadastro,
    String? dtVencimento,
    String? dtPagto,
    String? descricao,
    String? obs,
    String? nomeMembro,
    int? codPagtoConta,
    int? codUsuario,
    int? codClube,
    int? codTipoPagto,
    int? codConta,
    int? codMembro,
    double? valor,
  }) => PagamentoSgc(
    dtCadastro: dtCadastro ?? this.dtCadastro,
    dtVencimento: dtVencimento ?? this.dtVencimento,
    dtPagto: dtPagto ?? this.dtPagto,
    descricao: descricao ?? this.descricao,
    obs: obs ?? this.obs,
    nomeMembro: nomeMembro ?? this.nomeMembro,
    codPagtoConta: codPagtoConta ?? this.codPagtoConta,
    codUsuario: codUsuario ?? this.codUsuario,
    codClube: codClube ?? this.codClube,
    codTipoPagto: codTipoPagto ?? this.codTipoPagto,
    codConta: codConta ?? this.codConta,
    valor: valor ?? this.valor,
    codMembro: codMembro ?? this.codMembro,
  );

  @override
  String toString() => toJson().toString();
}