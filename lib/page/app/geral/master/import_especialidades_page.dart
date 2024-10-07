import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../../provider/provider.dart';
import '../../../../util/util.dart';
import '../../../../res/res.dart';

class ImportEspecialidadesPage extends StatefulWidget {
  const ImportEspecialidadesPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<ImportEspecialidadesPage> {

  final _log = const Log('ImportEspecialidadesPage');

  final _sgcProvider = SgcProvider.i;
  final _espProvider = EspecialidadesProvider.i;

  final Map<String, Especialidade> _especialidadesSgc = {};
  final Map<String, Especialidade> _especialidadesFirebase = {};
  final Map<String, Especialidade> _direfence = {};

  bool _inProgress = false;
  Future? _future;

  bool get _allSelected {
    return _direfence.values.where((e) => e.selected).length == _direfence.length;
  }

  bool get _allImported {
    return _especialidadesSgc.length == _especialidadesFirebase.length;
  }

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Especialidades'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return _body();
        },
      ),
      floatingActionButton: _floatincActionButton(),
    );
  }

  Widget _body() {
    if (_allImported) {
      final semText = {..._especialidadesSgc};
      semText.removeWhere((key, value) => value.text.isNotEmpty);
      final list = semText.values.toList();

      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onVerificarPreenchidosTap,
              child: const Text('Verificar preenchidos'),
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, i) => const SizedBox(height: 2),
              itemBuilder: (context, i) {
                final item = list[i];
                return EspecialidadeTile(
                  key: ValueKey(item),
                  especialidade: item,
                  onTap: (value) {},
                  trailing: Checkbox(
                    value: item.text.isEmpty,
                    onChanged: (value) {},
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    final list = _direfence.values.toList();

    return Column(
      children: [
        ListTile(
          title: Text('especialidades Sgc (${_especialidadesSgc.length})'),
          subtitle: Text('especialidades Firebase (${_especialidadesFirebase.length})'),
        ),

        CheckboxListTile(
          title: const Text('Selecionar todos'),
          value: _allSelected,
          onChanged: _setSelected,
        ),  // select all

        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, i) => const SizedBox(height: 2),
            itemBuilder: (context, i) {
              final item = list[i];
              return EspecialidadeTile(
                key: ValueKey(item),
                especialidade: item,
                onTap: (value) {
                  value.selected = !value.selected;
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
    );
  }

  Widget? _floatincActionButton() {
    if (_inProgress) return const CircularProgressIndicator();

    if (_allImported) {
      return FloatingActionButton.extended(
        onPressed: _onUpdateTap,
        label: const Text('Atualizar Selecionados'),
      );
    }

    return FloatingActionButton.extended(
      onPressed: _onImportTap,
      label: const Text('Importar Selecionados'),
    );
  }

  Future<void> _init() async {
    await _espProvider.refresh();
    _especialidadesSgc.addAll(await _sgcProvider.getEspecialidades());
    _especialidadesFirebase.addAll(_espProvider.data);

    _especialidadesSgc.forEach((key, value) {
      if (!_especialidadesFirebase.containsKey(key)) {
        _direfence[key] = value;
      }
    });

    _setState();
  }

  void _onImportTap() async {
    final selecteds = {..._direfence};
    selecteds.removeWhere((key, value) => !value.selected);

    if (selecteds.isEmpty) return;
    _setInProgress(true);

    try {
      await _espProvider.addAll(selecteds);
      _especialidadesFirebase.addAll(selecteds);
      Log.snack('Dados importados');
    } catch(e) {
      _log.e('_onImportTap', e);
      Log.snack('Erro ao importar', isError: true);
    }
    _setInProgress(false);
  }

  void _onUpdateTap() async {
    final selecteds = {..._especialidadesSgc};
    selecteds.removeWhere((key, value) => value.text.isNotEmpty);

    if (selecteds.isEmpty) return;
    _setInProgress(true);

    try {
      for (var e in selecteds.values) {
        e.text = await _sgcProvider.getEspecialidadeText(e.cod);
        _setState();
      }

      await _espProvider.addAllRequisitos(
          selecteds.map((key, value) => MapEntry(key, value.text)));
    } catch(e) {
      _log.e('_onUpdateTap', e);
      Log.snack('Erro ao atualizar', isError: true);
    }

    _setInProgress(false);
  }

  void _onVerificarPreenchidosTap() async {
    _setInProgress(true);

    _especialidadesFirebase.addAll(await _espProvider.getAllRequisitos());
    _setInProgress(false);
  }


  void _setSelected(bool? value) {
    for (var e in _direfence.values) {
      e.selected = value!;
    }
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