import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class SgcEspMembroPage extends StatefulWidget {
  final Membro membro;
  const SgcEspMembroPage({
    super.key,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcEspMembroPage> {

  Membro get membro => widget.membro;

  final List<MembroEspecialidade> _esps = [];

  Future? _future;

  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Especialidades do membro'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: MembroTile(
              key: ValueKey(membro),
              membro: membro,
            ),
          ),  // membro

          FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: LinearProgressIndicator());
              }

              if (_esps.isEmpty) {
                return const Text('Esse membro não tem especialidades registradas');
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: _esps.length,
                  itemBuilder: (context, i) {
                    final item = _esps[i];

                    return Card(
                      child: Row(
                        children: [
                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.nome),
                                Text(item.data),
                              ],
                            ),
                          ),

                          if (item.canDelete)
                            IconButton(
                              tooltip: 'Remover',
                              onPressed: () => _onDeleteEspTap(item),
                              icon: const Icon(Icons.delete_forever),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),  // esp list
        ],
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Future<void> _init() async {
    final items = await SgcProvider.i.loadEspecialidadesMembro(membro.codUsuario);
    _esps.addAll(items);
    _esps.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }

  void _onDeleteEspTap(MembroEspecialidade esp) async {
    final res = await DialogBox(
      context: context,
      title: esp.nome,
      content: const [
        Text('Deseja remover essa especialidade?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    await SgcProvider.i.removeEspecialidadesMembro(esp.cod).then((value) {
      Log.snack('Especialidade removida');
      _esps.remove(esp);
    }).catchError((e) {
      Log.snack('Erro ao remover especialidade', isError: true);
      const Log('SgcEspMembroPage').e('_onDeleteEspTap', e);
    });

    _setInProgress(false);
  }

  void _setInProgress(bool b) {
    _inProgress = b;
    if (mounted) {
      setState(() {});
    }
  }
}