import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class UnidadePage extends StatefulWidget {
  final Unidade unidade;
  const UnidadePage({
    super.key,
    required this.unidade,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<UnidadePage> {

  final _log = const Log('UnidadePage');

  late Unidade unidade = widget.unidade;

  final _formKey = GlobalKey<FormState>();

  bool get isNovo => unidade.codUnidade == 0;

  bool _inProgress = false;
  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    final membros = MembrosProvider.i.data;
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Unidade'),
        actions: [
          if (!isNovo)
            IconButton(
              onPressed: _onDeleteTap,
              icon: const Icon(Icons.delete_forever),
            ),

          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: unidade.nomeUnidade,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Nome da unidade',
                    ),
                    validator: Validators.obrigatorio,
                    onSaved: (value) => unidade.nomeUnidade = value!,
                  ),  // nome

                  DropdownButtonFormField(
                    value: unidade.codConselheiro,
                    hint: const Text('Selecione'),
                    decoration: const InputDecoration(
                      labelText: 'Conselheiro',
                    ),
                    items: [0, ...unidade.conselheiroIds].map((key) => DropdownMenuItem(
                      value: key,
                      child: Text(membros['_$key']?.nomeUsuario ?? 'Selecionar'),
                    )).toList(),
                    onChanged: (int? value) => unidade.codConselheiro = value!,
                    validator: Validators.dropDownIntObrigatorio,
                    onSaved: (value) => unidade.codConselheiro = value!,
                  ),  // conselheiro

                  TextFormField(
                    initialValue: '${unidade.senha}',
                    keyboardType: TextInputType.number,
                    inputFormatters: TextType.numero.inputFormatters,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Senha da unidade',
                    ),
                    validator: (value) {
                      if (value!.length != 4) return 'Informe 4 digitos';

                      return null;
                    },
                    onSaved: (value) => unidade.senha = int.parse(value!),
                  ),  // senha

                  TextFormField(
                    initialValue: unidade.historico,
                    keyboardType: TextInputType.text,
                    inputFormatters: TextType.text.inputFormatters,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Histórico',
                      hintText: 'Fundação, conselheiros, etc...',
                    ),
                    onSaved: (value) => unidade.historico = value!,
                  ),  // Histórico

                  TextFormField(
                    initialValue: unidade.extras,
                    keyboardType: TextInputType.text,
                    inputFormatters: TextType.text.inputFormatters,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Extras',
                      hintText: 'Brado, significado do nome, etc...',
                    ),
                    onSaved: (value) => unidade.extras = value!,
                  ),  // extras

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: ElevatedButton(
                      onPressed: _onSaveTap,
                      child: const Text('Salvar'),
                    ),
                  )

                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Future<void> _init() async {
    if (isNovo) {
      final cods = await SgcProvider.i.getUnidadeConselheiros();
      unidade.conselheiroIds.addAll(cods);
      return;
    }

    unidade = await SgcProvider.i.getUnidade(unidade);
  }

  void _onSaveTap() async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    _setInProgress(true);

    try {
      unidade.codClube = ClubeProvider.i.clube.codigo;
      unidade.codAutor = FirebaseProvider.i.user.codUsuario;
      unidade.dtCadastro = Formats.dataUs(DateTime.now());

      await SgcProvider.i.getUnidade(unidade, send: true);

      if (mounted) {
        Navigator.pop(context, true);
      }
      Log.snack('Unidade salva');
    } catch(e) {
      _log.e('_onSaveTap', e);
      Log.snack('Erro ao salvar os dados', isError: true);
    }

    _setInProgress(false);
  }

  void _onDeleteTap() async {
    if (!await Popup(context).delete()) return;

    _setInProgress(true);
    try {
      await SgcProvider.i.removeUnidade(unidade.codUnidade);

      if (mounted) {
        Navigator.pop(context, false);
      }
      Log.snack('Unidade removida');
    } catch(e) {
      _log.e('_onDeleteTap', e);
      Log.snack('Erro ao realizar ação', isError: true);
    }

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