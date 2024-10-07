import 'dart:io';

class Hino {
  String titulo = '';
  String letra = '';
  String url = '';
  bool baixado = false;
  bool baixando = false;
  File? file;

  Hino({
    this.titulo = '',
    this.letra = '',
    this.url = '',
    this.baixado = false,
    this.baixando = false,
    this.file,
  });

  double progress = 0;

  void downloadProgress(int count, int total) {
    progress = count / total;
  }

}