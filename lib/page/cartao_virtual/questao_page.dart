import 'dart:convert';
import 'dart:io';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../provider/provider.dart';
import '../../model/model.dart';
import '../../util/util.dart';
import '../../res/res.dart';
import '../page.dart';

class QuestaoPage extends StatefulWidget {
  final Membro membro;
  final Questao questao;
  const QuestaoPage({
    super.key,
    required this.questao,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<QuestaoPage> {

  Questao get questao => widget.questao;
  Membro get membro => widget.membro;

  late final _filePathController = TextEditingController();
  late final MaskedTextController _dateController = MaskedTextController(
    mask: Masks.date,
    text: questao.data,
  );

  final _formKey = GlobalKey<FormState>();

  bool _inProgress = false;
  String? _tempPdfDir;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(10);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder questão'),
        actions: [
          if (questao.respondido)
            IconButton(
              tooltip: 'Remover resposta',
              onPressed: _onDeleteTap,
              icon: const Icon(Icons.delete_forever),
            ),

          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: padding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(questao.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),  // questao

              const SizedBox(height: 5),

              Card(
                child: TextFormField(
                  initialValue: questao.resposta,
                  maxLines: questao.sendFile ? 5 : 15,
                  decoration: const InputDecoration(
                    labelText: 'Relatório',
                    contentPadding: padding,
                    border: InputBorder.none,
                  ),
                  onSaved: (value) => questao.resposta = value!,
                  validator: questao.sendFile ? null : Validators.obrigatorio,
                ),
              ),  // resposta

              const SizedBox(height: 5),

              if (questao.sendFile)...[
                Row(
                  children: [
                    if (questao.fileUrl.isNotEmpty)...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onOpenFileTap,
                          child: const Text('Ver PDF enviado'),
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onCriarPdfTap,
                        child: const Text('Criar PDF'),
                      ),
                    ),
                  ],
                ),


                TextFormField(
                  controller: _filePathController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Arquivo',
                    suffixIcon: IconButton(
                      tooltip: 'Selecionar arquivo',
                      onPressed: _onSelectFileTap,
                      icon: const Icon(Icons.folder),
                    ),
                    contentPadding: padding,
                  ),
                  validator: (value) {
                    if (questao.fileName.isNotEmpty) return null;

                    return Validators.obrigatorio(value);
                  },
                ),
              ],

              TextFormField(
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Data',
                  suffixIcon: IconButton(
                    tooltip: 'Data',
                    onPressed: _onDateTap,
                    icon: const Icon(Icons.calendar_month),
                  ),
                  contentPadding: padding,
                ),
                onSaved: (value) => questao.data = value!,
                validator: Validators.obrigatorio,
              ),  // data

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSaveTap,
                  child: const Text('Salvar'),
                ),
              ),  // salvar
            ],
          ),
        ),
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Map<String, String> _getBody(bool excluir) {
    var codes = questao.code.split('/');

    String saveValue = 'Atualizar resposta';
    String deleteValue = 'Excluir resposta';
    if (questao.sendFile) {
      saveValue = 'Enviar resposta/arquivo';
      deleteValue = 'Excluir resposta/arquivo';
    }

    try {
      if (questao.contensEspecialChar) {
        questao.resposta = utf8.decode(questao.resposta.runes.toList());
      }
    } catch(e) {
      //
    }

    final map = {
      'dt_cadastro' : questao.data,
      'texto' : questao.resposta,
      'classe': codes[0],
      'pergunta_classe': codes[1],
      'opcao_classe': codes[2],
      'MM_insert': 'form1',
    };

    if (_filePathController.text.isEmpty) {
      if (questao.fileName.isNotEmpty) {
        map['arquivo2'] = questao.fileName;
      }
    }
    if (excluir) {
      map['Submit2'] = deleteValue;
    } else {
      map['Submit'] = saveValue;
    }

    return map;
  }

  void _onSaveTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    try {
      final form = _formKey.currentState!;
      if (!form.validate()) return;
      form.save();

      final body = _getBody(false);

      _setInProgress(true);

      bool resetFileName = false;

      void onDone() {
        Log.snack('Dados salvos');
        CvProvider.i.notify();
        if (mounted) {
          Navigator.pop(context);
        }
        _deleteTempDir();
      }
      void onErro(dynamic e) {
        if (resetFileName) {
          questao.fileName = '';
          // questao.fileUrl = '';
        }

        Log.snack('Ocorreu um erro ao salvar', isError: true, actionClick: () {
          DialogBox(
            context: context,
            content: [
              Text(e.toString()),
            ],
          ).ok();
        });
      }

      http.Response res;

      if (questao.sendFile) {
        String? fileName;
        String? filePath;

        if (_filePathController.text.isNotEmpty) {
          resetFileName = true;
          filePath = _filePathController.text;
          fileName = '${randomInt(9999999)}-${randomInt(9999)}-${randomInt(9999)}.pdf';
          questao.fileName = fileName;

          questao.uint8list = await File(filePath).readAsBytes();
        }

        res = await CvProvider.i.sendFile(membro.codUsuario, questao.url,
          fileBytes: questao.uint8list,
          fileName: fileName,
          body: body,
        );
      } else {
        res = await CvProvider.i.sendQuestao(membro.codUsuario, questao.url, body);
      }

      if (res.body.contains(CvProvider.requestResultBody)) {
        onDone();
      } else {
        onErro(res.body);
      }
    } catch(e) {
      Log.snack('Ocorreu um erro', isError: true, actionClick: () {
        DialogBox(
          context: context,
          title: 'Detalhes do erro',
          content: [Text(e.toString())],
        ).ok();
      });
    }
    _setInProgress(false);
  }

  void _onDeleteTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    final re = await DialogBox(
      context: context,
      title: 'Excluir resposta',
      content: [
        const Text('Essa ação não poderá ser desfeita, deseja continuar?'),
      ],
    ).simNao();
    if (!re.isPositive) return;

    final body = _getBody(true);

    _setInProgress(true);

    final res = await CvProvider.i.sendQuestao(membro.codUsuario, questao.url, body);

    if (res.body.contains('Requisito excluído com sucesso')) {
      questao.reset();
      Log.snack('Resposta excluída');
      CvProvider.i.notify();
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    Log.snack('Ocorreu um erro ao excluir', isError: true);
    _setInProgress(false);
  }

  void _onDateTap() async {
    final hoje = DateTime.now();

    final format = DateFormat('dd/MM/yyyy');
    var initial = format.tryParse(_dateController.text) ?? hoje;
    if (initial.year < 2000 || initial.compareTo(hoje) > 0) {
      initial = hoje;
    }

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: hoje,
      initialDate: initial,
    );

    if (date == null) return;

    _dateController.text = format.format(date);
  }

  void _onSelectFileTap() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecionar PDF',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      _filePathController.text = result.files.single.path!;
    }
  }

  void _onOpenFileTap() {
    Navigate.push(context, PdfViewPage(
      title: 'Arquivo',
      pdfUrl: questao.fileUrl,
    ));
  }

  void _onCriarPdfTap() async {
    final res = await Navigate.push(context, PdfCreatePage(
      tempFolderName: questao.code.replaceAll('/', ''),
    ));
    if (res is! String) return;

    _filePathController.text = res;
    _tempPdfDir = res.replaceAll('temp2.pdf', '');
  }

  void _deleteTempDir() async {
    if (_tempPdfDir == null) return;

    final dir = Directory(_tempPdfDir!);
    if (await dir.exists()) await dir.delete(recursive: true);
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