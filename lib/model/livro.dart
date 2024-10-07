import 'dart:io';
import '../provider/provider.dart';
import 'model.dart';

class Livro extends ItemModel {

  @override
  String id = '';
  String nome = '';
  String descricao = '';
  String autor = '';
  String urlCapa = '';
  String urlFile = '';
  bool livroDoAno = false;

  File get imageFile => StorageProvider.i.file([StoragePath.imagens, '$id.jpg']);

  Livro({
    this.id = '',
    this.nome = '',
    this.autor = '',
    this.descricao = '',
    this.urlCapa = '',
    this.urlFile = '',
    this.livroDoAno = false,
  });

  Livro.fromJson(Map? map) :
        id = map?['id'] ?? '',
        nome = map?['nome'] ?? '',
        autor = map?['autor'] ?? '',
        descricao = map?['descricao'] ?? '',
        urlCapa = map?['urlCapa'] ?? '',
        urlFile = map?['urlFile'] ?? '',
        livroDoAno = map?['livroDoAno'] ?? false;

  static Map<String, Livro> fromJsonList(Map? map) {
    Map<String, Livro> items = {};
    map?.forEach((key, value) {
      items[key] = Livro.fromJson(value);
    });
    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'autor': autor,
    'descricao': descricao,
    'urlCapa': urlCapa,
    'urlFile': urlFile,
    if (livroDoAno)
      'livroDoAno': livroDoAno,
  };

  Livro copy() => Livro.fromJson(toJson());
}