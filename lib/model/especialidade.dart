import 'dart:io';
import 'package:dbv_virtual/provider/provider.dart';
import 'package:flutter/material.dart';
import '../../util/util.dart';
import 'model.dart';

class EspecialidadeArea extends ItemModel {

  @override
  String id = '';
  String nome = '';
  Color? color;
  Color? borderColor;
  bool lightText = false;

  EspecialidadeArea({
    this.id = '',
    this.nome = '',
    this.color,
    this.borderColor,
    this.lightText = false,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
  };
}

class Especialidade extends ItemModel {

  @override
  String get id => '_$cod';
  int cod = 0;
  String idName = '';
  String nome = '';
  String area = '';
  String departamento = '';

  String text = '';

  bool selected = false;

  String get image => 'https://sg.sdasystems.org/img_especialidades/$idName.jpg';

  File get imageFile => StorageProvider.i.file([StoragePath.especialidades, '$id.jpg']);

  Especialidade({
    this.idName = '',
    this.cod = 0,
    this.nome = '',
    this.area = '',
    this.departamento = '',
  });

  Especialidade.fromJson(Map? map) :
        idName = map?['idName'] ?? '',
        cod = map?['cod'] ?? 0,
        nome = map?['nome'] ?? '',
        area = map?['area'] ?? '',
        departamento = map?['departamento'] ?? '';

  static Map<String, Especialidade> fromJsonList(Map? map) {
    Map<String, Especialidade> items = {};
    map?.forEach((key, value) {
      items[key] = Especialidade.fromJson(value);
    });
    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'cod': cod,
    'idName': idName,
    'nome': nome,
    'area': area,
    'departamento': departamento,
  };


  Especialidade copy() => Especialidade.fromJson(toJson());

  @override
  String toString() => toJson().toString();

}

class MembroEspecialidade extends ItemModel {

  @override
  String id = '';

  int cod = 0;
  String nome = '';
  String instrutor = '';
  String data = '';
  bool get canDelete => cod > 0;

  MembroEspecialidade({
    this.cod = 0,
    this.id = '',
    this.nome = '',
    this.instrutor = '',
    this.data = '',
  });


  @override
  Map<String, dynamic> toJson() => {
    'cod': cod,
    'nome': nome,
    'instrutor': instrutor,
    'data': data,
    'canDelete': canDelete,
  };

  @override
  String toString() => toJson().toString();

}

class EspecialidadeSolicitacao extends ItemModel {

  @override
  String get id => dados.membroId;

  EspSolDados dados = EspSolDados();

  final Map<String, Especialidade> especialidades = {};

  bool selected = false;

  EspecialidadeSolicitacao();

  EspecialidadeSolicitacao.fromJson(Map? map) {
    dados = EspSolDados.fromJson(map?['dados']);

    final esps = map?['especialidades'] as Map?;
    especialidades.addAll(Especialidade.fromJsonList(esps));
  }

  static Map<String, EspecialidadeSolicitacao> fromJsonList(Map? map) {
    Map<String, EspecialidadeSolicitacao> items = {};
    map?.forEach((key, value) {
      items[key] = EspecialidadeSolicitacao.fromJson(value);
    });
    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'dados': dados.toJson(),
    'especialidades': Util.mapObjectToJson(especialidades),
  };

  EspecialidadeSolicitacao copy() => EspecialidadeSolicitacao.fromJson(toJson());
}

class EspSolDados {

  String membroId = '';
  String instrutor = '';
  String data = '';

  EspSolDados();

  EspSolDados.fromJson(Map? map) :
        membroId = map?['membroId'] ?? '',
        instrutor = map?['instrutor'] ?? '',
        data = map?['data'] ?? '';

  Map<String, dynamic> toJson() => {
    'membroId': membroId,
    'instrutor': instrutor,
    'data': data,
  };

}


class ClasseItem extends ItemModel {

  @override
  String get id => '_$cod';
  int cod = 0;
  String nome = '';

  bool selected = false;

  ClasseItem({
    this.cod = 0,
    this.nome = '',
  });

  ClasseItem.fromJson(Map? map) :
        cod = map?['cod'] ?? 0,
        nome = map?['nome'] ?? '';

  static Map<String, ClasseItem> fromJsonList(Map? map) {
    Map<String, ClasseItem> items = {};
    map?.forEach((key, value) {
      items[key] = ClasseItem.fromJson(value);
    });
    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'cod': cod,
    'nome': nome,
  };


  ClasseItem copy() => ClasseItem.fromJson(toJson());

  @override
  String toString() => toJson().toString();

}