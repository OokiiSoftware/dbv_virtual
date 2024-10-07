import 'package:flutter/services.dart';

class TextType {

  //region variaveis

  static const int noneValue = 75;
  static const int nameValue = 89;
  static const int textValue = 45;
  static const int dataValue = 86;
  static const int horaValue = 41;
  static const int cepValue = 56;
  static const int susValue = 52;
  static const int cpfValue = 77;
  static const int cnpjValue = 98;
  static const int phoneValue = 265;
  static const int numeroValue = 908;
  static const int dinheiroValue = 25;
  static const int emailAddressValue = 498;
  static const int streetAddressValue = 546;

  static TextType get none => TextType(noneValue);
  static TextType get name => TextType(nameValue);
  static TextType get text => TextType(textValue);
  static TextType get data => TextType(dataValue);
  static TextType get hora => TextType(horaValue);
  static TextType get cep => TextType(cepValue);
  static TextType get sus => TextType(susValue);
  static TextType get cpf => TextType(cpfValue);
  static TextType get cnpj => TextType(cnpjValue);
  static TextType get phone => TextType(phoneValue);
  static TextType get numero => TextType(numeroValue);
  static TextType get dinheiro => TextType(dinheiroValue);
  static TextType get emailAddress => TextType(emailAddressValue);
  static TextType get streetAddress => TextType(streetAddressValue);

  //endregion

  final List<TextInputFormatter> inputFormatters = [];
  late TextInputType _textInputType;

  TextType(this.value) {
    if (isNumero) {
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
      _textInputType = TextInputType.number;
    }

    switch(value) {
      case TextType.nameValue:
        _textInputType = TextInputType.name;
        break;
      case TextType.textValue:
        _textInputType = TextInputType.text;
        break;
      case TextType.streetAddressValue:
        _textInputType = TextInputType.streetAddress;
        break;
      case TextType.emailAddressValue:
        _textInputType = TextInputType.emailAddress;
        break;

      case TextType.dinheiroValue:
        inputFormatters.add(TextFormatterReal(centavos: true));
        break;
      case TextType.cepValue:
        inputFormatters.add(TextFormatterCEP());
        break;
      case TextType.susValue:
        inputFormatters.add(TextFormatterSUS());
        break;
      case TextType.phoneValue:
        _textInputType = TextInputType.phone;
        inputFormatters.add(TextFormatterPhone());
        break;
      case TextType.cpfValue:
        inputFormatters.add(TextFormatterCPF());
        break;
      case TextType.cnpjValue:
        inputFormatters.add(TextFormatterCnpj());
        break;
      case TextType.dataValue:
        _textInputType = TextInputType.datetime;
        inputFormatters.add(TextFormatterData());
        break;
      case TextType.horaValue:
        _textInputType = TextInputType.datetime;
        inputFormatters.add(TextFormatterHora());
        break;
      case TextType.numeroValue:
        break;
      default:
        _textInputType = TextInputType.none;
    }
    // if (Platform.isWindows)
    //   inputFormatters.add(TextFormatterCorretor());
  }

  final int value;

  TextInputType get textInputType => _textInputType;

  bool get isNumero {
    return value == cepValue ||
        value == phoneValue ||
        value == cpfValue ||
        value == susValue ||
        value == cnpjValue ||
        value == dataValue ||
        value == horaValue ||
        value == dinheiroValue ||
        value == numeroValue;
  }

  TextType get upperCase {
    inputFormatters.add(TextFormatterUpperCase());
    return this;
  }
  TextType get lowerCase {
    inputFormatters.add(TextFormatterLowerCase());
    return this;
  }

}

class TextFormatterUpperCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
        composing: newValue.composing
    );
  }
}
class TextFormatterLowerCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toLowerCase(),
        selection: newValue.selection,
        composing: newValue.composing
    );
  }
}

/// Data Formatter 01/12/2000
class TextFormatterData extends TextInputFormatter {

  final int maxLength = 8;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTextLength = newValue.text.length;
    var selectionIndex = newValue.selection.end;

    if (novoTextLength > maxLength) {
      return oldValue;
    }

    var usedSubstringIndex = 0;
    final newText = StringBuffer();

