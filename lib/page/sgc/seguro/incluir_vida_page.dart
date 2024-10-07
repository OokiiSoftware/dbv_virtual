import 'package:dbv_virtual/util/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/model.dart';
import '../../../provider/provider.dart';
import '../../../res/res.dart';

class IncluirVidaPage extends StatefulWidget {
  const IncluirVidaPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<IncluirVidaPage> {

  SgcProvider _sgcProvider = SgcProvider.i;

  final List<Membro> _items = [];

  Future? _future;

  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    _sgcProvider = context.watch<SgcProvider>();

    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Incluir Vidas'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_items.isEmpty) {
            return const Center(
              child: Text('Nenhum membro para incluir'),
            );
          }

          return ListView.separated(
            itemCount: _items.length,
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 70),
            separatorBuilder: (context, i) => const SizedBox(height: 2),
            itemBuilder: (context, i) {
              final item = _items[i];
              return MembroTile(
                key: ValueKey(item),
                membro: item,
                trailing: Checkbox(
                  value: item.selected,
                  onChanged: (value) {
                    item.selected = value!;
                    _setState();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() :
      FloatingActionButton.extended(
        onPressed: _onIncluirTap,
        label: const Text('Incluir Selecionados'),
      ),
    );
  }

  Future<void> _init() async {
    _items.clear();
    _items.addAll(await _sgcProvider.getMembrosToAddSeguro());
    _setState();
  }

  void _onIncluirTap() async {
    List<int> cods = _items.where((e) => e.selected).map((e) => e.codUsuario).toList();

    if (cods.isEmpty) {
      Log.snack('Selecione algum membro', isError: true);
      return;
    }

    _setInProgress(true);

    List body = [
      'Submit1=Incluir selecionados',
      'saldo=1000',
    ];
    body.addAll(cods.map((i) => 'usuario[]=$i').toList());

    try {
      await _sgcProvider.getMembrosToAddSeguro(body: body);
      _items.removeWhere((e) => e.selected);
      Log.snack('Membros Incluidos');
    } catch(e) {
      const Log('IncluirVidaPage').e('_onIncluirTap', e);
      Log.snack('Erro ao realizar operação', isError: true);
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