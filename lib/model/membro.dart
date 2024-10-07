import '../../util/util.dart';
import '../../res/res.dart';
import 'model.dart';

class Membro extends ItemModel {

  //region variaveis
  @override
  String get id => '_$codUsuario';

  String nomeUsuario = '';
  String sexo = '';
  String dtNascimento = '';
  String celUsuario = '';
  String emailUsuario = '';
  String cepUsuario = '';
  String endUsuario = '';
  String bairroUsuario = '';
  String certidao = '';
  String rg = '';
  String orgExp = '';
  String cpf = '';
  String docProf = '';
  String nomePai = '';
  String emailPai = '';
  String telPai = '';
  String nomeMae = '';
  String emailMae = '';
  String telMae = '';

  String responsavel = '';
  String vinculoResponsavel = '';
  String emailResponsavel = '';
  String telResponsavel = '';
  String cpfResp = '';

  int codUsuario = 0;
  int codFuncao = 0;
  int codEstadoCivil = 0;
  int codCamiseta = 0;
  int codEstado = 0;
  int codCidade = 0;
  int codTipoProf = 0;

  bool batizado = false;
  //endregion

  FichaMedica fichaMedica = FichaMedica();

  bool fichaPendente = false;
  bool segurado = false;
  bool selected = false;
  String? fotoTemp;


  Membro({
    this.nomeUsuario = '',
    this.sexo = '',
    this.dtNascimento = '',
    this.celUsuario = '',
    this.emailUsuario = '',
    this.cepUsuario = '',
    this.endUsuario = '',
    this.bairroUsuario = '',
    this.certidao = '',
    this.rg = '',
    this.orgExp = '',
    this.cpf = '',
    this.docProf = '',
    this.nomePai = '',
    this.emailPai = '',
    this.telPai = '',
    this.nomeMae = '',
    this.emailMae = '',
    this.telMae = '',
    this.responsavel = '',
    this.vinculoResponsavel = '',
    this.emailResponsavel = '',
    this.telResponsavel = '',
    this.cpfResp = '',

    this.codUsuario = 0,
    this.codFuncao = 0,
    this.codEstadoCivil = 0,
    this.codCamiseta = 0,
    this.codEstado = 0,
    this.codCidade = 0,
    this.codTipoProf = 0,

    this.batizado = false,
    this.segurado = false,
    this.fichaPendente = false,
  });

  Membro.fromJson(Map? map) :
        nomeUsuario = map?['nome_usuario'] ?? map?['nome'] ?? '',
        sexo = map?['sexo'] ?? '',
        dtNascimento = map?['dt_nascimento'] ?? map?['dataNasc'] ?? '',
        celUsuario = map?['cel_usuario'] ?? map?['celular'] ?? '',
        emailUsuario = map?['email_usuario'] ?? map?['email'] ?? '',
        cepUsuario = map?['cep_usuario'] ?? map?['endereco']?['cep'] ?? '',
        endUsuario = map?['end_usuario'] ?? map?['endereco']?['rua'] ?? '',
        bairroUsuario = map?['bairro_usuario'] ?? map?['endereco']?['bairro'] ?? '',
        certidao = map?['certidao'] ?? '',
        rg = map?['rg'] ?? '',
        orgExp = map?['org_exp'] ?? '',
        cpf = map?['cpf'] ?? '',
        docProf = map?['doc_prof'] ?? '',
        nomePai = map?['nome_pai'] ?? '',
        emailPai = map?['email_pai'] ?? '',
        telPai = map?['tel_pai'] ?? '',
        nomeMae = map?['nome_mae'] ?? '',
        emailMae = map?['email_mae'] ?? '',
        telMae = map?['tel_mae'] ?? '',
        responsavel = map?['responsavel'] ?? '',
        vinculoResponsavel = map?['vinculo_responsavel'] ?? '',
        emailResponsavel = map?['email_responsavel'] ?? '',
        telResponsavel = map?['tel_responsavel'] ?? '',
        cpfResp = map?['cpf_resp'] ?? '',

        fotoTemp = map?['fotoTemp'],

