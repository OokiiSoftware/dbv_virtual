import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class SgcSolicitacaoEspecialidadesPage extends StatefulWidget{
  const SgcSolicitacaoEspecialidadesPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcSolicitacaoEspecialidadesPage> {

  final _editProv = EditEspecialidadesProvider.i;

  Map<String, EspecialidadeSolicitacao> get _esps => _editProv.data;

  List<Membro> get _membros {
    List<Membro> items = [];

    for (var key in _esps.keys) {
      final membro = MembrosProvider.i.data[key];
      if (membro != null) {
        items.add(membro);
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Solicitações'),
      ),
      body: ListView.separated(
        itemCount: _membros.length,
        padding: const EdgeInsets.all(5),
        separatorBuilder: (_, i) => const SizedBox(height: 2),
        itemBuilder: (context, i) {
          final item = _membros[i];

          return MembroTile(
            key: ValueKey(item),
            membro: item,
            onTap: (item) => _onMembroTap(item, _esps[item.id]!),
            trailing: IconButton.filled(
              onPressed: () => _onMembroTap(item, _esps[item.id]!),
              icon: Text('${_esps[item.id]!.especialidades.length}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onMembroTap(Membro value, EspecialidadeSolicitacao esp) async {
    await Navigate.push(context, SgcSolicitacaoEspecialidadesMembroPage(
      membro: value,
      especialidade: esp,
    ));
    setState(() {});
  }
}

class SgcSolicitacaoEspecialidadesMembroPage extends StatefulWidget{
  final Membro membro;
  final EspecialidadeSolicitacao especialidade;
  const SgcSolicitacaoEspecialidadesMembroPage({
    super.key,
    required this.membro,
    required this.especialidade,
  });

  @override
  State<StatefulWidget> createState() => _StateMembro();
}
class _StateMembro extends State<SgcSolicitacaoEspecialidadesMembroPage> {

  final _log = const Log('SgcSolicitacaoEspecialidadesMembroPage');

  Membro get membro => widget.membro;
  EspecialidadeSolicitacao get especialidade => widget.especialidade;

  bool get meuPerfil => membro.id == FirebaseProvider.i.user.id;

  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    final esps = especialidade.especialidades.values.toList();

    return Scaffold(
      appBar: SgcAppBar(
        title: Text(membro.nomeUsuario),
      ),
      body: Column(
        children: [
          Card(
            child: ListTile(
              title: Text('Instrutor: ${especialidade.dados.instrutor}'),
              subtitle: Text('Data: ${especialidade.dados.data}'),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: esps.length,
              padding: const EdgeInsets.only(bottom: 70),
              itemBuilder: (context, i) {
                final item = esps[i];

                return EspecialidadeTile(
                  key: ValueKey(item),
                  especialidade: item,
                  onTap: (item) {
                    item.selected = !item.selected;
                    _setState();
                  },
                  trailing: Checkbox(
                    value: item.selected,
                    onChanged: (value) {
                      item.selected = value!;
                      _setState();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() :
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'uioidlf',
            onPressed: _onRejeitarTap,
            backgroundColor: Colors.orangeAccent,
            label: const Text('Rejeitar\nSelecionados'),
          ),

          const SizedBox(width: 5),

          FloatingActionButton.extended(
            heroTag: 'yuioijm',
            onPressed: _onAprovarTap,
            backgroundColor: Colors.lightBlueAccent,
            label: const Text('Aprovar\nSelecionados'),
          ),
        ],
      ),
    );
  }

  void _onAprovarTap() async {
    if (meuPerfil) {
      DialogBox(
        context: context,
        title: 'Ops',
        content: const [
          Text('Você não pode aprovar suas próprias especialidades'),
        ],
      ).ok();
      return;
    }

    final selecteds = especialidade.especialidades.values.where((e) => e.selected).toList();

    if (selecteds.isEmpty) {
      return Log.snack('Selecione as especialidades', isError: true);
    }

    final res = await DialogBox(
      context: context,
      title: 'Aprovar',
      content: const [
        Text('Deseja aprovar a adição das especialidades selecionadas?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    try {
      int codClube = ClubeProvider.i.clube.codigo;
      if (codClube == 0) {
        codClube = await SgcProvider.i.getCodClube();
        if (codClube == 0) throw 'clubeCod == null';

        ClubeProvider.i.setCodigo(codClube);
      }

      final body = {
        'instrutor': especialidade.dados.instrutor,
        'dt_termino': especialidade.dados.data,
        'dt_cadastro': Formats.dataHoraUs(DateTime.now()),
        'cod_autor': FirebaseProvider.i.user.codUsuario,
        'cod_clube': codClube,
      };

      await SgcProvider.i.enviarEspecialidades([membro], selecteds, body);
    } catch(e) {
      _log.e('_onAprovarTap', e);
      Log.snack('Erro ao realizar ação', isError: true);
    }

    await _common('_onAprovarTap', selecteds);

    _setInProgress(false);
  }

  void _onRejeitarTap() async {
    final selecteds = especialidade.especialidades.values.where((e) => e.selected).toList();

    if (selecteds.isEmpty) {
      return Log.snack('Selecione as especialidades', isError: true);
    }

    final res = await DialogBox(
      context: context,
      title: 'Rejeitar',
      content: const [
        Text('Deseja rejeitar a adição das especialidades selecionadas?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    await _common('_onRejeitarTap', selecteds);

    _setInProgress(false);
  }

  Future<void> _delete(List<Especialidade> items) async {
    for (var esp in items) {
      await EditEspecialidadesProvider.i.removeEsp(esp, membro.id);
    }
  }

  Future<void> _deleteDados() async {
    await EditEspecialidadesProvider.i.removeDados(membro.id);

    if (mounted) Navigator.pop(context);
  }


  Future<void> _common(String tag, List<Especialidade> selecteds) async {
    try {
      await _delete(selecteds);
      especialidade.especialidades.removeWhere((key, e) => e.selected);

      if (especialidade.especialidades.isEmpty) {
        await _deleteDados();
      }
      Log.snack('Dados salvos');
    } catch(e) {
      _log.e(tag, e);
      Log.snack('Erro ao realizar ação', isError: true);
    }
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