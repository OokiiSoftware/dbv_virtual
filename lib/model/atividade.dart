import 'dart:typed_data';

class Atividade {
  String name = '';
  final List<Questao> questoes = [];

  Atividade({
    this.name = '',
    List<Questao>? questoes,
  }) {
    if (questoes != null) this.questoes.addAll(questoes);
  }

  Atividade.fromJson(Map? map) :
      name = map?['name'] ?? '' {
    List qt = map?['questoes'] ?? [];
    for (var value in qt) {
      questoes.add(Questao.fromJson(value));
    }
  }

  double get percent {
    int questoesCount = 0;
    int respondidosCount = 0;

    for (var questao in questoes) {
      if (questao.subQuestoes.isEmpty) {
        questoesCount++;
        if (questao.respondido) {
          respondidosCount++;
        }
      } else {
        for (var questao in questao.subQuestoes) {
          questoesCount++;
          if (questao.respondido) {
            respondidosCount++;
          }
        }
      }
    }

    if (questoesCount == 0) questoesCount++;

    return (respondidosCount / questoesCount) * 100;
  }

  int get respondidosCount {
    int respondidos = 0;

    for (var questao in questoes) {
      if (questao.subQuestoes.isEmpty) {
        if (questao.respondido) {
          respondidos++;
        }
      } else {
        for (var questao in questao.subQuestoes) {
          if (questao.respondido) {
            respondidos++;
          }
        }
      }
    }

    return respondidos;
  }

  int get questoesCount {
    int questoesCount = 0;

    for (var questao in questoes) {
      if (questao.subQuestoes.isEmpty) {
        questoesCount++;
      } else {
        for (var _ in questao.subQuestoes) {
          questoesCount++;
        }
      }
    }

    return questoesCount;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'questoes': _questoesToJson(),
  };

  List<Map> _questoesToJson() {
    List<Map> items = [];
    for (var e in questoes) {
      items.add(e.toJson());
    }
    return items;
  }
}

class Questao {
  String name = '';
  String data = '';
  String resposta = '';
  String url = '';
  String fileUrl = '';
  String fileName = '';
  bool sendFile = false;
  List<Questao> subQuestoes = [];

  Uint8List? uint8list;

  bool get respondido {
    if (subQuestoes.isEmpty) {
      return data.isNotEmpty;
    }

    return subQuestoes.where((e) => e.respondido).isNotEmpty;
  }

  Questao({
    this.name = '',
    this.resposta = '',
    this.data = '',
    this.url = '',
    this.fileUrl = '',
    this.fileName = '',
    this.sendFile = false,
    List<Questao>? subQuestoes,
  }) {
    if (subQuestoes != null) this.subQuestoes.addAll(subQuestoes);
  }

  Questao.fromJson(Map? map) :
        name = map?['name'] ?? '',
        data = map?['data'] ?? '',
        resposta = map?['resposta'] ?? '',
        url = map?['url'] ?? '',
        fileUrl = map?['fileUrl'] ?? '',
        fileName = map?['fileName'] ?? '',
        sendFile = map?['sendFile'] ?? false {
    List sq = map?['subQuestoes'] ?? [];
    for (var value in sq) {
      subQuestoes.add(Questao.fromJson(value));
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'data': data,
    'resposta': resposta,
    'url': url,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'sendFile': sendFile,
    'subQuestoes': subQuestoes.map((e) => e.toJson()).toList(),
  };

  /// Format -> 00/0000/0000
  String get code {
    var code = url;
    code = code.replaceAll('https://clubes.adventistas.org/br/reply-card-member/', '');
    code = code.replaceAll('https://clubes.adventistas.org/br/file-card-member/', '');
    return code;
  }


  Questao copy() => Questao.fromJson(toJson());

  void reset() {
    resposta = '';
    data = '';
    fileName = '';
    fileUrl = '';
  }

  bool get contensEspecialChar {
    if (subQuestoes.isEmpty) {
      final regex = RegExp('[^a-zA-Z0-9á-úÁ-Ú _.,àù*!@#\$%¨&(){}\'";:|><?+/\\-\t\r\n]');

      final has = regex.hasMatch(resposta);
      if (has) {
        // const Log('Questao').d('EspecialChar', has, resposta);
      }
      return has;
    }

    return subQuestoes.where((e) => e.contensEspecialChar).isNotEmpty;
  }

  @override
  String toString() => toJson().toString();
}