        codUsuario = map?['cod_usuario'] ?? int.tryParse(map?['codigo'] ?? '') ?? 0,
        codFuncao = map?['cod_funcao'] ?? Util.codFuncaoByText(map?['cargo'] ?? ''),
        codEstadoCivil = map?['cod_estado_civil'] ?? 0,
        codCamiseta = map?['cod_camiseta'] ?? 0,
        codTipoProf = map?['cod_tipo_prof'] ?? 0,

        batizado = map?['batizado'] ?? false,
        segurado = map?['segurado'] ?? false,
        fichaPendente = map?['fichaPendente'] ?? false,
        fichaMedica = FichaMedica.fromJson(map?['fichaMedica']) {
    codEstado = map?['cod_estado'] ?? Util.codEstadoByText(map?['endereco']?['estado'] ?? '');
    codCidade = map?['cod_cidade'] ?? Util.codCidadeByText(codEstado, map?['endereco']?['cidade'] ?? '');
  }

  static Map<String, Membro> fromJsonList(Map? map) {
    Map<String, Membro> items = {};

    map?.forEach((key, value) {
      items[key] = Membro.fromJson(value);
    });

    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome_usuario': nomeUsuario,
    'sexo': sexo,
    'dt_nascimento': dtNascimento,
    'cel_usuario': celUsuario,
    'email_usuario': emailUsuario.toLowerCase(),
    'cep_usuario': cepUsuario,
    'end_usuario': endUsuario,
    'bairro_usuario': bairroUsuario,
    'certidao': certidao,
    'rg': rg,
    'org_exp': orgExp,
    'cpf': cpf,
    'doc_prof': docProf,
    'nome_pai': nomePai,
    'email_pai': emailPai.toLowerCase(),
    'tel_pai': telPai,
    'nome_mae': nomeMae,
    'email_mae': emailMae.toLowerCase(),
    'tel_mae': telMae,
    'responsavel': responsavel,
    'vinculo_responsavel': vinculoResponsavel,
    'email_responsavel': emailResponsavel.toLowerCase(),
    'tel_responsavel': telResponsavel,
    'cpf_resp': cpfResp,

    'cod_usuario': codUsuario,
    'cod_funcao': codFuncao,
    'cod_estado_civil': codEstadoCivil,
    'cod_camiseta': codCamiseta,
    'cod_estado': codEstado,
    'cod_cidade': codCidade,
    'cod_tipo_prof': codTipoProf,
    if (fotoTemp != null)
      'fotoTemp': fotoTemp,

    'fichaMedica': fichaMedica.toJson(),

    if (batizado)
      'batizado': true,
    if (segurado)
      'segurado': true,
    if (fichaPendente)
      'fichaPendente': true,

    /*'nome': nomeUsuario,
    'email': emailUsuario,
    'codigo': codUsuario,
    'dataNasc': dtNascimento,
    'cargo': cargo,
    'celular': celUsuario,
    'camisa': Arrays.tamanhoCamisa[codCamiseta],
    'endereco': Endereco(
      rua: endUsuario,
      bairro: bairroUsuario,
      cep: cepUsuario,
      estado: Arrays.estado[codEstado] ?? '',
      cidade: Arrays.cidades[codEstado]?[codCidade] ?? '',
    ).toJson(),*/
  };


  String get cargo => Arrays.funcoes[codFuncao] ?? '';

  String get foto => 'https://sg.sdasystems.org/cms/fotos_membros/$codUsuario.jpg';

  DateTime? get dataNascimento {
    return Formats.stringToDateTime(dtNascimento);
  }

  int? get idade {
    final hoje = DateTime.now();
    final dias = dataNascimento?.difference(DateTime(0)).inDays;
    if (dias == null) return null;

    return (hoje.subtract(Duration(days: dias))).year;
  }

  String get endereco {
    return '$endUsuario, $bairroUsuario';
  }

