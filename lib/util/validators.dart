import 'package:email_validator/email_validator.dart';
import '../util/util.dart';

class Validators {

  static String? obrigatorio(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';

    return null;
  }

  static String? data(String? value) {
    if (value!.isEmpty) return null;
    const erro = 'Data inválida';

    final sp = value.split('/');
    if (sp.length != 3) return erro;

    final dia = int.tryParse(sp[0]) ?? 0;
    final mes = int.tryParse(sp[1]) ?? 0;
    final ano = int.tryParse(sp[2]) ?? 0;

    bool diaInvalido = dia < 1 || dia > 31;
    bool mesInvalido = mes < 1 || mes > 12;
    bool anoInvalido = ano < 1500;

    if (diaInvalido || mesInvalido || anoInvalido) return erro;

    return null;
  }

  static String? dataObrigatorio(String? value) {
    final test = Validators.obrigatorio(value);
    if (test != null) return test;

    return data(value);
  }


  static String? dropDownIntObrigatorio(int? value) {
    if (value == 0) return 'Campo obrigatório';

    return null;
  }


  static String? cpfObrigatorio(String? value) {
    var res = obrigatorio(value);
    if (res != null) return res;

    return cpf(value);
  }

  static String? cpf(String? value) {
    if (value == null || value.isEmpty) return null;

    final valido = CPFValidator.isValid(value);

    if (!valido) return 'CPF inválido';

    return null;
  }


  static String? emailObrigatorio(String? value) {
    var res = obrigatorio(value);
    if (res != null) return res;

    return email(value);
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailValido = EmailValidator.validate(value);
    if (!emailValido) return 'Email inválido.';

    return null;
  }


  static String? telefoneObrigatorio(String? value) {
    var res = obrigatorio(value);
    if (res != null) return res;

    return telefone(value);
  }

  static String? telefone(String? value) {
    if (value == null || value.isEmpty) return null;
    value = Formats.removeMascara(value);

    if (value.length < 10) return 'Número inválido';

    return null;
  }
}


class CPFValidator {
  static const List<String> blackList = [
    '00000000000',
    '11111111111',
    '22222222222',
    '33333333333',
    '44444444444',
    '55555555555',
    '66666666666',
    '77777777777',
    '88888888888',
    '99999999999',
    '12345678909'
  ];

  static const stripRegex = r'[^\d]';

  // Compute the Verifier Digit (or 'Dígito Verificador (DV)' in PT-BR).
  // You can learn more about the algorithm on [wikipedia (pt-br)](https://pt.wikipedia.org/wiki/D%C3%ADgito_verificador)
  static int _verifierDigit(String cpf) {
    var numbers =
    cpf.split('').map((number) => int.parse(number, radix: 10)).toList();

    var modulus = numbers.length + 1;

    var multiplied = <int>[];

    for (var i = 0; i < numbers.length; i++) {
      multiplied.add(numbers[i] * (modulus - i));
    }

    var mod = multiplied.reduce((buffer, number) => buffer + number) % 11;

    return (mod < 2 ? 0 : 11 - mod);
  }

  static String format(String cpf) {
    var regExp = RegExp(r'^(\d{3})(\d{3})(\d{3})(\d{2})$');

    return strip(cpf).replaceAllMapped(regExp, (Match m) => '${m[1]}.${m[2]}.${m[3]}-${m[4]}');
  }

  static String strip(String cpf) {
    var regExp = RegExp(stripRegex);

    return cpf.replaceAll(regExp, '');
  }

  static bool isValid(String cpf, {stripBeforeValidation = true}) {
    if (stripBeforeValidation) {
      cpf = strip(cpf);
    }

    // CPF must be defined
    // if (cpf == null || cpf.isEmpty) {
    //   return false;
    // }

    // CPF must have 11 chars
    if (cpf.length != 11) {
      return false;
    }

    // CPF can't be blacklisted
    if (blackList.contains(cpf)) {
      return false;
    }

    var numbers = cpf.substring(0, 9);
    numbers += _verifierDigit(numbers).toString();
    numbers += _verifierDigit(numbers).toString();

    return numbers.substring(numbers.length - 2) ==
        cpf.substring(cpf.length - 2);
  }

}

class CNPJValidator {
  static const List<String> blackList = [
    '00000000000000',
    '11111111111111',
    '22222222222222',
    '33333333333333',
    '44444444444444',
    '55555555555555',
    '66666666666666',
    '77777777777777',
    '88888888888888',
    '99999999999999'
  ];

  static const stripRegex = r'[^\d]';

  // Compute the Verifier Digit (or 'Dígito Verificador (DV)' in PT-BR).
  // You can learn more about the algorithm on [wikipedia (pt-br)](https://pt.wikipedia.org/wiki/D%C3%ADgito_verificador)
  static int _verifierDigit(String cnpj) {
    var index = 2;

    var reverse =
    cnpj.split('').map((s) => int.parse(s)).toList().reversed.toList();

    var sum = 0;

    for (var number in reverse) {
      sum += number * index;
      index = (index == 9 ? 2 : index + 1);
    }

    var mod = sum % 11;

    return (mod < 2 ? 0 : 11 - mod);
  }

  static String format(String cnpj) {
    var regExp = RegExp(r'^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$');

    return strip(cnpj).replaceAllMapped(
        regExp, (Match m) => '${m[1]}.${m[2]}.${m[3]}/${m[4]}-${m[5]}');
  }

  static String strip(String cnpj) {
    var regex = RegExp(stripRegex);

    return cnpj.replaceAll(regex, '');
  }

  static bool isValid(String cnpj, {stripBeforeValidation = true}) {
    if (stripBeforeValidation) {
      cnpj = strip(cnpj);
    }

    // cnpj must be defined
    // if (cnpj == null || cnpj.isEmpty) {
    //   return false;
    // }

    // cnpj must have 14 chars
    if (cnpj.length != 14) {
      return false;
    }

    // cnpj can't be blacklisted
    if (blackList.contains(cnpj)) {
      return false;
    }

    var numbers = cnpj.substring(0, 12);
    numbers += _verifierDigit(numbers).toString();
    numbers += _verifierDigit(numbers).toString();

    return numbers.substring(numbers.length - 2) ==
        cnpj.substring(cnpj.length - 2);
  }

}
