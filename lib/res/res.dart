import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../provider/provider.dart';
import '../util/util.dart';
export 'dialog_box.dart';
export 'popup.dart';
export 'tiles.dart';
export 'theme.dart';
export 'widgets.dart';

class Ressorces {
  static String get appName => VersionControlProvider.i.appName;

  static File get clubeLogo => StorageProvider.i.file(['clubeLogo.png']);

  static Color colorFromEventType(int value) {
    switch(value) {
      case 1: return Colors.blue; // Normal
      case 2: return Colors.blue; // Reunião de Pais
      case 3: return Colors.blue; // Investidura
      case 4: return Colors.greenAccent; // Atividade externa
      case 5: return Colors.yellowAccent; // Dia Mundial dos Desbravadores
      case 6: return Colors.blue; // Vigilia
      case 7: return Colors.blue; // Voz Juvenil
      case 8: return Colors.brown; // Acampamento
      case 9: return Colors.brown[900]!; // Acampamento liderança
      case 10: return Colors.black; // Pernoite
      case 15: return Colors.blue; // Fábrica de Líderes
      case 16: return Colors.amberAccent; // Semana do Lenço
      case 17: return Colors.blue; // Batismo da Primavera
      case 18: return Colors.blue; // Reunião semanal
      case 19: return Colors.blue; // Visita especial
      case 20: return Colors.blue; // Desbravador por 1 dia
      case 21: return Colors.blue; // Vamos com todos
      case 22: return Colors.blue; // Clube Pioneiro
      case 25: return Colors.blue; // Dia Mundial dos Aventureiros
      case 27: return Colors.blue; // Campori
      case 28: return Colors.blue; // Aventuri
      case 29: return Colors.blue; // CTBD
      case 30: return Colors.blue; // Olimpori
      case 31: return Colors.blue; // Curso de Campo
      case 32: return Colors.blue; // Rally de Líderes
      case 33: return Colors.blue; // Reunião Diretoria
      case 35: return Colors.blue; // Excursão
      case 43: return Colors.blue; // Aventureiro por 1 dia
      case 44: return Colors.blue; // Evento On-line
      case 47: return Colors.blue; // Abertura das Atividades
      case 48: return Colors.blue; // Encerramento das Atividades
      case 2222: return Colors.purple; // Encerramento das Atividades
      default: return Colors.transparent;
    }
  }
}

class Assets {
  static const agendaecTop = 'assets/images/agenda_decoration_top.png';
  static const agendaecBot = 'assets/images/agenda_decoration_bot.png';
  static const clubeLogo = 'assets/images/clube_logo.png';
  static const pdfTutorial = 'assets/images/pdf_tutorial.png';

  static Future<void> loadCidades() async {
    final json = await rootBundle.loadString('assets/files/cidades.json');
    Map map = jsonDecode(json);

    map.forEach((ufId, value) {
      int uf = int.parse(ufId);
      Arrays.cidades[uf] = {};
      value.forEach((cidadeId, value) {
        int city = int.parse(cidadeId);
        Arrays.cidades[uf]![city] = value.toString();
      });
    });
  }
}

class Arrays {

  static List<int> get cargosElevados => [
    6, 7, 8, 9, 12,
  ];

  static List<String> get diasSemana => [
    'DOMINGO',
    'SEGUNDA',
    'TERÇA',
    'QUARTA',
    'QUINTA',
    'SEXTA',
    'SÁBADO',
  ];


  static Map<int, String> get funcoes => {
    0: 'Selecionar',
    128: 'Almoxarife de Unidade',
    55: 'Ancião',
    102: 'Apoio',
    130: 'Capelão da Unidade',
    8: 'Capelão do Clube',
    15: 'Capitão de Unidade',
    11: 'Conselheiro',
    127: 'Conselheiro Associado',
    13: 'Cozinheiro do Clube',
    14: 'Desbravador',
    7: 'Diretor Associado',
    6: 'Diretor de Clube',
    108: 'Filho Diretoria (0 a 9 anos)',
    10: 'Instrutor',
    129: 'Padioleiro da Unidade',
    101: 'Pais de Desbravador',
    53: 'Profissional de Saúde',
    90: 'Secretario de Unidade ',
    12: 'Secretário do Clube',
    16: 'Segurança do Clube',
    91: 'Tesoureiro de Unidade',
    9: 'Tesoureiro do Clube',
  };

  static Map<int, String> get estadoCivil => {
    0: 'Selecionar',
    1: 'Casado',
    4: 'Divorciado',
    5: 'Não informado',
    2: 'Solteiro',
    3: 'Viúvo',
  };

  static Map<int, String> get tamanhoCamisa => {
    0: 'Selecionar',
    26: 'Adulto EXG',
    16: 'Adulto G',
    17: 'Adulto GG',
    15: 'Adulto M',
    14: 'Adulto P',
    21: 'Adulto PP',
    22: 'Adulto XG',
    18: 'Adulto XGG',
    19: 'Adulto XXGG',
    10: 'Baby-look G',
    11: 'Baby-look GG',
    9: 'Baby-look M',
    8: 'Baby-look P',
    24: 'Baby-look PP',
    23: 'Baby-look XG',
    12: 'Baby-look XGG',
    13: 'Baby-look XXGG',
    5: 'Infantil 10',
    6: 'Infantil 12',
    7: 'Infantil 14',
    25: 'Infantil 16',
    1: 'Infantil 2',
    2: 'Infantil 4',
    3: 'Infantil 6',
    4: 'Infantil 8',
  };

