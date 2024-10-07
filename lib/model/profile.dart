import 'model.dart';

class Profile extends ItemModel {

  @override
  String get id => user.id;

  final List<List<String>> especialiades = []; // [nome, data]
  final List<List<String>> historico = []; // [nome, ano]
  final List<List<String>> eventos = []; // [nome, ano]
  final List<List<String>> classesConcluidas = []; // [nome, data, linkCertificado]
  final List<String> dados = [];
  final Map<String, Classe> classes = {};

  Membro user = Membro();

  Profile();

  Profile.fromJson(Map? map) {
    if (map == null) return;

    /// List<List<String>>
    List listsE = map['especialiades'] ?? [];
    for(int i = 0; i < listsE.length; i++) {
      especialiades.add([]);
      List list = listsE[i];
      for(int j = 0; j < list.length; j++) {
        especialiades[i].add(list[j].toString());
      }
    }

    List listsEC = map['classesConcluidas'] ?? [];
    for(int i = 0; i < listsEC.length; i++) {
      classesConcluidas.add([]);
      List list = listsEC[i];
      for(int j = 0; j < list.length; j++) {
        classesConcluidas[i].add(list[j].toString());
      }
    }

    List listsH = map['historico'] ?? [];
    for(int i = 0; i < listsH.length; i++) {
      historico.add([]);
      List list = listsH[i];
      for(int j = 0; j < list.length; j++) {
        historico[i].add(list[j].toString());
      }
    }

    List listsE2 = map['eventos'] ?? [];
    for(int i = 0; i < listsE2.length; i++) {
      eventos.add([]);
      List list = listsE2[i];
      for(int j = 0; j < list.length; j++) {
        eventos[i].add(list[j].toString());
      }
    }

    /// List<String>
    List dados = map['dados'] ?? [];
    for(int i = 0; i < dados.length; i++) {
      this.dados.add(dados[i].toString());
    }

    classes.addAll(Classe.fromJsonList(map['classes']));

    user = Membro.fromJson(map['user']);
  }

  static Map<String, Profile> fromJsonList(Map? map) {
    Map<String, Profile> items = {};
    map?.forEach((key, value) {
      items[key] = Profile.fromJson(value);
    });
    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'classesConcluidas': classesConcluidas,
    'especialiades': especialiades,
    'historico': historico,
    'eventos': eventos,
    'dados': dados,
    'user': user.toJson(),
    'classes': classes.map((key, value) => MapEntry(key, value.toJson())),
  };


  void clear() {
    dados.clear();
    classesConcluidas.clear();
    especialiades.clear();
    historico.clear();
    eventos.clear();
    classes.clear();

    user = Membro();
  }

  @override
  String toString() => toJson().toString();
}