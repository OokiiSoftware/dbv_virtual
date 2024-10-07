import 'model.dart';

class Clube extends ItemModel {

  @override
  String id = '';
  String nome = '';
  String logoUrl = '';
  String associacao = '';
  String regiao = '';
  String dataFundacao = '';
  String reuniaoDia = '';
  String reuniaoHora = '';
  String regulamentoInterno = '';
  String hino = '';
  String pixChave = '';
  String pixNomePessoa = '';
  double taxaMensal = 0;

  String primaryColor = '';
  String secondaryColor = '';

  int codigo = 0;

  Clube({
    this.id = '',
    this.nome = '',
    this.associacao = '',
    this.regiao = '',
    this.taxaMensal = 0,
  });

  Clube.fromJson(Map? map) :
        id = map?['id'] ?? '',
        nome = map?['nome'] ?? '',
        logoUrl = map?['logoUrl'] ?? '',
        associacao = map?['associacao'] ?? '',
        regiao = map?['regiao'] ?? '',
        dataFundacao = map?['dataFundacao'] ?? '',
        reuniaoDia = map?['reuniaoDia'] ?? '',
        reuniaoHora = map?['reuniaoHora'] ?? '',
        regulamentoInterno = map?['regulamentoInterno'] ?? '',
        hino = map?['hino'] ?? '',
        pixChave = map?['pixChave'] ?? '',
        pixNomePessoa = map?['pixNomePessoa'] ?? '',
        primaryColor = map?['primaryColor'] ?? '',
        secondaryColor = map?['secondaryColor'] ?? '',
        codigo = map?['codigo'] ?? 0,
        taxaMensal = double.tryParse('${map?['taxaMensal']}') ?? 0;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'logoUrl': logoUrl,
    'associacao': associacao,
    'regiao': regiao,
    'dataFundacao': dataFundacao,
    'reuniaoDia': reuniaoDia,
    'reuniaoHora': reuniaoHora,
    'regulamentoInterno': regulamentoInterno,
    'hino': hino,
    'pixChave': pixChave,
    'pixNomePessoa': pixNomePessoa,
    'codigo': codigo,
    'taxaMensal': taxaMensal,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
  };

  Clube copy() => Clube.fromJson(toJson());

  @override
  String toString() => toJson().toString();
}