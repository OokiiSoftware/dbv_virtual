import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:intl/intl.dart';

class Formats {

  static final formatoDecimalValor = NumberFormat('#,##0.00', 'pt_BR');

  /// Formato yyyy-MM-dd
  static String dataUs(DateTime? data) {
    if (data == null) return 'data inválida';

    var formatter = DateFormat('yyyy-MM-dd');
    String horaFormatada = formatter.format(data);
    return horaFormatada;
  }

  /// Formato yyyy-MM-dd HH-mm-ss
  static String dataHoraUs(DateTime? data) {
    if (data == null) return 'data inválida';

    var formatter = DateFormat('yyyy-MM-dd HH-mm-ss');
    String horaFormatada = formatter.format(data);
    return horaFormatada;
  }

  /// Formato dd/MM/yyyy
  static String data(DateTime? data) {
    if (data == null) return '';

    var formatter = DateFormat('dd/MM/yyyy');
    String dataFormatada = formatter.format(data);
    return dataFormatada;
  }

  /// Formato dd/MM/yyyy HH:mm:ss
  static String dataHora(DateTime? data) {
    if (data == null) return '';

    var formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    String dataHoraFormatada = formatter.format(data);
    return dataHoraFormatada;
  }

  static DateTime? stringToDateTime(String? value) {
    if (value == null) return null;

    value = value.split(' ').first;
    final sp = value.split('-');
    if (sp[0].length == 4) {
      value = '${sp[2]}/${sp[1]}/${sp[0]}';
    }

    return DateFormat('dd/MM/yyyy').tryParse(value);
  }

  static String? convertData(String? value) {
    if (value == null) return null;

    value = value
        .split(' ')
        .first;
    final sp = value.split('-');
    if (sp[0].length == 4) {
      return '${sp[2]}/${sp[1]}/${sp[0]}';
    }
    return value;
  }


  /// Converte (2024-12-01 23:00:00) pra (12-01)
  static String convertTime(int value) {
    var date = DateTime.fromMillisecondsSinceEpoch(value).toString();
    return date.substring(date.indexOf('-') +1, date.indexOf(' '));
  }

  static String formatarValorDecimal(double? valor, {String prefix = '', String sufix = ''}) {
    return '$prefix${formatoDecimalValor.format(valor ?? 0)}$sufix';
  }

  static String formatarCpf(String value) {
    return MaskedTextController(mask: Masks.cpf, text: value).text;
  }

  static String formatarTelefone(String value) {
    value = removeMascara(value);
    if (value.length == 10) {
      return MaskedTextController(mask: Masks.phone8, text: value).text;
    }

    return MaskedTextController(mask: Masks.phone9, text: value).text;
  }

  static String formatarCep(String value) {
    return MaskedTextController(mask: Masks.cep, text: value).text;
  }


  /// útil para campos do tipo: CPF, CNPJ, CEP, etc
  static String removeMascara(String value) {
    return value.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '');
  }

  static String intToMes(int value) {
    switch(value) {
      case 1: return 'Janeiro';
      case 2: return 'Fevereiro';
      case 3: return 'Março';
      case 4: return 'Abril';
      case 5: return 'Maio';
      case 6: return 'Junho';
      case 7: return 'Julho';
      case 8: return 'Agosto';
      case 9: return 'Setembro';
      case 10: return 'Outubro';
      case 11: return 'Novembro';
      case 12: return 'Dezembro';
      default: return '';
    }
  }

  static String intToSemana(int value) {
    switch(value) {
      case 1: return 'Domingo';
      case 2: return 'Segunda';
      case 3: return 'Terça';
      case 4: return 'Quarta';
      case 5: return 'Quinta';
      case 6: return 'Sexta';
      case 7: return 'Sábado';
      default: return '';
    }
  }

  static String intToSemanaSort(int value) {
    switch(value) {
      case 1: return 'Dom';
      case 2: return 'Seg';
      case 3: return 'Ter';
      case 4: return 'Qua';
      case 5: return 'Qui';
      case 6: return 'Sex';
      case 7: return 'Sáb';
      default: return '';
    }
  }

}

class Masks {

  static const date = '00/00/0000';
  static const dateUs = '0000/00/00';

  static const phone8 = '(00) 0000-0000';
  static const phone9 = '(00) 00000-0000';

  static const cep = '00.000-000';

  static const cpf = '000.000.000-00';
  static const cnpj = '00.000.000/0000-00';

}