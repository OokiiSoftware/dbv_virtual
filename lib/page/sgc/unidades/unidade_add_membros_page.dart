import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';

class UnidadeAddMembrosPage extends StatefulWidget {
  const UnidadeAddMembrosPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<UnidadeAddMembrosPage> {

  late MembrosUnidade membrosUnidade;
  final _membros = MembrosProvider.i.data;

  int _currentUniCod = 0;
  bool _inProgress = false;
  Future? _future;

  @override
  void dispose() {
    super.dispose();
    MembrosProvider.i.setSelectedAll(false);
  }

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Add Membros'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // CheckboxListTile(
              //   title: Text(_allSelected ? 'Desmarcar tudo' : 'Selecionar tudo'),
              //   value: _allSelected,
              //   onChanged: _setSelected,
              // ),

              DropdownButtonFormField(
                value: _currentUniCod,
                hint: const Text('Selecione'),
                decoration: const InputDecoration(
                  labelText: 'Unidade',
                ),
                items: membrosUnidade.unidades.keys.map((key) => DropdownMenuItem(
                  value: key,
                  child: Text(membrosUnidade.unidades[key]!),
                )).toList(),
                onChanged: (int? value) => _currentUniCod = value!,
                validator: Validators.dropDownIntObrigatorio,
                onSaved: (value) => _currentUniCod = value!,
              ),  // tipo conta

              Expanded(
                child: ListView.separated(
                  itemCount: membrosUnidade.membroCods.length,
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 70),
                  separatorBuilder: (_, i) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final codMembro = membrosUnidade.membroCods[i];
                    final membro = _membros['_$codMembro'];

                    if (membro == null) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: const Text('Membro não encontrado'),
                      );
                    }

                    return MembroTile(
                      key: ValueKey(membro),
                      membro: membro,
                      onTap: (value) {
                        membro.selected = !membro.selected;
                        _setState();
                      },
                      trailing: Checkbox(
                        value: membro.selected,
                        onChanged: (value) {
                          membro.selected = !membro.selected;
                          _setState();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() :
      FloatingActionButton.extended(
        onPressed: _onSaveTap,
        label: const Text('Salvar'),
      ),
    );
  }

  Future<void> _init() async {
    membrosUnidade = await SgcProvider.i.getUnidadeMembroIds();
    if (membrosUnidade.unidades.isEmpty) return;

    _currentUniCod = membrosUnidade.unidades.keys.first;
  }

  void _onSaveTap() async {
    List<int> cods = [];
    for (var cod in membrosUnidade.membroCods) {
      final membro = _membros['_$cod'];
      if (membro == null) continue;

      if (membro.selected) cods.add(cod);
    }

    if (cods.isEmpty) {
      Log.snack('Selecione um ou mais membros', isError: true);
      return;
    }

    _setInProgress(true);
    try {
      final codClube = ClubeProvider.i.clube.codigo;
      final codAutor = FirebaseProvider.i.user.codUsuario;
      final dtCadastro = Formats.dataUs(DateTime.now());

      List<String> body = [
        'cod_clube=$codClube',
        'cod_autor=$codAutor',
        'dt_cadastro=$dtCadastro',
        'cod_unidade=$_currentUniCod',
        'Submit=Salvar',
        'MM_insert=form1',
      ];
      body.addAll(cods.map((i) => 'cod_usuario[]=$i').toList());

      await SgcProvider.i.getUnidadeMembroIds(body);

      membrosUnidade.membroCods.removeWhere((cod) => cods.contains(cod));

      Log.snack('Membros adicionados');
    } catch(e) {
      Log.snack('Erro ao realiza ação', isError: true);
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