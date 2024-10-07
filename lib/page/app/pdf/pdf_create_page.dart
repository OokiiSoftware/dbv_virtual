import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_compressor/pdf_compressor.dart';
import '../../../page/page.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class PdfCreatePage extends StatefulWidget {
  final String tempFolderName;
  const PdfCreatePage({super.key, required this.tempFolderName});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<PdfCreatePage> {

  static const String _hintText = '''
Digite aqui...

Para obter ajuda sobre como adicionar títulos ou imagens clique no icone de interrogação (?) no topo da tela.
  ''';

  static final _controller = TextEditingController();
  static final Map<String, String> _imagens = {};

  String get tempFolderName => widget.tempFolderName;

  late File _fileTemp;
  late final String _tempDir;

  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _init();

    if (kDebugMode) {
      _controller.text = '''
## Titulo

**Subtitulo**

[[img1]] [[vazio]] [[img1]] [[vazio]]

[[img1]] [[vazio]]

[[img1]]
''';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de PDF'),
        actions: [
          IconButton(
            tooltip: 'Limpar tudo',
            onPressed: _onClearTap,
            icon: const Icon(Icons.clear),
          ),
          IconButton(
            tooltip: 'Ajuda',
            onPressed: _onHelpTap,
            icon: const Icon(Icons.help),
          ),

          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              maxLines: 45,
              decoration: const InputDecoration(
                hintText: _hintText,
              ),
              onChanged: (value) {
                // element.text = value;
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onSelectImageTap,
                  child: const Text('Add Imagem'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: _onVisualizarTap,
                  child: const Text('Visualizar PDF'),
                ),
              ),
            ],
          ),

          if (_imagens.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                children: [
                  for(var key in _imagens.keys)
                    InkWell(
                      onTap: () => _onImageTap(key),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(blurRadius: 2),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.file(File(_imagens[key]!),
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, e) => const Icon(Icons.image),
                              ),
                            ),
                            Text(key,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Future<void> _init() async {
    var dir = await getApplicationCacheDirectory();
    dir = Directory('${dir.path}$pathDiv$tempFolderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    _tempDir = dir.path;
    _fileTemp = File('${dir.path}${pathDiv}temp.pdf');

    await _fileTemp.create();
  }

  void _showBottonSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSaveTap,
                    child: const Text('Salvar PDF'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: PdfViewPage(
                showAppBar: false,
                pdfUrl: _fileTemp.path,
              ),
            ),
          ],
        );
      },
    );
  }

  void _onSelectImageTap() async {
    final picker = ImagePicker();

    final res = await picker.pickImage(source: ImageSource.gallery);
    if (res == null || !mounted) return;

    final filePath = await Navigate.push(context, CropImagePage(
      inPath: res.path,
      outPath: '$_tempDir$pathDiv${randomString()}.png',
    ));

    if (filePath is! String) return;

    if (mounted) {
      _imagens['img${_imagens.length+1}'] = filePath;
      _setState();
    }
  }

  void _onImageTap(String key) async {
    final res = await DialogBox(
      context: context,
      contentPadding: EdgeInsets.zero,
      content: [
        Image.file(File(_imagens[key]!),
          errorBuilder: (c, o, e) => const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Icon(Icons.image),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.all(10),
          child: Text('Deseja remover essa imagem?'),
        ),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _imagens.remove(key);
    _setState();
  }

  void _onVisualizarTap() async {
    _setInProgress(true);

    try {
      _fileTemp = File(await compute(computePdf, ComputePdfData(
        text: _controller.text,
        pathToSave: _fileTemp.path,
        imagens: _imagens,
      )));

      _showBottonSheet();
    } catch(e) {
      if (!mounted) return;

      DialogBox(
        title: 'Ops',
        context: context,
        content: [
          if (e.toString().contains('A Imagem'))
            Text(e.toString())
          else...[
            const Text('Tem algo de errado no seu texto'),
            const Text('verifique todas as suas imagens entre [[colchetes]]'),
            const Text('e veja se está faltando [ ou ]'),

            const Text('\nLembre-se de não incluir imagens junto ao texto'),
          ],
        ],
      ).ok();

      // const Log('PdfCreatePage').e('_onSaveTap', e);
    }

    _setInProgress(false);
  }


  void _onClearTap() async {
    final res = await DialogBox(
      context: context,
      title: 'Apagar tudo',
      content: const [
        Text('Deseja limpar todos os campos?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _controller.text = '';
    _imagens.clear();
    _setState();
  }

  void _onHelpTap() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    DialogBox(
                      context: context,
                      negativeButtonText: 'Fechar',
                      contentPadding: EdgeInsets.zero,
                      content: [
                        Image.asset(Assets.pdfTutorial),
                      ]
                    ).cancel();
                  },
                  child: const Text('Ver imagem ilustrativa'),
                ),
              ),

              const SizedBox(height: 10),

              const Text('- Inclua 2 cerquilhas (##) no início da linha para adicionar um título'),

              const Text('## Esse é um título', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),

              const Text('\n- Para incluir negrito no texto insira o texto entre 2 asteriscos (**)'),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: '**Esse é um texto em negrito**',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' aqui não está em negrito'),
                  ],
                ),
              ),

              const Text('\n- Para adicionar imagens inclua o nome da imagem entre 2 colchetes [[img1]]'),
              const Text('\n[[img1]] [[img2]]'),
              const Row(
                children: [
                  Expanded(child: Icon(Icons.image, size: 150,)),
                  Expanded(child: Icon(Icons.image, size: 150,)),
                ],
              ),
              const Text('\n- Não inclua imagens entre o texto', style: TextStyle(color: Colors.red)),

              const Text('\n- Para diminuir o tamanho da imagem inclua [[vazio]] na linha junto com a imagem'),
              const Text('\n[[img1]] [[vazio]] [[img2]] [[vazio]]'),
              const Row(
                children: [
                  Expanded(child: Icon(Icons.image, size: 100,)),
                  Expanded(child: Center(child: Text('Espaço\nVazio'))),
                  Expanded(child: Icon(Icons.image, size: 100,)),
                  Expanded(child: Center(child: Text('Espaço\nVazio'))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSaveTap() async {
    _setInProgress(true);

    try {
      final path = _fileTemp.path;
      final path2 = path.replaceAll('temp.pdf', 'temp2.pdf');

      if (Platform.isAndroid) {
        await PdfCompressor.compressPdfFile(
            path, path2, CompressQuality.MEDIUM);
      }

      _fileTemp = File(path2);

      if (!await verificarTamanho()) return;
      if (!mounted) return;

      final res = await DialogBox(
        context: context,
        content: const [
          Text('Deseja concluir a edição do PDF?'),
        ],
      ).simNao();
      if (!res.isPositive || !mounted) return;

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, _fileTemp.path);
      }
    } catch(e) {
      _setInProgress(false);
      Log.snack('Não foi possível salvar o arquivo', isError: true, actionClick: () {
        DialogBox(
          context: context,
          title: 'Detalhes do erro',
          content: [Text(e.toString())],
        ).ok();
      });
      const Log('PdfCreatePage').e('_onSaveTap', e);
    }
  }


  Future<bool> verificarTamanho() async {
    final value = await _fileTemp.length();

    if (value / (1024 * 1024) > 2 && mounted) {
      DialogBox(
        context: context,
        content: const [
          Text('Seu PDF está maior que 2Mb e por isso não será aceito.'),
          Text('Tente usar imagens com menor resolução.'),
        ],
      ).ok();

      return false;
    }

    return true;
  }

  String get pathDiv {
    return Platform.isAndroid ? '/' : '\\';
  }

  void _setInProgress(bool b) {
    _inProgress = b;
    _setState();
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}

Future<String> computePdf(ComputePdfData data) async {
  Future<pw.Widget> widget(String text) async {
    if (text.startsWith('##')) {
      return pw.Header(text: text.replaceAll('##', ''));
    }

    final sp = text.split('**');

    if (sp.length == 1) {
      if (text.contains('[[')) {

        List<pw.Widget> images = [];
        Future<void> addImage(String text) async {
          int fim = text.indexOf(']]');

          String key = text.substring(0, fim);
          if (key == 'vazio') {
            images.add(pw.Container());
            return;
          }

          if (!data.imagens.containsKey(key)) throw 'A Imagem [[$key]] não foi encontrada';

          final file = File(data.imagens[key]!);
          images.add(pw.Image(pw.MemoryImage(await file.readAsBytes())));
        }

        final vs = text.split('[[');
        vs.removeWhere((e) => e.isEmpty);
        for(var v in vs) {
          await addImage(v);
        }

        return pw.Row(
          children: images.map((e) => pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(right: 10),
              child: e,
            ),
          )).toList(),
        );
      }

      return pw.Paragraph(
        text: text,
        textAlign: pw.TextAlign.start,
      );
    }

    return pw.RichText(
      text: pw.TextSpan(
        children: [
          for(int i = 0; i < sp.length; i++)
            pw.TextSpan(
                text: sp[i],
                style: pw.TextStyle(
                  fontWeight: i.isEven ? null : pw.FontWeight.bold,
                )
            ),
        ],
      ),
    );

    // return pw.Paragraph(
    //   text: text,
    //   textAlign: pw.TextAlign.start,
    // );
  }

  final text = data.text;
  List<pw.Widget> items = [];

  final ps = text.split('\n');
  for(var p in ps) {
    items.add(await widget(p));
  }

  var page = pw.MultiPage(build: (pw.Context context) => items);

  final pdf = pw.Document();
  pdf.addPage(page);
  var file = await File(data.pathToSave).writeAsBytes(await pdf.save());

  return file.path;
}

class ComputePdfData {
  final String text;
  final String pathToSave;
  final Map<String, String> imagens;
  final bool compress;

  ComputePdfData({
    required this.text,
    required this.pathToSave,
    required this.imagens,
    this.compress = false,
  });
}
