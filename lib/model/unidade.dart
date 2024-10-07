import 'model.dart';

class Unidade extends ItemModel {

  @override
  String get id => '_$codUnidade';
  int codUnidade = 0;
  int codClube = 0;
  int codAutor = 0;
  int codConselheiro = 0;
  int senha = 0;

  String dtCadastro = '';
  String nomeUnidade = '';
  String historico = '';
  String extras = '';

  int membrosCount = 0;
  String nomeConselheiro = '';
  bool canDelete = false;

  List<int> conselheiroIds = [];

  Unidade({
    this.codUnidade = 0,
    this.codClube = 0,
    this.codAutor = 0,
    this.codConselheiro = 0,
    this.senha = 0,
    this.membrosCount = 0,
    this.dtCadastro = '',
    this.nomeUnidade = '',
    this.nomeConselheiro = '',
    this.historico = '',
    this.extras = '',
    this.canDelete = false,
    List<int>? conselheiroIds,
  }) {
    if (conselheiroIds != null) {
      this.conselheiroIds.addAll(conselheiroIds);
    }
  }

  Unidade.fromJson(Map? map) :
        codUnidade = map?['cod_unidade'] ?? 0,
        codClube = map?['cod_clube'] ?? 0,
        codAutor = map?['cod_autor'] ?? 0,
        codConselheiro = map?['cod_conselheiro'] ?? 0,
        senha = map?['senha'] ?? 0,
        dtCadastro = map?['dt_cadastro'] ?? '',
        nomeUnidade = map?['nome_unidade'] ?? '',
        historico = map?['historico'] ?? '',
        extras = map?['extras'] ?? '';

  static Map<String, Unidade> fromJsonList(Map? map) {
    Map<String, Unidade> items = {};
    map?.forEach((key, value) {
      items[key] = Unidade.fromJson(value);
    });
    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'cod_unidade': codUnidade == 0 ? '' : codUnidade,
    'cod_clube': codClube,
    'cod_autor': codAutor,
    'cod_conselheiro': codConselheiro,
    'senha': senha,
    'nome_unidade': nomeUnidade,
    'historico': historico,
    'extras': extras,
    'dt_cadastro': dtCadastro,
  };

  Unidade copy({
    int? codUnidade,
    int? codClube,
    int? codAutor,
    int? codConselheiro,
    int? senha,
    int? membrosCount,
    String? dtCadastro,
    String? nomeUnidade,
    String? nomeConselheiro,
    String? historico,
    String? extras,
    bool? canDelete,
    List<int>? conselheiroIds,
  }) => Unidade(
    codUnidade: codUnidade ?? this.codUnidade,
    codClube: codClube ?? this.codClube,
    codAutor: codAutor ?? this.codAutor,
    codConselheiro: codConselheiro ?? this.codConselheiro,
    senha: senha ?? this.senha,
    membrosCount: membrosCount ?? this.membrosCount,
    dtCadastro: dtCadastro ?? this.dtCadastro,
    nomeUnidade: nomeUnidade ?? this.nomeUnidade,
    nomeConselheiro: nomeConselheiro ?? this.nomeConselheiro,
    historico: historico ?? this.historico,
    extras: extras ?? this.extras,
    canDelete: canDelete ?? this.canDelete,
    conselheiroIds: conselheiroIds ?? this.conselheiroIds,
  );

  @override
  String toString() => toJson().toString();
}

class UnidadeMembro {
  int codMembro = 0;
  String nomeUnidade = '';

  String get idMembro => '_$codMembro';

  UnidadeMembro({
    this.codMembro = 0,
    this.nomeUnidade = '',
  });

  @override
  String toString() {
    return {
      'codMembro': codMembro,
      'nomeUnidade': nomeUnidade,
    }.toString();
  }
}

class MembrosUnidade {

  Map<int, String> unidades = {};
  List<int> membroCods = [];

}