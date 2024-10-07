import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class SegurosPage extends StatefulWidget {
  const SegurosPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SegurosPage> {

  SgcProvider _sgcProvider = SgcProvider.i;

  final _cPesquisa = TextEditingController();
  final _pesquisaFocus = FocusNode();

  int _filtro = 0;

  Future? _future;

  bool _inProgress = false;

  final List<SeguroRemessa> _items = [];

  List<SeguroRemessa> get items {
    final List<SeguroRemessa> list = [];
    if (_cPesquisa.text.isEmpty) {
      list.addAll(_items);
    } else {
      list.addAll(_items.where((e) => e.nomeUsuario.toLowerCase().contains(_cPesquisa.text.toLowerCase())));
    }

    list.removeWhere((e) {
      switch(_filtro) {
        case 1:
          return !e.ativo;
        case 2:
          return e.ativo;
        default: return false;
      }
    });
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

    Widget radio(String title, int value) {
      return Expanded(
        child: InkWell(
          onTap: () {
            _filtro = value;
            _setState();
          },
          child: SizedBox(
            height: 75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, textAlign: TextAlign.center),
                Radio<int>(
                  value: value,
                  groupValue: _filtro,
                  onChanged: (value) {
                    _filtro = value!;
                    _setState();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        appBar: SgcAppBar(
          title: const Text('Seguros'),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              collapsedHeight: 130,
              floating: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextFormField(
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

                    Row(
                      children: [
                        radio('Todos', 0),
                        radio('Ativos', 1),
                        radio('Inativos', 2),
                      ],
                    ),
                  ],
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

                  return ListView.separated(
                    itemCount: items.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(3, 0, 3, 70),
                    separatorBuilder: (context, i) => const SizedBox(height: 2),
                    itemBuilder: (context, i) {
                      final value = items[i];

                      return SeguroRemessaTile(
                        key: ValueKey(value),
                        seguro: value,
                        onTransferTap: _onChangeSeguroTap,
                        onDeleteTap: _onDeleteTap,
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
        floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
      ),
    );
  }


  Future<void> _init() async {
    _items.clear();
    _items.addAll(await _sgcProvider.getRemessaSeguros());
  }

  Future<void> _onRefresh() async {
    if (InternetProvider.i.disconnected) {
      return InternetProvider.showMsgNoConnect();
    }

    _items.clear();
    _items.addAll(await _sgcProvider.getRemessaSeguros());
    _setState();
  }

  void _onChangeSeguroTap(SeguroRemessa seguro) async {
    _pesquisaFocus.unfocus();

    final res = await Navigate.push(context, SeguroChangePage(seguro: seguro));
    if (res == true) {
      _items.remove(seguro);

      _setInProgress(true);
      await _onRefresh();
      _setInProgress(false);
    }
  }

  void _onDeleteTap(SeguroRemessa seguro) async {
    _pesquisaFocus.unfocus();

    final res = await DialogBox(
      context: context,
      title: 'Remover seguro',
      content: [
        Text('Deseja remover o seguro de ${seguro.nomeUsuario}?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    try {
      await _sgcProvider.removeSeguro(seguro.codUsuario, seguro.codVida);
      _items.remove(seguro);
      Log.snack('Seguro removido');
    } catch(e) {
      const Log('SegurosPage').e('_onDeleteTap', e);
      Log.snack('Ocorreu um erro na operção', isError: true);
    }

    _setInProgress(false);
  }

  void _onPesquisaChanged(String value) {
    _setState();
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