  List<List<dynamic>> verificarAlteracao(Map<String, dynamic> map, {Map? recursiveMap}) {
    List<List<dynamic>> dados = [];
    final json = recursiveMap ?? toJson();

    var keys = <String>[...json.keys, ...map.keys];
    keys = keys.toSet().toList();

    for(var key in keys) {
      final value = json[key];
      final newValue = map[key];

      if (key == 'id') continue;
      if (key == 'fotoTemp') continue;

      if (key.contains('cod_')) {
        dynamic valueA;
        dynamic valueB;

        switch(key) {
          case 'cod_camiseta':
            valueA = Arrays.tamanhoCamisa[value];
            valueB = Arrays.tamanhoCamisa[newValue];
            break;
          case 'cod_estado':
            valueA = Arrays.estado[value];
            valueB = Arrays.estado[newValue];
            break;
          case 'cod_cidade':
            final estadoA = json['cod_estado'];
            final estadoB = map['cod_estado'];
            valueA = Arrays.cidades[estadoA]?[value];
            valueB = Arrays.cidades[estadoB]?[newValue];
            break;
          case 'cod_estado_civil':
            valueA = Arrays.estadoCivil[value];
            valueB = Arrays.estadoCivil[newValue];
            break;
          case 'cod_funcao':
            valueA = Arrays.funcoes[value];
            valueB = Arrays.funcoes[newValue];
            break;
          case 'cod_tipo_prof':
            valueA = Arrays.profSaude[value];
            valueB = Arrays.profSaude[newValue];
            break;
        }

        final key2 = key.replaceAll('cod_', '');
        if (valueA != valueB) dados.add([key2, valueA, valueB]);
        continue;
      }

      if (value is Map) {
        dados.addAll(verificarAlteracao(newValue, recursiveMap: value));
      } else {
        if (value != newValue) {
          dados.add([key, value, newValue]);
        }
      }
    }

    return dados;
  }

  Membro copy() => Membro.fromJson(toJson());

  @override
  String toString() => toJson().toString();
}

class FichaMedica {

  //region variaveis
  String dtConfirmacao = ''; // data de envio
  String descPlano = '';
  String carteira = '';

  String remediosCardiaco = '';
  String remediosDiabetes = '';
  String remediosRenal = '';
  String remediosMental = '';
  String problemas = '';
  String remedio = '';
  String recente = '';
  String recenteRemedio = '';
  String alergia = '';
  String alergiaRemedio = '';
  String ferimento = '';
  String fratura = '';
  String tempoFratura = '';
  String cirurgia = '';
  String internacao = '';

  int codFicha = 0;
  int codUsuario = 0;
  int codSangue = 0;

  bool plano = false; // plano de saúde
  bool catapora = false;
  bool meningite = false;
  bool hepatite = false;
  bool dengue = false;
  bool pneumonia = false;
  bool malaria = false;
  bool febre = false; // febre amarela
  bool h1n1 = false;
  bool covid = false;
  bool colera = false;
  bool rubeola = false;
  bool sarampo = false;
  bool tetano = false;
  bool variola = false;
  bool coqueluche = false;
  bool difteria = false;
  bool caxumba = false;
  bool sangue = false;
  bool pele = false;
  bool alimentar = false;
  bool medicamento = false;
  bool renite = false;
  bool bronquite = false;
  bool cadeirante = false;
  bool visual = false;
  bool auditivo = false;
  bool fala = false;
  bool cardiaco = false;
  bool diabetes = false;
  bool renal = false;
  bool mental = false;

  bool confirmacao = false; // confirmacao de verificação

  //endregion

  FichaMedica();

  FichaMedica.fromJson(Map? map) :
        dtConfirmacao = map?['dt_confirmacao'] ?? '',
        descPlano = map?['desc_plano'] ?? '',
        carteira = map?['carteira'] ?? '',
        remediosCardiaco = map?['remedios_cardiaco'] ?? '',
        remediosDiabetes = map?['remedios_diabetes'] ?? '',
        remediosRenal = map?['remedios_renal'] ?? '',
        remediosMental = map?['remedios_mental'] ?? '',
        problemas = map?['problemas'] ?? '',
        remedio = map?['remedio'] ?? '',
        recente = map?['recente'] ?? '',
        recenteRemedio = map?['recente_remedio'] ?? '',
        alergia = map?['alergia'] ?? '',
        alergiaRemedio = map?['alergia_remedio'] ?? '',
        ferimento = map?['ferimento'] ?? '',
        fratura = map?['fratura'] ?? '',
        tempoFratura = map?['tempo_fratura'] ?? '',
        cirurgia = map?['cirurgia'] ?? '',
        internacao = map?['internacao'] ?? '',

        codFicha = map?['cod_ficha'] ?? 0,
        codUsuario = map?['cod_usuario'] ?? 0,
        codSangue = map?['cod_sangue'] ?? 0,

