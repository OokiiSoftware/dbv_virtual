import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class SgcMembrosPage extends StatefulWidget {
  final bool select;
  final bool multselect;
  const SgcMembrosPage({
    super.key,
    this.select = false,
    this.multselect = false,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcMembrosPage> {

  static const _kAtivados = 'Ativados';
  static const _kDesativados = 'Desativados';

  bool get select => widget.select;
  bool get multselect => widget.multselect;

  static String _filtro = _kAtivados;

  final _cPesquisa = TextEditingController();

  SgcProvider _sgcProvider = SgcProvider.i;

  List<Membro> get items {
    List<Membro> list;
    if (_cPesquisa.text.isEmpty) {
      list = _sgcProvider.membros;
    } else {
      list = _sgcProvider.queryMembros(_cPesquisa.text);
    }
    list.sort((a, b) => a.nomeUsuario.toLowerCase().compareTo(b.nomeUsuario.toLowerCase()));

    return list;
  }

  final _selected = <int>[];

  bool get _mostrandoDesativados => _filtro == _kDesativados;
  bool get _todosSelecionados => items.length == _selected.length;
  bool _inProgress = false;

  final _pesquisaFocus = FocusNode();
  Future? _future;

  @override
  void dispose() {
    super.dispose();
    _unselectAll();
  }

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    _sgcProvider = context.watch<SgcProvider>();
    bool solicitacaoAlteracaoMembro = context.watch<EditMembrosProvider>().list.isNotEmpty;

    double appBarHeigth = 120;
    if (solicitacaoAlteracaoMembro) {
      appBarHeigth += 80;
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        appBar: SgcAppBar(
          title: const Text('Membros'),
        ),
        body: CustomScrollView(
          slivers: [
            SliverSafeArea(
              sliver: SliverAppBar(
                expandedHeight: appBarHeigth,
                collapsedHeight: appBarHeigth,
                floating: true,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  color: Colors.white,
                  height: appBarHeigth,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: _filtro,
                        decoration: const InputDecoration(
                          labelText: 'Lista de membros',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          )
                        ),
                        items: [
                          _kAtivados,
                          _kDesativados
                        ].map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        )).toList(),
                        onChanged: _onFiltroChanged,
                      ),  // filtro

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cPesquisa,
                              focusNode: _pesquisaFocus,
                              decoration: InputDecoration(
                                labelText: 'PESQUISAR',
                                hintText: 'Nome',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                constraints: const BoxConstraints(
                                  maxHeight: 35,
                                ),
                              ),
                              onChanged: _onPesquisaChanged,
                            ),
                          ),

                          if (!multselect)
                            IconButton(
                              tooltip: 'Visualização',
                              onPressed: _onModeListTap,
                              icon: Icon(VariaveisGlobais.listMode ? Icons.list : Icons.grid_view),
                            ),
                        ],
                      ),  // pesquisa

                      if (solicitacaoAlteracaoMembro)
                        Container(
                          color: Colors.orangeAccent,
                          child: ListTile(
                            onTap: _onSolicitacaoAlteracaoMembroTap,
                            title: const Text('Solicitação de alteração'),
                            subtitle: const Text('Alguns membros solicitaram atualização de seus dados'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text('${_todosSelecionados ? 'Desmarcar' : 'Selecionar'} todos'),
                    value: _todosSelecionados,
                    onChanged: _onSelectAllChanged,
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return _body();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _actionButton(),
      ),
    );
  }

  Widget _body() {
    if (VariaveisGlobais.listMode || multselect) {
      return ListView.separated(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(3, 0, 3, 70),
        itemBuilder: (context, i) {
          return itemBuilder(items[i]);
        },
        separatorBuilder: (context, i) => const SizedBox(height: 2),
      );
    }

    final pageWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = pageWidth ~/ 150;

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 70),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1/1.5,
      ),
      itemBuilder: (_, i) => itemBuilder(items[i]),
    );
  }

  Widget itemBuilder(Membro value) {
    if (VariaveisGlobais.listMode || multselect) {
      return MembroTile(
        key: ValueKey(value),
        membro: value,
        showFichaPendente: !_mostrandoDesativados,
        importado: MembrosProvider.i.data[value.id] != null,
        onTap: multselect ? (value) => _onMembroSelectedChanged(value, !value.selected) : onItemTap,
        trailing: multselect ? Checkbox(
          value: value.selected,
          onChanged: (v) => _onMembroSelectedChanged(value, v),
        ) : Checkbox(
          value: value.selected,
          onChanged: (v) => _onSelectedChanged(value, v),
        ),
      );
    }

    return MembroTileGrid(
      key: ValueKey(value),
      membro: value,
      importado: _mostrandoDesativados ? null : MembrosProvider.i.data[value.id] != null,
      onTap: onItemTap,
      showFichaPendente: !_mostrandoDesativados,
      icon: Checkbox(
        value: value.selected,
        onChanged: (v) => _onSelectedChanged(value, v),
      ),
    );
  }

  Widget _actionButton() {
    if (_inProgress) {
      return const CircularProgressIndicator();
    }

    if (_selected.isEmpty) {
      return FloatingActionButton.extended(
        heroTag: 'IGJHBih',
        onPressed: _onAddTap,
        label: const Text('Add Membro'),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_filtro == _kAtivados)...[
          FloatingActionButton.extended(
            heroTag: 'UIhyYUygi',
            onPressed: _onDesativarTap,
            label: const Text('Desativar'),
          ),

          const SizedBox(height: 5, width: 5),

          FloatingActionButton.extended(
            heroTag: 'yTUIIOHh',
            onPressed: _onImportTap,
            label: const Text('Importar\nAtualizar'),
          ),
        ] else...[
          FloatingActionButton.extended(
            heroTag: 'huiGUGs',
            onPressed: _onAtivarTap,
            label: const Text('Ativar'),
          ),
        ],
      ],
    );
  }


  Future<void> _init() async {
    Future.delayed(const Duration(milliseconds: 150), () {
      _sgcProvider.loadLocalMembros(_mostrandoDesativados);
    });

    await _sgcProvider.loadMembros(
      desativados: _mostrandoDesativados,
    );
  }

  Future<void> _onRefresh() async {
    await _sgcProvider.loadMembros(
      force: true,
      desativados: _mostrandoDesativados,
    );
    EditMembrosProvider.i.refresh();
  }

  void onItemTap(Membro membro) async {
    _pesquisaFocus.unfocus();
    if (select) {
      Navigator.pop(context, membro);
      return;
    }

    await Navigate.push(context, SgcMembroPage(
      membro: membro.copy(),
      readOnly: FirebaseProvider.i.readOnly,
    ));
    _setState();
  }



  void _onSolicitacaoAlteracaoMembroTap() async {
    Navigate.push(context, const SgcAlteracaoMembrosPage());
  }

  void _onAddTap() async {
    _pesquisaFocus.unfocus();
    await Navigate.push(context, SgcMembroPage(
      membro: Membro(),
      readOnly: FirebaseProvider.i.readOnly,
    ));
    _setState();
  }

  void _onImportTap() async {
    _setInProgress(true);

    try {
      for (var cod in _selected) {
        var membro = _sgcProvider.membrosData[cod]!;

        /// EstadoCivil é obrigatório, se = 0 o membro não foi carregado
        if (membro.codEstadoCivil == 0) {
          membro = await _sgcProvider.getMembro(cod);
          _sgcProvider.membrosData[cod] = membro;
        }

        FirebaseProvider.i.criarIdentificador(membro.id);
        await MembrosProvider.i.add(membro);
      }

      Log.snack('Dados importados');
      _unselectAll();
    } catch(e) {
      Log.snack('Erro ao importar dados', isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
    }

    _setInProgress(false);
  }

  void _onDesativarTap() async {
    final res = await DialogBox(
      context: context,
      content: [
        for (var cod in _selected)...[
          MembroTile(
            key: ValueKey(cod),
            membro: _sgcProvider.membrosData[cod]!,
            dense: true,
          ),
          const SizedBox(height: 5),
        ],

        const Text('Deseja desativar esses membros?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    try {
      for (var cod in _selected) {
        var membro = _sgcProvider.membrosData[cod]!;

        FirebaseProvider.i.removerIdentificador(membro.id);
        await MembrosProvider.i.remove(membro);
      }
      await _sgcProvider.setMembrosAtivo(_selected, false);

      Log.snack('Membros desativados');
    } catch(e) {
      Log.snack('Erro ao realizar ação', isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
    }

    _unselectAll();
    _setInProgress(false);
  }

  void _onAtivarTap() async {
    final res = await DialogBox(
      context: context,
      content: [
        for (var cod in _selected)...[
          MembroTile(
            key: ValueKey(cod),
            membro: _sgcProvider.membrosData[cod]!,
            dense: true,
          ),
          const SizedBox(height: 5),
        ],

        const Text('Deseja ativar esses membros?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    try {
      for (var cod in _selected) {
        var membro = _sgcProvider.membrosData[cod]!;

        FirebaseProvider.i.criarIdentificador(membro.id);
        await MembrosProvider.i.add(membro);
      }
      await _sgcProvider.setMembrosAtivo(_selected, true);

      Log.snack('Membros ativados');
    } catch(e) {
      Log.snack('Erro ao realizar ação', isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
    }

    _unselectAll();
    _setInProgress(false);
  }


  void returnMultSelect() {
    Navigator.pop(context, items.where((e) => e.selected).toList());
  }


  void _onMembroSelectedChanged(Membro membro, bool? value) {
    membro.selected = value!;
    _setState();
  }

  void _onSelectedChanged(Membro membro, bool? value) {
    membro.selected = value!;

    if (value) {
      _selected.add(membro.codUsuario);
    } else {
      _selected.remove(membro.codUsuario);
    }
    _setState();
  }

  void _onFiltroChanged(String? value) async {
    if (_filtro == value) return;

    _filtro = value!;
    _setState();

    _setInProgress(true);
    await _sgcProvider.loadMembros(
      desativados: _mostrandoDesativados,
      force: true,
    );
    _setInProgress(false);
  }

  void _onSelectAllChanged(bool? value) {
    if (value!) {
      _selected.clear();
      for (var e in items) {
        e.selected = true;
        _selected.add(e.codUsuario);
      }
    } else {
      _unselectAll();
    }

    _setState();
  }


  void _onPesquisaChanged(String value) {
    _setState();
  }

  void _onModeListTap() {
    VariaveisGlobais.listMode = !VariaveisGlobais.listMode;
    pref.setBool(PrefKey.listMode, VariaveisGlobais.listMode);
    _setState();
  }


  void _unselectAll() {
    for (var cod in _selected) {
      _sgcProvider.membrosData[cod]?.selected = false;
    }

    _selected.clear();
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
