class Endereco {
  String cep = '';
  String num = '';
  String rua = '';
  String bairro = '';
  String cidade = '';
  String estado = '';
  String pais = '';

  Endereco({
    this.pais = '',
    this.estado = '',
    this.cidade = '',
    this.bairro = '',
    this.rua = '',
    this.num = '',
    this.cep = '',
  });

  Endereco.fromJson(Map? map) :
        cep = map?['cep'] ?? '',
        num = map?['num'] ?? '',
        rua = map?['rua'] ?? '',
        bairro = map?['bairro'] ?? '',
        cidade = map?['cidade'] ?? '',
        estado = map?['estado'] ?? '',
        pais = map?['pais'] ?? '';

  Map<String, dynamic> toJson() => {
    'cep': cep,
    'num': num,
    'rua': rua,
    'bairro': bairro,
    'cidade': cidade,
    'estado': estado,
    'pais': pais,
  };

  Endereco copy() => Endereco.fromJson(toJson());

  String get asString {
    String value = '';
    if (rua.isNotEmpty) value += rua;
    if (num.isNotEmpty) value += ', Nº $num';
    if (cidade.isNotEmpty) value += ', $cidade';

    return value;
  }
}