        plano = map?['plano'] ?? false,
        catapora = map?['catapora'] ?? false,
        meningite = map?['meningite'] ?? false,
        hepatite = map?['hepatite'] ?? false,
        dengue = map?['dengue'] ?? false,
        pneumonia = map?['pneumonia'] ?? false,
        malaria = map?['malaria'] ?? false,
        febre = map?['febre'] ?? false,
        h1n1 = map?['h1n1'] ?? false,
        covid = map?['covid'] ?? false,
        colera = map?['colera'] ?? false,
        rubeola = map?['rubeola'] ?? false,
        sarampo = map?['sarampo'] ?? false,
        tetano = map?['tetano'] ?? false,
        variola = map?['variola'] ?? false,
        coqueluche = map?['coqueluche'] ?? false,
        difteria = map?['difteria'] ?? false,
        caxumba = map?['caxumba'] ?? false,
        sangue = map?['sangue'] ?? false,
        pele = map?['pele'] ?? false,
        alimentar = map?['alimentar'] ?? false,
        medicamento = map?['medicamento'] ?? false,
        renite = map?['renite'] ?? false,
        bronquite = map?['bronquite'] ?? false,
        cadeirante = map?['cadeirante'] ?? false,
        visual = map?['visual'] ?? false,
        auditivo = map?['auditivo'] ?? false,
        fala = map?['fala'] ?? false,
        cardiaco = map?['cardiaco'] ?? false,
        diabetes = map?['diabetes'] ?? false,
        renal = map?['renal'] ?? false,
        mental = map?['mental'] ?? false,
        confirmacao = map?['confirmacao'] ?? false;

  Map<String, dynamic> toJson() => {
    'dt_confirmacao': dtConfirmacao,
    'desc_plano': descPlano,
    'carteira': carteira,
    'remedios_cardiaco': remediosCardiaco,
    'remedios_diabetes': remediosDiabetes,
    'remedios_renal': remediosRenal,
    'problemas': problemas,
    'remedio': remedio,
    'recente': recente,
    'recente_remedio': recenteRemedio,
    'alergia': alergia,
    'alergia_remedio': alergiaRemedio,
    'ferimento': ferimento,
    'fratura': fratura,
    'tempo_fratura': tempoFratura,
    'cirurgia': cirurgia,
    'internacao': internacao,

    'cod_ficha': codFicha,
    'cod_usuario': codUsuario,
    'cod_sangue': codSangue,

    if (plano)
      'plano': plano,
    if (catapora)
      'catapora': catapora,
    if (meningite)
      'meningite': meningite,
    if (hepatite)
      'hepatite': hepatite,
    if (dengue)
      'dengue': dengue,
    if (pneumonia)
      'pneumonia': pneumonia,
    if (malaria)
      'malaria': malaria,
    if (febre)
      'febre': febre,
    if (h1n1)
      'h1n1': h1n1,
    if (covid)
      'covid': covid,
    if (colera)
      'colera': colera,
    if (rubeola)
      'rubeola': rubeola,
    if (sarampo)
      'sarampo': sarampo,
    if (tetano)
      'tetano': tetano,
    if (variola)
      'variola': variola,
    if (coqueluche)
      'coqueluche': coqueluche,
    if (difteria)
      'difteria': difteria,
    if (caxumba)
      'caxumba': caxumba,
    if (sangue)
      'sangue': sangue,
    if (pele)
      'pele': pele,
    if (alimentar)
      'alimentar': alimentar,
    if (medicamento)
      'medicamento': medicamento,
    if (renite)
      'renite': renite,
    if (bronquite)
      'bronquite': bronquite,
    if (cadeirante)
      'cadeirante': cadeirante,
    if (visual)
      'visual': visual,
    if (auditivo)
      'auditivo': auditivo,
    if (fala)
      'fala': fala,
    if (cardiaco)
      'cardiaco': cardiaco,
    if (diabetes)
      'diabetes': diabetes,
    if (renal)
      'renal': renal,
    if (mental)
      'mental': mental,
    if (confirmacao)
      'confirmacao': confirmacao,
  };


  FichaMedica copy() => FichaMedica.fromJson(toJson());

  @override
  String toString() => toJson().toString();

}