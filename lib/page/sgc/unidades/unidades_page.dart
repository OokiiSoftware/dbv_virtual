import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class UnidadesPage extends StatefulWidget {
  const UnidadesPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<UnidadesPage> {

  final _log = const Log('UnidadesPage');

  static final Map<String, Unidade> _unidades = {};

  bool _inProgress = false;
  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    final list = _unidades.values.toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        appBar: SgcAppBar(
          title: const Text('Unidades'),
        ),
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              itemBuilder: (context, i) {
                final item = list[i];

                return UnidateTile(
                  unidade: item,
                  onTap: _onUnidadeTap,
                  onMembrosTap: _onMembrosTap,
                  onDeleteTap: _onDeleteTap,
                );
              },
              separatorBuilder: (_, i) => const Divider(height: 2),
              itemCount: list.length,
            );
          },
        ),
        floatingActionButton: _inProgress ? const CircularProgressIndicator() :
        FloatingActionButton.extended(
          onPressed: _onUnidadeTap,
          label: const Text('Novo'),
        ),
      ),
    );
  }

  Future<void> _init() async {
    if (_unidades.isNotEmpty) return;
    await _refreshAux();
    _setState();
  }

  Future<void> _onRefresh() async {
    _unidades.clear();
    await _refreshAux();
    _setState();
  }

  Future<void> _refreshAux() async {
    try {
      _unidades.addAll(await SgcProvider.i.getUnidades());
    } catch(e) {
      Log.snack('Erro ao obter os dados', isError: true);
      _log.e('_refreshAux', e);
    }
  }


  void _onUnidadeTap([Unidade? value]) async {
    final res = await Navigate.push(context, UnidadePage(unidade: value?.copy() ?? Unidade()));
    if (res is! bool) return;

    if (res) {
      _setInProgress(true);
      await _onRefresh();
      _setInProgress(false);
    } else {
      _unidades.remove(value?.id);
      _setState();
    }

  }

  void _onDeleteTap(Unidade value) async {
    if (!await Popup(context).delete()) return;

    _setInProgress(true);
    try {
      await SgcProvider.i.removeUnidade(value.codUnidade);
    } catch(e) {
      Log.snack('Erro ao realizar operação', isError: true);
      _log.e('_onDeleteTap', e);
    }

    _setInProgress(false);
  }

  void _onMembrosTap(Unidade value) async {
    Navigate.push(context, UnidadeMembrosPage(unidade: value));
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