    if (novoTextLength >= 3) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 2)}/');
      if (newValue.selection.end >= 2) selectionIndex++;
    }
    if (novoTextLength >= 5) {
      newText.write('${newValue.text.substring(2, usedSubstringIndex = 4)}/');
      if (newValue.selection.end >= 4) selectionIndex++;
    }
    if (novoTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// Hora Formatter HH:mm
class TextFormatterHora extends TextInputFormatter {
  /// Define o tamanho máximo do campo.
  final int maxLength = 4;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTextLength = newValue.text.length;
    var selectionIndex = newValue.selection.end;

    var usedSubstringIndex = 0;
    final newText = StringBuffer();

    if (novoTextLength > maxLength) {
      return oldValue;
    }

    switch (novoTextLength) {
      case 1:
        final hora = int.tryParse(newValue.text.substring(0, 1));
        if (hora != null) {
          if (hora >= 3) return oldValue;
        }
        break;
      case 2:
        final hora = int.tryParse(newValue.text.substring(0, 2));
        if (hora != null) {
          if (hora >= 24) return oldValue;
        }
        break;
      case 3:
        final minuto = int.tryParse(newValue.text.substring(2, 3));
        if (minuto != null) {
          if (minuto >= 6) return oldValue;
        }
        newText
            .write('${newValue.text.substring(0, usedSubstringIndex = 2)}:');
        if (newValue.selection.end >= 2) selectionIndex++;
        break;
      case 4:
        final minuto = int.tryParse(newValue.text.substring(2, 4));
        if (minuto != null) {
          if (minuto >= 60) return oldValue;
        }
        newText
            .write('${newValue.text.substring(0, usedSubstringIndex = 2)}:');
        if (newValue.selection.end >= 2) selectionIndex++;
        break;
      default:
    }

    if (novoTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// Telefone Formatter (00) 91234-1234
class TextFormatterPhone extends TextInputFormatter {

  final int maxLength = 11;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTextLength = newValue.text.length;

    var selectionIndex = newValue.selection.end;

    if (novoTextLength == 11) {
      if (newValue.text.toString()[2] != '9') {
        return oldValue;
      }
    }

    /// Verifica o tamanho máximo do campo.
    if (novoTextLength > maxLength) {
      return oldValue;
    }

    var usedSubstringIndex = 0;

    final newText = StringBuffer();

    if (novoTextLength >= 1) {
      newText.write('(');
      if (newValue.selection.end >= 1) selectionIndex++;
    }

    if (novoTextLength >= 3) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 2)}) ');
      if (newValue.selection.end >= 2) selectionIndex += 2;
    }

    if (newValue.text.length == 11) {
      if (novoTextLength >= 8) {
        newText
            .write('${newValue.text.substring(2, usedSubstringIndex = 7)}-');
        if (newValue.selection.end >= 7) selectionIndex++;
      }
    } else {
      if (novoTextLength >= 7) {
        newText
            .write('${newValue.text.substring(2, usedSubstringIndex = 6)}-');
        if (newValue.selection.end >= 6) selectionIndex++;
      }
    }

    if (novoTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// CPF Formatter (000.000.000-00)
class TextFormatterCPF extends TextInputFormatter {
  /// Define o tamanho máximo do campo.
  int get maxLength => 11;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTextLength = newValue.text.length;
    var selectionIndex = newValue.selection.end;

    if (novoTextLength > maxLength) {
      return oldValue;
    }

    var usedSubstringIndex = 0;
    final newText = StringBuffer();

    if (novoTextLength >= 4) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)}.');
      if (newValue.selection.end >= 3) selectionIndex++;
    }
    if (novoTextLength >= 7) {
      newText.write('${newValue.text.substring(3, usedSubstringIndex = 6)}.');
      if (newValue.selection.end >= 6) selectionIndex++;
    }
    if (novoTextLength >= 10) {
      newText.write('${newValue.text.substring(6, usedSubstringIndex = 9)}-');
      if (newValue.selection.end >= 9) selectionIndex++;
    }
    if (novoTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// CNPJ Formatter (00.000.000/1000-00)
class TextFormatterCnpj extends TextInputFormatter {
  /// Define o tamanho máximo do campo.
  int get maxLength => 14;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTextLength = newValue.text.length;
    var selectionIndex = newValue.selection.end;

    if (novoTextLength > maxLength) {
      return oldValue;
    }

    var usedSubstringIndex = 0;
    final newText = StringBuffer();

    if (novoTextLength >= 3) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 2)}.');
      if (newValue.selection.end >= 2) selectionIndex++;
    }
    if (novoTextLength >= 6) {
      newText.write('${newValue.text.substring(2, usedSubstringIndex = 5)}.');
      if (newValue.selection.end >= 5) selectionIndex++;
    }
    if (novoTextLength >= 9) {
      newText.write('${newValue.text.substring(5, usedSubstringIndex = 8)}/');
      if (newValue.selection.end >= 8) selectionIndex++;
    }
    if (novoTextLength >= 13) {
      newText.write('${newValue.text.substring(8, usedSubstringIndex = 12)}-');
      if (newValue.selection.end >= 12) selectionIndex++;
    }
    if (novoTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// CEP Formatter (00.000-00)
class TextFormatterCEP extends TextInputFormatter {
  /// Define o tamanho máximo do campo.
  final maxLength = 8;

  /// [incluirPonto] indica se o formato do CEP deve utilizar `.` ou não.
  final bool incluirPonto;

  TextFormatterCEP({this.incluirPonto = true});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final valorNovoLength = newValue.text.length;
    var selectionIndex = newValue.selection.end;

    if (valorNovoLength > maxLength) {
      return oldValue;
    }
    var substrInicio = 2;
    if (!incluirPonto) {
      substrInicio = 0;
    }

    var substrIndex = 0;
    final valorFinal = StringBuffer();

    if (valorNovoLength >= 3 && incluirPonto) {
      valorFinal.write('${newValue.text.substring(0, substrIndex = 2)}.');
      if (newValue.selection.end >= 2) selectionIndex++;
    }
    if (valorNovoLength >= 6) {
      valorFinal
          .write('${newValue.text.substring(substrInicio, substrIndex = 5)}-');
      if (newValue.selection.end >= 5) selectionIndex++;
    }

    if (valorNovoLength >= substrIndex) {
      valorFinal.write(newValue.text.substring(substrIndex));
    }

    return TextEditingValue(
      text: valorFinal.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// SUS Card Formatter (0000 0000 0000 0000)
class TextFormatterSUS extends TextInputFormatter {
  /// Define o tamanho máximo do campo.
  int get maxLength => 16;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTextLength = newValue.text.length;
    var selectionIndex = newValue.selection.end;

    if (novoTextLength > maxLength) {
      return oldValue;
    }

    var usedSubstringIndex = 0;
    final newText = StringBuffer();

    if (novoTextLength < maxLength) {
      if (novoTextLength >= 4) {
        newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)} ');
        if (newValue.selection.end >= 2) selectionIndex++;
      }
      if (novoTextLength >= 8) {
        newText.write('${newValue.text.substring(3, usedSubstringIndex = 7)} ');
        if (newValue.selection.end >= 5) selectionIndex++;
      }
      if (novoTextLength >= 12) {
        newText.write('${newValue.text.substring(7, usedSubstringIndex = 11)} ');
        if (newValue.selection.end >= 7) selectionIndex++;
      }
      if (novoTextLength >= usedSubstringIndex) {
        newText.write(newValue.text.substring(usedSubstringIndex));
      }
    } else {
      if (novoTextLength >= 5) {
        newText.write('${newValue.text.substring(0, usedSubstringIndex = 4)} ');
        if (newValue.selection.end >= 3) selectionIndex++;
      }
      if (novoTextLength >= 9) {
        newText.write('${newValue.text.substring(4, usedSubstringIndex = 8)} ');
        if (newValue.selection.end >= 6) selectionIndex++;
      }
      if (novoTextLength >= 13) {
        newText.write('${newValue.text.substring(8, usedSubstringIndex = 12)} ');
        if (newValue.selection.end >= 9) selectionIndex++;
      }
      if (novoTextLength >= usedSubstringIndex) {
        newText.write(newValue.text.substring(usedSubstringIndex));
      }
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// Real Formatter (9.999.999.999,00).
/// [centavos] indica se o campo deve ter centavos ou não.
class TextFormatterReal extends TextInputFormatter {

  TextFormatterReal({this.centavos = false, this.moeda = false});

  /// Define o tamanho máximo do campo.
  int maxLength = 12;

  /// [centavos] para indicar se o campo aceita centavos ou não.
  final bool centavos;
  final bool moeda;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTextLength = newValue.text.length;
    var selectionIndex = newValue.selection.end;

    if (novoTextLength > maxLength) {
      return oldValue;
    }

    const currency = 'R\$ ';
    var usedSubstringIndex = 0;
    final newText = StringBuffer();
    if (moeda) {
      if (centavos) {
        maxLength = 14;
        switch (novoTextLength) {
          case 1:
            newText.write('${currency}0,0');
            selectionIndex = 7;
            break;
          case 2:
            if (newValue.text[0] == '0') {
              newText.write('${currency}0,0${newValue.text.substring(1, 2)}${newValue.text.substring(2, usedSubstringIndex = 2)}');
              selectionIndex = 7;
            } else {
              newText.write('${currency}0,${newValue.text.substring(0, 2)}${newValue.text.substring(2, usedSubstringIndex = 2)}');
              selectionIndex = 7;
            }
            break;
          case 3:
            newText.write('$currency${newValue.text.substring(0, 1)},${newValue.text.substring(1, usedSubstringIndex = 2)}');
            selectionIndex = 7;
            break;
          case 4:
            if (newValue.text[0] == '0') {
              newText.write('$currency${newValue.text.substring(1, 2)},${newValue.text.substring(2, usedSubstringIndex = 4)}');
              selectionIndex = 7;
            } else {
              newText.write('$currency${newValue.text.substring(0, 2)},${newValue.text.substring(2, usedSubstringIndex = 4)}');
              selectionIndex = 8;
            }
            break;
          case 5:
            newText.write('$currency${newValue.text.substring(0, 3)},${newValue.text.substring(3, usedSubstringIndex = 5)}');
            selectionIndex = 9;
            break;
          case 6:
            newText.write('$currency${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)},${newValue.text.substring(4, usedSubstringIndex = 5)}');
            selectionIndex = 11;
            break;
          case 7:
            newText.write('$currency${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)},${newValue.text.substring(5, usedSubstringIndex = 6)}');
            selectionIndex = 12;
            break;
          case 8:
            newText.write('$currency${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)},${newValue.text.substring(6, usedSubstringIndex = 7)}');
            selectionIndex = 13;
            break;
          case 9:
            newText.write('$currency${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)}.${newValue.text.substring(4, 7)},${newValue.text.substring(7, usedSubstringIndex = 8)}');
            selectionIndex = 15;
            break;
          case 10:
            newText.write('$currency${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)}.${newValue.text.substring(5, 8)},${newValue.text.substring(8, usedSubstringIndex = 9)}');
            selectionIndex = 16;
            break;
          case 11:
            newText.write('$currency${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)}.${newValue.text.substring(6, 9)},${newValue.text.substring(9, usedSubstringIndex = 10)}');
            selectionIndex = 17;
            break;
          case 12:
            newText.write('$currency${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)}.${newValue.text.substring(4, 7)}.${newValue.text.substring(7, 10)},${newValue.text.substring(10, usedSubstringIndex = 11)}');
            selectionIndex = 19;
            break;
          case 13:
            newText.write('$currency${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)}.${newValue.text.substring(5, 8)}.${newValue.text.substring(8, 11)},${newValue.text.substring(11, usedSubstringIndex = 11)}');
            selectionIndex = 20;
            break;
          case 14:
            newText.write('$currency${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)}.${newValue.text.substring(6, 9)}.${newValue.text.substring(9, 12)},${newValue.text.substring(12, usedSubstringIndex = 13)}');
            selectionIndex = 21;
            break;
        }
      } else {
        switch (novoTextLength) {
          case 0:
            newText.write(currency);
            selectionIndex = 3;
            break;
          case 1:
            newText.write(currency);
            selectionIndex = 4;
            break;
          case 2:
            newText.write(currency);
            selectionIndex = 5;
            break;
          case 3:
            newText.write(currency);
            selectionIndex = 6;
            break;
          case 4:
            newText.write('$currency${newValue.text.substring(0, 1)}.${newValue.text.substring(1, usedSubstringIndex = 3)}');
            selectionIndex = 8;
            break;
          case 5:
            newText.write('$currency${newValue.text.substring(0, 2)}.${newValue.text.substring(2, usedSubstringIndex = 3)}');
            selectionIndex = 9;
            break;
          case 6:
            newText.write('$currency${newValue.text.substring(0, 3)}.${newValue.text.substring(3, usedSubstringIndex = 3)}');
            selectionIndex = 10;
            break;
          case 7:
            newText.write('$currency${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)}.${newValue.text.substring(4, usedSubstringIndex = 5)}');

            selectionIndex = 12;
            break;
          case 8:
            newText.write('$currency${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)}.${newValue.text.substring(5, usedSubstringIndex = 6)}');
            selectionIndex = 13;
            break;
          case 9:
            newText.write('$currency${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)}.${newValue.text.substring(6, usedSubstringIndex = 7)}');
            selectionIndex = 14;
            break;
          case 10:
            newText.write('$currency${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)}.${newValue.text.substring(4, 7)}.${newValue.text.substring(7, usedSubstringIndex = 10)}');
            selectionIndex = 16;
            break;
          case 11:
            newText.write('$currency${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)}.${newValue.text.substring(5, 8)}.${newValue.text.substring(8, usedSubstringIndex = 11)}');
            selectionIndex = 17;
            break;
          case 12:
            newText.write('$currency${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)}.${newValue.text.substring(6, 9)}.${newValue.text.substring(9, usedSubstringIndex = 12)}');
            selectionIndex = 18;
            break;
        }
      }
    } else {
      if (centavos) {
        maxLength = 14;
        switch (novoTextLength) {
          case 1:
            newText.write('0,0');
            selectionIndex = 4;
            break;
          case 2:
            if (newValue.text[0] == '0') {
              newText.write('0,0${newValue.text.substring(1, 2)}${newValue.text.substring(2, usedSubstringIndex = 2)}');
              selectionIndex = 4;
            } else {
              newText.write('0,${newValue.text.substring(0, 2)}${newValue.text.substring(2, usedSubstringIndex = 2)}');
              selectionIndex = 4;
            }
            break;
          case 3:
            newText.write('${newValue.text.substring(0, 1)},${newValue.text.substring(1, usedSubstringIndex = 2)}');
            selectionIndex = 4;
            break;
          case 4:
            if (newValue.text[0] == '0') {
              newText.write('${newValue.text.substring(1, 2)},${newValue.text.substring(2, usedSubstringIndex = 4)}');
              selectionIndex = 4;
            } else {
              newText.write('${newValue.text.substring(0, 2)},${newValue.text.substring(2, usedSubstringIndex = 4)}');
              selectionIndex = 5;
            }
            break;
          case 5:
            newText.write('${newValue.text.substring(0, 3)},${newValue.text.substring(3, usedSubstringIndex = 5)}');
            selectionIndex = 6;
            break;
          case 6:
            newText.write('${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)},${newValue.text.substring(4, usedSubstringIndex = 5)}');
            selectionIndex = 8;
            break;
          case 7:
            newText.write('${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)},${newValue.text.substring(5, usedSubstringIndex = 6)}');
            selectionIndex = 9;
            break;
          case 8:
            newText.write('${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)},${newValue.text.substring(6, usedSubstringIndex = 7)}');
            selectionIndex = 10;
            break;
          case 9:
            newText.write('${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)}.${newValue.text.substring(4, 7)},${newValue.text.substring(7, usedSubstringIndex = 8)}');
            selectionIndex = 12;
            break;
          case 10:
            newText.write('${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)}.${newValue.text.substring(5, 8)},${newValue.text.substring(8, usedSubstringIndex = 9)}');
            selectionIndex = 13;
            break;
          case 11:
            newText.write('${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)}.${newValue.text.substring(6, 9)},${newValue.text.substring(9, usedSubstringIndex = 10)}');
            selectionIndex = 14;
            break;
          case 12:
            newText.write('${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)}.${newValue.text.substring(4, 7)}.${newValue.text.substring(7, 10)},${newValue.text.substring(10, usedSubstringIndex = 11)}');
            selectionIndex = 16;
            break;
          case 13:
            newText.write('${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)}.${newValue.text.substring(5, 8)}.${newValue.text.substring(8, 11)},${newValue.text.substring(11, usedSubstringIndex = 11)}');
            selectionIndex = 17;
            break;
          case 14:
            newText.write('${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)}.${newValue.text.substring(6, 9)}.${newValue.text.substring(9, 12)},${newValue.text.substring(12, usedSubstringIndex = 13)}');
            selectionIndex = 18;
            break;
        }
      } else {
        switch (novoTextLength) {
          case 4:
            newText.write('${newValue.text.substring(0, 1)}.${newValue.text.substring(1, usedSubstringIndex = 3)}');
            selectionIndex = 5;

            break;
          case 5:
            newText.write('${newValue.text.substring(0, 2)}.${newValue.text.substring(2, usedSubstringIndex = 3)}');
            selectionIndex = 6;
            break;
          case 6:
            newText.write('${newValue.text.substring(0, 3)}.${newValue.text.substring(3, usedSubstringIndex = 3)}');
            selectionIndex = 7;
            break;
          case 7:
            newText.write('${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)}.${newValue.text.substring(4, usedSubstringIndex = 5)}');

            selectionIndex = 9;
            break;
          case 8:
            newText.write('${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)}.${newValue.text.substring(5, usedSubstringIndex = 6)}');
            selectionIndex = 10;
            break;
          case 9:
            newText.write('${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)}.${newValue.text.substring(6, usedSubstringIndex = 7)}');
            selectionIndex = 11;
            break;
          case 10:
            newText.write('${newValue.text.substring(0, 1)}.${newValue.text.substring(1, 4)}.${newValue.text.substring(4, 7)}.${newValue.text.substring(7, usedSubstringIndex = 10)}');
            selectionIndex = 13;
            break;
          case 11:
            newText.write('${newValue.text.substring(0, 2)}.${newValue.text.substring(2, 5)}.${newValue.text.substring(5, 8)}.${newValue.text.substring(8, usedSubstringIndex = 11)}');
            selectionIndex = 14;
            break;
          case 12:
            newText.write('${newValue.text.substring(0, 3)}.${newValue.text.substring(3, 6)}.${newValue.text.substring(6, 9)}.${newValue.text.substring(9, usedSubstringIndex = 12)}');
            selectionIndex = 15;
            break;
        }
      }
    }

    if (novoTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}




class TextFormatterCorretor extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    int pos = newValue.selection.start;
    String value = newValue.text;
    // if (Platform.isWindows) {
    //   value = value
    //       .replaceAll('´´a', 'á')
    //       .replaceAll('``a', 'à')
    //       .replaceAll('^^a', 'â')
    //       .replaceAll('~~a', 'ã')
    //       .replaceAll('´´A', 'Á')
    //       .replaceAll('``A', 'À')
    //       .replaceAll('^^A', 'Â')
    //       .replaceAll('~~A', 'Ã')
    //
    //       .replaceAll('´´e', 'é')
    //       .replaceAll('``e', 'è')
    //       .replaceAll('^^e', 'ê')
    //       .replaceAll('´´E', 'É')
    //       .replaceAll('``E', 'È')
    //       .replaceAll('^^E', 'Ê')
    //
    //       .replaceAll('´´i', 'í')
    //       .replaceAll('``i', 'ì')
    //       .replaceAll('^^i', 'î')
    //       .replaceAll('´´I', 'Í')
    //       .replaceAll('``I', 'Ì')
    //       .replaceAll('^^I', 'î')
    //
    //       .replaceAll('´´o', 'ó')
    //       .replaceAll('``o', 'ò')
    //       .replaceAll('^^o', 'ô')
    //       .replaceAll('~~o', 'õ')
    //       .replaceAll('´´O', 'Ó')
    //       .replaceAll('``O', 'Ò')
    //       .replaceAll('^^O', 'Ô')
    //       .replaceAll('~~O', 'Õ')
    //
    //       .replaceAll('´´u', 'ú')
    //       .replaceAll('``u', 'ù')
    //       .replaceAll('^^u', 'û')
    //       .replaceAll('´´U', 'Ú')
    //       .replaceAll('``U', 'Ù')
    //       .replaceAll('^^U', 'Û')
    //
    //       .replaceAll('\'\'c', 'ç')
    //       .replaceAll('\'\'C', 'Ç');
    // }

    /// Makes the cursor stay in the correct place
    pos -= (newValue.text.length - value.length);
    if (pos > value.length) {
      pos = value.length;
    }
    return TextEditingValue(
      text: value,
      selection: TextSelection.fromPosition(TextPosition(offset: pos)),
      composing: newValue.composing,
    );
  }
}