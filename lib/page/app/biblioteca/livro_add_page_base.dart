import 'dart:io';
import 'package:dbv_virtual/page/app/geral/crop_image_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

abstract class LivroAddPageBase extends StatefulWidget {
  final Livro? livro;
  final bool readOnly;
  const LivroAddPageBase({
    super.key,
    this.livro,
    this.readOnly = true,
  });

  @override
  State<StatefulWidget> createState();
}
abstract class LivroAddPageBaseState<T extends LivroAddPageBase, P extends BibliotecaProviderBase> extends State<T> {
  final _log = const Log('LivroAddPage');

  String get pageTitle;
  /// key pra salvar no banco de dados
  String get keyPath;

  late Livro livro = widget.livro ?? Livro();
  bool get readOnly => widget.readOnly;

  late P provider;

  bool get isNovo => livro.id.isEmpty;
  bool get showLivroDoAno => false;

  final _formKey = GlobalKey<FormState>();

  String? _capaPath;
  String? _pdfPath;

  final List<String> _capasTemp = [];

  bool _inProgress = false;

  @override
  void dispose() {
    super.dispose();
    StorageProvider.i.deleteFolder('livroTemp');

    void deleteImages() async {
      for (var e in _capasTemp) {
        final file = File(e);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    deleteImages();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    provider = context.read<P>();
    return Scaffold(
      appBar: AppBar(
        title: Text('${isNovo ? 'Novo' : 'Editar'} $pageTitle'),
        actions: [
          if (!isNovo)
            IconButton(
              tooltip: 'Remover',
              onPressed: _onRemoveTap,
              icon: const Icon(Icons.delete_forever),
            ),

          const SizedBox(width: 10),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            Card(
              child: _fotoLatout(),
            ),

            TextFormField(
              initialValue: livro.nome,
              keyboardType: TextInputType.name,
              inputFormatters: TextType.name.inputFormatters,
              decoration: const InputDecoration(
                labelText: 'Titulo',
              ),
              validator: Validators.obrigatorio,
              onSaved: (value) => livro.nome = value!,
            ),  // nome

            TextFormField(
              initialValue: livro.autor,
              keyboardType: TextInputType.name,
              inputFormatters: TextType.name.inputFormatters,
              decoration: const InputDecoration(
                labelText: 'Autor',
              ),
              onSaved: (value) => livro.autor = value!,
            ),  // autor

            TextFormField(
              initialValue: livro.descricao,
              maxLines: 3,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.inputFormatters,
              decoration: const InputDecoration(
                labelText: 'Descrição',
              ),
              onSaved: (value) => livro.descricao = value!,
            ),  // descricao

            if (showLivroDoAno)
              SwitchListTile(
                title: const Text('Livro do ano'),
                value: livro.livroDoAno,
                onChanged: _onLivroDoAnoChanged,
              ),

            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(_capaPath == null ? '' : 'Capa Alterada'),
                  ),
                ),

                if (isNovo || kDebugMode)...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: Text(_pdfPath == null ? '' : _pdfName,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onChangeCapaTap,
                    child: Text('${isNovo ? 'Adicionar' : 'Alterar'} Capa'),
                  ),
                ),

                if (isNovo || kDebugMode)...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onChangePDFTap,
                      child: const Text('Adicionar PDF'),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              child: ElevatedButton(
                onPressed: _onSaveTap,
                child: const Text('Salvar'),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Widget _fotoLatout() {
    if (_capaPath != null) {
      return Image.file(File(_capaPath!));
    }

    return FotoLayout(
      path: livro.urlCapa,
      borderRadius: 10,
      aspectRatio: 1/1.5,
      headers: FirebaseProvider.i.headers,
    );
  }

  void _init() async {

  }

  void _onSaveTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    if (_pdfPath == null && livro.urlFile.isEmpty) {
      Log.snack('Adicione o PDF', isError: true);
      return;
    }

    _setInProgress(true);

    if (isNovo) {
      livro.id = randomString();
    }

    if (_capaPath != null) {
      try {
        final capa = await _uploadCapa();
        if (capa == null) throw 'Erro ao enviar a capa do livro';

        livro.urlCapa = capa;
      } catch(e) {
        _onError(e);
        _log.e('_onSaveTap', '_uploadCapa', e);
        return;
      }
    }

    if (_pdfPath != null) {
      try {
        final link = await _uploadPdf();
        if (link == null) throw 'Erro ao enviar o arquivo PDF';

        livro.urlFile = link;
      } catch(e) {
        _onError(e);
        _log.e('_onSaveTap', '_uploadPdf', e);
        return;
      }
    }

    try {
      await provider.add(livro);

      if (mounted) {
        Navigator.pop(context);
      }
      Log.snack('Dados salvos');
    } catch(e) {
      _onError(e);
      _log.e('_onSaveTap', e);
    }
  }

  void _onRemoveTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    if (!await Popup(context).delete()) return;

    _setInProgress(true);
    try {
      await provider.remove(livro);

      if (mounted) {
        Navigator.pop(context);
      }
      Log.snack('Dados removidos');
    } catch(e) {
      _setInProgress(false);
      Log.snack('Erro ao salvar os dados', isError: true, actionClick: () {
        Popup(context).errorDetalhes(e);
      });
    }
  }

  void _onChangeCapaTap() async {
    final picker = ImagePicker();
    final res = await picker.pickImage(source: ImageSource.gallery);
    if (res == null || !mounted) return;

    final file = StorageProvider.i.file([StoragePath.imagens, '${randomString()}.jpg']);

    final path = await Navigate.push(context, CropImagePage(
      inPath: res.path,
      outPath: file.path,
    ));

    if (path is! String) return;

    _capasTemp.add(path);
    _capaPath = path;
    _setState();
  }

  void _onChangePDFTap() async {
    final res = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecionar PDF',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (res != null) {
      _pdfPath = res.files.single.path!;
      _setState();
    }
  }

  void _onLivroDoAnoChanged(bool value) async {
    livro.livroDoAno = value;
    _setState();
  }


  Future<String?> _uploadCapa() async {
    final bytes = await Util.compressImage(_capaPath!);

    final path = [
      PrefKey.app,
      PrefKey.biblioteca,
      keyPath,
      'capas',
      '${livro.id}.png'
    ];

    return await FirebaseProvider.i.uploadFile(path, bytes, ignoreSize: true);
  }

  Future<String?> _uploadPdf() async {
    final path = [
      PrefKey.app,
      PrefKey.biblioteca,
      keyPath,
      'files',
      '${livro.id}.pdf'
    ];

    return await FirebaseProvider.i.uploadFile(
      path,
      await File(_pdfPath!).readAsBytes(),
      ignoreSize: true,
    );
  }


  String get _pdfName {
    return _pdfPath!.split(StorageProvider.i.pathDiv).last;
  }

  void _onError(dynamic e) {
    Log.snack('Erro ao salvar os dados', isError: true, actionClick: !mounted ? null : () {
      Popup(context).errorDetalhes(e);
    });

    _setInProgress(false);
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