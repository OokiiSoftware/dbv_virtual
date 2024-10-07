import 'dart:io';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../provider/provider.dart';
import '../../../service/service.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class ClubeEditPage extends StatefulWidget {
  final Clube clube;
  final bool readOnly;
  final Future<void> Function(Clube)? onRegistro;
  const ClubeEditPage({
    super.key,
    this.readOnly = false,
    this.onRegistro,
    required this.clube,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<ClubeEditPage> {

  Clube get clube => widget.clube;
  bool get readOnly => widget.readOnly;
  Future<void> Function(Clube)? get onRegistro => widget.onRegistro;

  bool get registro => onRegistro != null;

  final _formKey = GlobalKey<FormState>();

  bool _inProgress = false;

  String? _fotoPath;

  Color colorP = Tema.i.primaryColor;
  Color colorS = Tema.i.tintDecColor;

  late MoneyMaskedTextController taxaMensaoController = MoneyMaskedTextController(
    initialValue: clube.taxaMensal,
  );

  @override
  Widget build(BuildContext context) {
    if (!Arrays.diasSemana.contains(clube.reuniaoDia)) {
      clube.reuniaoDia = Arrays.diasSemana.first;
    }

    return Scaffold(
      appBar: registro ? null : AppBar(
        title: Text(clube.nome),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            const SizedBox(height: 10),

            SizedBox(
              width: 200,
              height: 200,
              child: InkWell(
                onTap: readOnly ? null : _onImageTap,
                child: Card(
                  child: _imageWidget(),
                ),
              ),
            ),  // image

            Card(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: clube.nome,
                    keyboardType: TextInputType.name,
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      labelText: 'Nome do clube',
                    ),
                    onSaved: (value) => clube.nome = value!,
                    validator: Validators.obrigatorio,
                  ),  // nome

                  TextFormField(
                    initialValue: clube.associacao,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      labelText: 'Associação',
                    ),
                    onSaved: (value) => clube.associacao = value!,
                  ),  // associacao

                  TextFormField(
                    initialValue: clube.regiao,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      labelText: 'Região',
                    ),
                    onSaved: (value) => clube.regiao = value!,
                  ),  // regiao

                  TextFormField(
                    initialValue: clube.dataFundacao,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.data.inputFormatters,
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      labelText: 'Data da Fundação',
                    ),
                    onSaved: (value) => clube.dataFundacao = value!,
                  ),  // dataFundacao

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          value: clube.reuniaoDia,
                          items: Arrays.diasSemana.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          )).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Dia de Reunião',
                          ),
                          onChanged: _onDiaReuniaoChanged,
                        ),
                      ),  // dia
                      Expanded(
                        child: TextFormField(
                          initialValue: clube.reuniaoHora,
                          keyboardType: TextInputType.name,
                          readOnly: readOnly,
                          inputFormatters: TextType.hora.inputFormatters,
                          decoration: const InputDecoration(
                            labelText: 'Horário de Reunião',
                          ),
                          onSaved: (value) => clube.reuniaoHora = value!,
                        ),
                      ),  // hora
                    ],
                  ),  // dia reunião
                ],
              ),
            ),

            const SizedBox(height: 10),

            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  const Text('Dados de pagamento da taxa'),

                  TextFormField(
                    controller: taxaMensaoController,
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      prefixText: 'R\$ ',
                      labelText: 'Valor da Taxa Mensal',
                    ),
                    onSaved: (value) => clube.taxaMensal = taxaMensaoController.numberValue,
                  ),  // taxaMensal

                  TextFormField(
                    initialValue: clube.pixChave,
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      labelText: 'Chave Pix para pagamento',
                    ),
                    onSaved: (value) => clube.pixChave = value!,
                  ),  // Chave Pix

                  TextFormField(
                    initialValue: clube.pixNomePessoa,
                    keyboardType: TextInputType.name,
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      labelText: 'Nome do recebedor',
                    ),
                    onSaved: (value) => clube.pixNomePessoa = value!,
                  ),  // Chave Pix

                  const SizedBox(height: 5),
                ],
              ),
            ),

            if (!readOnly)...[
              TextFormField(
                initialValue: clube.regulamentoInterno,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Link do regulamento Interno',
                ),
                onSaved: (value) => clube.regulamentoInterno = value!,
                // validator: Validators.obrigatorio,
              ),  // regulamentoInterno

              const SizedBox(height: 20),

              if (clube.id.isNotEmpty)
                SizedBox(
                  child: ElevatedButton(
                    onPressed: _onHinoTap,
                    child: const Text('Hino do Clube'),
                  ),
                ),  // hino

              const Text('Selecione as cores do seu clube',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => _onColorTap(colorP, true),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: colorP,
                            ),
                          ),
                        ),
                        const Text('Cor Primária'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => _onColorTap(colorS, false),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: colorS,
                            ),
                          ),
                        ),
                        const Text('Cor Secundária'),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSaveTap,
                  child: Text(registro ? 'Registrar Clube' : 'Salvar'),
                ),
              ),  // save
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Widget _imageWidget() {
    if (_fotoPath != null) {
      return Image.file(File(_fotoPath!));
    }

    return FotoLayout(
      path: clube.logoUrl,
      borderRadius: 10,
      fit: BoxFit.contain,
      headers: FirebaseProvider.i.headers,
    );
  }

  void _onImageTap() async {
    final picker = ImagePicker();
    final res = await picker.pickImage(source: ImageSource.gallery);

    _fotoPath = res?.path;
    _setState();
  }

  void _onSaveTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    _setInProgress(true);
    final isNovo = clube.id.isEmpty;

    if (isNovo) {
      clube.id = randomString();
      FirebaseProvider.i.setClubeId(clube.id);
    }

    if (_fotoPath != null) {
      try {
        final url = await _uploadFoto();
        await File(_fotoPath!).copy(Ressorces.clubeLogo.path);
        clube.logoUrl = url;
      } catch(e) {
        if (mounted) {
          DialogBox(
            context: context,
            title: 'Erro ao enviar imagem',
            content: [
              Text(e.toString()),
            ],
          ).ok();
        } else {
          Log.snack(e.toString(), isError: true);
        }
        const Log('ClubeEditPage').e('_uploadFoto', e);

        _setInProgress(false);
        return;
      }
    }

    String convert(Color color) {
      return color.toString().replaceAll('Color(0x', '').replaceAll(')', '');
    }

    clube.primaryColor = convert(colorP);
    clube.secondaryColor = convert(colorS);

    try {
      await ClubeProvider.i.set(clube);
      await onRegistro?.call(clube);
      Log.snack('Dados salvos');
    } catch(e) {
      if (isNovo) {
        FirebaseProvider.i.setClubeId('');
      }
      Log.snack('Erro ao salvar os dados', isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
    }

    Tema.i.notify();
    _setInProgress(false);
  }

  void _onHinoTap() async {
    final res = await Navigate.push(context, HinoPage(hino: clube.hino));
    if (res is String) {
      clube.hino = res;
      _setState();
    }
  }

  void _onColorTap(Color color, bool primary) async {
    final res = await DialogBox(
      context: context,
      title: primary ? 'Cor Primária' : 'Cor Sencundária',
      content: [
        const Text('Algumas cores podem dificultar a leitura, então fique atento',
          style: TextStyle(
            color: Colors.red,
          ),
        ),

        ColorPicker(
          pickerColor: color,
          enableAlpha: false,
          paletteType: PaletteType.hueWheel,
          onColorChanged: (Color value) {
            color = value;
          },
        ),
      ],
    ).cancelOK();
    if (!res.isPositive) return;

    if (primary) {
      colorP = color;
    } else {
      colorS = color;
    }

    _setState();
  }


  Future<String> _uploadFoto() async {
    final prov = FirebaseProvider.i;

    final path = [
      ChildKeys.clubes,
      prov.clubeId,
      'images',
      'clubeLogo.jpg',
    ];

    final bytes = await Util.compressImage(_fotoPath!);
    return await FirebaseProvider.i.uploadFile(path, bytes);
  }


  void _onDiaReuniaoChanged(String? value) {
    clube.reuniaoDia = value!;
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