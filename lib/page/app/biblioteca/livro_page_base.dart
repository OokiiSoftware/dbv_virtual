import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

abstract class LivroPageBase extends StatefulWidget {
  final Livro livro;
  final bool readOnly;
  const LivroPageBase({
    super.key,
    required this.livro,
    this.readOnly = true,
  });

  @override
  State<StatefulWidget> createState();
}
abstract class LivroPageBaseState<T extends LivroPageBase> extends State<T> {

  String get pathToSave;

  Livro get livro => widget.livro;
  bool get readOnly => widget.readOnly;

  final _controller = PdfViewerController();
  final _textController = TextEditingController();

  String _livrosPath = '';

  bool _arquivoBaixado = false;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(livro.nome),
        actions: [
          if (!readOnly)
            IconButton(
              tooltip: 'Editar dados',
              onPressed: onEditTap,
              icon: const Icon(Icons.edit),
            ),

          if (_arquivoBaixado)
            IconButton(
              tooltip: 'Excluir',
              onPressed: _onDeleteTap,
              icon: const Icon(Icons.delete_forever),
            )
          else
            IconButton(
              tooltip: 'Baixar',
              onPressed: _controller.pageCount != 0 ? _onBaixarTap : null,
              icon: const Icon(Icons.download),
            ),

          const SizedBox(width: 10),
        ],
      ),
      body: PdfViewPage(
        pdfUrl: _arquivoBaixado ? _file.path : livro.urlFile,
        showAppBar: false,
        controller: _controller,
        controllers: _controllers(),
      ),
    );
  }

  Widget _controllers() {
    const space = SizedBox(width: 10);
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          IconButton(
            onPressed: _controller.previousPage,
            icon: const Icon(Icons.arrow_back_ios),
          ),  // previous page
          space,

          Container(
            width: 50,
            height: 30,
            alignment: Alignment.center,
            child: TextField(
              controller: _textController,
              keyboardType: TextInputType.number,
              inputFormatters: TextType.numero.inputFormatters,
              decoration: const InputDecoration(
                filled: true,
                isDense: true,
                fillColor: Colors.black12,
                contentPadding: EdgeInsets.all(5),
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                if (value.isEmpty) return;

                final page = int.parse(value);
                _controller.jumpToPage(page);
              },
            ),
          ),
          Text(' / ${_controller.pageCount}'),

          space,
          IconButton(
            onPressed: _controller.nextPage,
            icon: const Icon(Icons.arrow_forward_ios),
          ),  // next page

          const Spacer(),

          IconButton(
            onPressed: () {
              _controller.zoomLevel -= .5;
              _setState();
            },
            icon: const Icon(Icons.zoom_out),
          ),  // zoon out
          IconButton(
            onPressed: () {
              _controller.zoomLevel += .5;
              _setState();
            },
            icon: const Icon(Icons.zoom_in),
          ),  // zoon in

        ],
      ),
    );
  }

  void _init() async {
    _controller.addListener(_loadListener);
    _controller.addListener(_scrollListener);

    _livrosPath = await StorageProvider.i.createFolder(pathToSave);
    _arquivoBaixado = await _file.exists();

    _setState();
  }

  void onEditTap();

  void _onBaixarTap() async {
    try {
      final bytes = await _controller.saveDocument();

      await _file.writeAsBytes(bytes);
      _arquivoBaixado = true;
      Log.snack('PDF salvo');
      _setState();
    } catch(e) {
      Log.snack('Não foi possível salvar o arquivo',
          isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
    }
  }

  void _onDeleteTap() async {
    final res = await DialogBox(
      context: context,
      title: 'Exluir livro',
      content: [
        Text(livro.nome),
        Text(livro.descricao),
        const Text('\nDeseja excluir esse livro do dispositivo?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    if (await _file.exists()) await _file.delete();

    Log.snack('Arquivo excluido');
    _arquivoBaixado = false;
    _setState();
  }


  void _loadListener() {
    if (_controller.pageCount != 0) {
      _setState();
      _controller.removeListener(_loadListener);
    }
  }

  void _scrollListener() {
    _textController.text = '${_controller.pageNumber}';
  }


  File get _file => File('$_livrosPath${livro.id}.pdf');

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}
