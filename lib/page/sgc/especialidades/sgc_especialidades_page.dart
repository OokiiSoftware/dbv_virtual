import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/model.dart';
import '../../../provider/provider.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

class SgcEspecialidadesPage extends StatefulWidget {
  const SgcEspecialidadesPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcEspecialidadesPage> {

  SgcProvider _sgcProvider = SgcProvider.i;
  final _cPesquisa = TextEditingController();
  final _pesquisaFocus = FocusNode();

  Future? _future;

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

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    _sgcProvider = context.watch<SgcProvider>();
    bool solicitacaoEspecialidades = context.watch<EditEspecialidadesProvider>().list.isNotEmpty;

    double appBarHeigth = 120;
    if (solicitacaoEspecialidades) {
      appBarHeigth += 80;
    }

    return RefreshIndicator(
      onRefresh: EditEspecialidadesProvider.i.refresh,
      child: Scaffold(
        appBar: SgcAppBar(
          title: const Text('Especialidades'),
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
                      Container(
                        width: double.infinity,
                        height: 40,
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton.icon(
                          onPressed: _onAddEspecialidadesTap,
                          label: const Text('Atribuir Especialidades'),
                          icon: const Icon(Icons.local_fire_department),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
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

                            IconButton(
                              tooltip: 'Visualização',
                              onPressed: _onModeListTap,
                              icon: Icon(VariaveisGlobais.listMode ? Icons.list : Icons.grid_view),
                            ),
                          ],
                        ),
                      ),  // pesquisa

                      if (solicitacaoEspecialidades)
                        Container(
                          color: Colors.orangeAccent,
                          child: ListTile(
                            onTap: _onSolicitacoesTap,
                            title: const Text('Solicitação de especialidades'),
                            subtitle: const Text('Alguns membros solicitaram a adição de suas especialidades'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: LinearProgressIndicator());
                  }

                  return _body();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (VariaveisGlobais.listMode) {
      return ListView.separated(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(3, 10, 3, 70),
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
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 70),
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
    if (VariaveisGlobais.listMode) {
      return MembroTile(
        key: ValueKey(value),
        membro: value,
        importado: MembrosProvider.i.data[value.id] != null,
        onTap: onItemTap,
      );
    }

    return MembroTileGrid(
      key: ValueKey(value),
      membro: value,
      importado: MembrosProvider.i.data[value.id] != null,
      onTap: onItemTap,
    );
  }


  Future<void> _init() async {
    Future.delayed(const Duration(milliseconds: 150), () {
      _sgcProvider.loadLocalMembros(false);
    });

    await _sgcProvider.loadMembros();
  }

  void onItemTap(Membro membro) {
    _pesquisaFocus.unfocus();

    Navigate.push(context, SgcEspMembroPage(
      membro: membro.copy(),
    ));
  }

  void _onAddEspecialidadesTap() async {
    Navigate.push(context, const SgcAddEspecialidadePage());
  }

  void _onSolicitacoesTap() async {
    Navigate.push(context, const SgcSolicitacaoEspecialidadesPage());
  }


  void _onPesquisaChanged(String value) {
    _setState();
  }

  void _onModeListTap() {
    VariaveisGlobais.listMode = !VariaveisGlobais.listMode;
    pref.setBool(PrefKey.listMode, VariaveisGlobais.listMode);
    _setState();
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}