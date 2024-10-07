import 'package:flutter/material.dart';
import '../../../../provider/provider.dart';
import '../../../../util/util.dart';
import '../../../../res/res.dart';

class VersionamentoPage extends StatefulWidget {
  const VersionamentoPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<VersionamentoPage> {

  final _controlProvider = VersionControlProvider.i;

  final _cVersionDbv = TextEditingController();
  final _cVersionAguias = TextEditingController();

  bool _importantUpdateAguas = false;
  bool _importantUpdateDbv = false;

  bool _inProgress = false;

  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _controlProvider.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versionamento'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const Text('Enviar atualização',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text('Águias da Colina'),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: _cVersionAguias,
                              keyboardType: TextInputType.number,
                              inputFormatters: TextType.numero.inputFormatters,
                              decoration: const InputDecoration(
                                  labelText: 'Versão'
                              ),
                            ),
                          ),
                          Expanded(child: SwitchListTile(
                            title: const Text('Atualização'),
                            subtitle: const Text('Importante'),
                            value: _importantUpdateAguas,
                            onChanged: (value) {
                              _importantUpdateAguas = value;
                              _setState();
                            },
                          )),
                          IconButton(
                            tooltip: 'Salvar',
                            onPressed: _onSaveVersionAguiasTap,
                            icon: const Icon(Icons.save),
                          ),
                        ],
                      ),

                      const Divider(),
                      const Text('DBV Virtual'),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: _cVersionDbv,
                              keyboardType: TextInputType.number,
                              inputFormatters: TextType.numero.inputFormatters,
                              decoration: const InputDecoration(
                                  labelText: 'Versão'
                              ),
                            ),
                          ),
                          Expanded(child: SwitchListTile(
                            title: const Text('Atualização'),
                            subtitle: const Text('Importante'),
                            value: _importantUpdateDbv,
                            onChanged: (value) {
                              _importantUpdateDbv = value;
                              _setState();
                            },
                          )),
                          IconButton(
                            tooltip: 'Salvar',
                            onPressed: _onSaveVersionDbvTap,
                            icon: const Icon(Icons.save),
                          ),
                        ],
                      ),

                      Text('Versão atual: ${_controlProvider.versionCod}'),
                    ],
                  ),
                ),
              ),

              for(var v in _controlProvider.list)
                Card(
                  child: Column(
                    children: [
                      Text(_nameByPack(v.key)),
                      for(var key in v.versions.keys)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _onDeleteTap(v.key, key),
                              icon: const Icon(Icons.delete_forever),
                            ),
                            Text('$key: '),
                            Text(v.versions[key] == true ? 'Importante' : 'Normal'),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  String _nameByPack(String value) {
    switch(value) {
      case 'comokisoftaguias_colina':
        return 'Águias da Colina';
      case 'comokisoftdbv_virtual':
        return 'DBV Virtual';

      default: return '';
    }
  }

  void _onSaveVersionAguiasTap() async {
    final version = _cVersionAguias.text;
    if (version.isEmpty) return;

    _setInProgress(true);
    await _controlProvider.addVerion('comokisoftaguias_colina', version, _importantUpdateAguas);
    _setInProgress(false);
  }

  void _onSaveVersionDbvTap() async {
    final version = _cVersionDbv.text;
    if (version.isEmpty) return;

    _setInProgress(true);

    await _controlProvider.addVerion('comokisoftdbv_virtual', version, _importantUpdateDbv);

    _setInProgress(false);
  }

  void _onDeleteTap(String pack, String version) async {
    final res = await DialogBox(
      context: context,
      title: version,
      content: const [
        Text('Deseja remover essa versão?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    await _controlProvider.removeVerion(pack, version);

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