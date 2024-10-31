import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../provider/provider.dart';
import '../../../../model/model.dart';
import '../../../../res/res.dart';

class EspecialidadePage extends StatefulWidget {
  final bool readOnly;
  final Especialidade especialidade;
  const EspecialidadePage({
    super.key,
    this.readOnly = true,
    required this.especialidade,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<EspecialidadePage> {

  EspecialidadesProvider _provider = EspecialidadesProvider.i;

  Especialidade get especialidade => widget.especialidade;
  bool get readOnly => widget.readOnly;

  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _init(false);
  }

  @override
  Widget build(BuildContext context) {
    _provider = context.watch<EspecialidadesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(especialidade.nome),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 80),
            children: [
              Center(
                child: FotoLayout(
                  path: especialidade.image,
                  saveTo: especialidade.imageFile,
                  borderRadius: 50,
                  width: 150,
                  fit: BoxFit.fill,
                ),
              ),  // foto

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    Text(especialidade.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(especialidade.area),
                    Text(especialidade.idName),
                  ],
                ),
              ),  // title

              const SizedBox(height: 10),

              _espText(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Compartilhar',
        onPressed: _onShareTap,
        child: const Icon(Icons.share),
      ),
    );
  }

  Widget _espText() {
    final linhas = especialidade.text.split('\n');
    List<Widget> childs = [];

    String currentLinha = '';
    Map<String, List<String>> requisitos = {};

    for (var linha in linhas) {
      if (linha.isEmpty) continue;
      bool startNumero = int.tryParse(linha[0]) != null;

      if (startNumero) {
        requisitos[linha] = [linha];
        currentLinha = linha;
      } else {
        requisitos[currentLinha]?.add(linha);
      }
    }

    for (var linha in requisitos.values) {
      childs.add(Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Text(linha.join('\n')),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: childs,
    );
  }

  Future<void> _init([bool forceLoad = true]) async {
    await Future.delayed(const Duration(milliseconds: 150));

    await _provider.getById(especialidade.id);
  }

  void _onShareTap() async {
    final linhas = especialidade.text.split('\n');
    List<pw.Widget> childs = [];

    String currentLinha = '';
    Map<String, List<String>> requisitos = {};

    childs.add(pw.Center(
      child: pw.Image(pw.MemoryImage(await especialidade.imageFile.readAsBytes())),
    ));  // image
    childs.add(pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text('${especialidade.nome}\n${especialidade.area}',
        textAlign: pw.TextAlign.center,
      ),
    ));  // title

    for (var linha in linhas) {
      if (linha.isEmpty) continue;
      bool startNumero = int.tryParse(linha[0]) != null;

      if (startNumero) {
        requisitos[linha] = [linha];
        currentLinha = linha;
      } else {
        requisitos[currentLinha]?.add(linha);
      }
    }

    for (var linha in requisitos.values) {
      childs.add(pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        child: pw.Text(linha.join('\n')),
      ));
    }

    var page = pw.MultiPage(
      footer: (context) => pw.Container(
        child: pw.Text('Gerado por: ${VersionControlProvider.i.appName}'),
      ),
      build: (pw.Context context) => childs,
    );
    final pdf = pw.Document();
    pdf.addPage(page);

    var file = StorageProvider.i.file(['${especialidade.nome} - ${especialidade.area}.pdf']);
    await file.writeAsBytes(await pdf.save());

    final res = await Share.shareXFiles([
      XFile(file.path),
    ]);

    if (res.status == ShareResultStatus.success) {
      await file.delete();
    }
  }
}