import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class UnidadeMembrosPage extends StatefulWidget {
  final Unidade unidade;
  const UnidadeMembrosPage({
    super.key,
    required this.unidade,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<UnidadeMembrosPage> {

  final _log = const Log('UnidadeMembrosPage');

  Unidade get unidade => widget.unidade;

  static final List<UnidadeMembro> _uniMembrosAll = [];
  final List<UnidadeMembro> _uniMembros = [];
  final Map<String, Membro> _membros = MembrosProvider.i.data;

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
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        appBar: SgcAppBar(
          title: Text(unidade.nomeUnidade),
        ),
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onAddMembroTap,
                          child: const Text('Add Membro'),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: MaterialButton(
                          color: Colors.red[300],
                          onPressed: _onRemoveMembroTap,
                          child: const Text('Remover'),
                        ),
                      ),
                    ],
                  ),
                ),

                ListView.separated(
                  itemCount: _uniMembros.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(3),
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, i) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final item = _uniMembros[i];
                    final membro = _membros['_${item.codMembro}'];
                    if (membro == null) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: const Text('Membro não encontrado'),
                      );
                    }

                    return MembroTile(
                      key: ValueKey(membro),
                      membro: membro,
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
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _init() async {
    if (_uniMembrosAll.isNotEmpty) {
      _uniMembros.addAll(_uniMembrosAll.where((e) => e.nomeUnidade == unidade.nomeUnidade));

      if (_uniMembros.isNotEmpty) return;
    }

    await _refreshAux();
  }

  Future<void> _onRefresh() async {
    _uniMembros.clear();
    await _refreshAux();
    _setState();
  }

  Future<void> _refreshAux() async {
    try {
      _uniMembrosAll.clear();
      _uniMembrosAll.addAll(await SgcProvider.i.getUnidadeMembros());

      _uniMembros.addAll(_uniMembrosAll.where((e) => e.nomeUnidade == unidade.nomeUnidade));
    } catch(e) {
      _log.e('_refreshAux', e);
      Log.snack('Erro ao obter os dados', isError: true);
    }
  }


  void _onAddMembroTap() async {
    final res = await Navigate.push(context, const UnidadeAddMembrosPage());
    if (res is! bool) return;

    if (res) {
      _onRefresh();
    }
  }

  void _onRemoveMembroTap() async {
    List<int> cods = [];
    for (var uni in _uniMembros) {
      final mem = _membros[uni.idMembro];
      if (mem?.selected ?? false) {
        cods.add(uni.codMembro);
      }
    }
    if (cods.isEmpty) {
      Log.snack('Selecione um ou mais membros', isError: true);
      return;
    }

    try {
      await SgcProvider.i.removeUnidadeMembros(cods);

      _uniMembrosAll.removeWhere((e) => cods.contains(e.codMembro));
      _uniMembros.removeWhere((e) => cods.contains(e.codMembro));
      _setState();
      Log.snack('Membro removido');
    } catch(e) {
      _log.e('_onRemoveMembroTap', e);
      Log.snack('Erro ao realizar ação', isError: true);
    }
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}