  static Map<int, String> get estado => {
    0: 'Selecionar',
    1: 'ACRE',
    2: 'ALAGOAS',
    4: 'AMAPÁ',
    3: 'AMAZONAS',
    5: 'BAHIA',
    6: 'CEARÁ',
    7: 'DISTRITO FEDERAL',
    8: 'ESPÍRITO SANTO',
    9: 'GOIÁS',
    10: 'MARANHÃO',
    13: 'MATO GROSSO',
    12: 'MATO GROSSO DO SUL',
    11: 'MINAS GERAIS',
    14: 'PARÁ',
    15: 'PARAÍBA',
    18: 'PARANÁ',
    16: 'PERNAMBUCO',
    17: 'PIAUÍ',
    19: 'RIO DE JANEIRO',
    20: 'RIO GRANDE DO NORTE',
    23: 'RIO GRANDE DO SUL',
    21: 'RONDÔNIA',
    22: 'RORAIMA',
    24: 'SANTA CATARINA',
    26: 'SÃO PAULO',
    25: 'SERGIPE',
    27: 'TOCANTINS',
  };

  static Map<int, String> get profSaude => {
    0: 'Não sou Profissional de Saúde',
    6: 'Dentista',
    2: 'Enfermeiro',
    4: 'Fisioterapeuta',
    1: 'Médico',
    7: 'Psicólogo',
    5: 'Socorrista',
    3: 'Técnico em Enfermagem',
  };

  static Map<int, String> get tipoSanguineo => {
    0: 'Selecionar',
    1: 'A+',
    2: 'A-',
    5: 'AB+',
    6: 'AB-',
    3: 'B+',
    4: 'B-',
    7: 'O+',
    8: 'O-',
    9: 'NÃO SABE',
  };

  static Map<int, String> get tipoEvento => {
    0: 'Selecione',
    47: 'Abertura das Atividades',
    8: 'Acampamento',
    9: 'Acampamento liderança',
    4: 'Atividade externa',
    43: 'Aventureiro por 1 dia',
    28: 'Aventuri',
    17: 'Batismo da Primavera',
    27: 'Campori',
    22: 'Clube Pioneiro',
    29: 'CTBD',
    31: 'Curso de Campo',
    20: 'Desbravador por 1 dia',
    25: 'Dia Mundial dos Aventureiros',
    5: 'Dia Mundial dos Desbravadores',
    48: 'Encerramento das Atividades',
    44: 'Evento On-line',
    35: 'Excursão',
    15: 'Fábrica de Líderes',
    3: 'Investidura',
    1: 'Normal',
    30: 'Olimpori',
    10: 'Pernoite',
    32: 'Rally de Líderes',
    2: 'Reunião de Pais',
    33: 'Reunião Diretoria',
    18: 'Reunião semanal',
    16: 'Semana do Lenço',
    21: 'Vamos com todos',
    6: 'Vigilia',
    19: 'Visita especial',
    7: 'Voz Juvenil',

    2222: 'Aniversário',
  };

  static Map<int, String> get tipoConta => {
    0: 'Selecione',
    37: 'Acampamento',
    12: 'Ajustes',
    14: 'Alimentação',
    10: 'Aquisições',
    17: 'Associação/Missão',
    25: 'Aventuri',
    28: 'Barracas',
    29: 'Brindes',
    5: 'Caixa da Igreja',
    26: 'Campori',
    18: 'Consumo',
    21: 'Despesas internas',
    2: 'Doações',
    31: 'Equipamentos',
    4: 'Eventos',
    36: 'Gráfica',
    35: 'Hospedagem',
    9: 'Inscrições',
    33: 'Lazer',
    24: 'Liderança',
    32: 'Locações',
    15: 'Materiais',
    1: 'Mensalidades',
    8: 'Outros',
    34: 'Passagens',
    13: 'Reembolso',
    16: 'Salário',
    19: 'Secretaria',
    7: 'Seguro anual',
    30: 'Seguros',
    6: 'Taxas',
    20: 'Transporte',
    23: 'Treinamentos',
    22: 'Unidades e equipes',
    27: 'Uniformes',
    11: 'Vendas',
    3: 'Viagens',
  };

  static Map<int, String> get classes => {
    1: 'Amigo',
    21: 'Amigos da Natureza',
    2: 'Companheiro',
    22: 'Companheiro de Excursionismo',
    5: 'Excursionista',
    25: 'Excursionista na Mata',
    6: 'Guia',
    26: 'Guia de Exploração',
    3: 'Pesquisador',
    23: 'Pesquisador de Campos e Bosques',
    4: 'Pioneiro',
    24: 'Pioneiro de Novas Fronteiras',
  };


  /// <estadoId, cidadeId, nome>
  static final Map<int, Map<int, String>> cidades = {};
}

class VariaveisGlobais {

  static bool get listMode => pref.getBool(PrefKey.listMode);
  static set listMode(bool value) => pref.setBool(PrefKey.listMode, value);
}