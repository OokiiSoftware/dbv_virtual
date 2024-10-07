import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/provider.dart';
import '../../../../model/model.dart';
import '../../../../util/util.dart';
import '../../../../res/res.dart';
import '../../../page.dart';

class EspecialidadeAreasPage extends StatefulWidget {
  final bool readOnly;
  final bool select;
  const EspecialidadeAreasPage({
    super.key,
    this.readOnly = true,
    this.select = false,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<EspecialidadeAreasPage> {

  EspecialidadesProvider _provider = EspecialidadesProvider.i;

  bool get select => widget.select;

  bool get readOnly => widget.readOnly;
  bool _inProgress = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    _provider = context.watch<EspecialidadesProvider>();
    final list = _provider.areas;
    list.sort((a, b) => a.nome.compareTo(b.nome));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Especialidades'),
        actions: [
          IconButton(
            tooltip: 'Pesquisar',
            onPressed: _onSearchTap,
            icon: const Icon(Icons.search),
          ),

          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.separated(
          itemCount: list.length,
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 20),
          itemBuilder: (context, i) {
            final item = list[i];
            final espCout = _provider.getAllByType(item.nome).length;

            return EspecialidadeAreaTile(
              area: item,
              espCout: espCout,
              onTap: _onItemTap,
            );
          },
          separatorBuilder: (context, i) => const SizedBox(height: 5),
        ),
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Future<void> _init() async {
    if (InternetProvider.i.disconnected) {
      _inProgress = false;
      return _setState();
    }

    await _provider.loadOnline();
    _inProgress = false;
    _setState();
  }

  Future<void> _onRefresh() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    try {
      await _provider.refresh();
    } catch(e) {
      Log.snack(e.toString(), isError: true);
    }
  }


  void _onItemTap(EspecialidadeArea value) async {
    if (select) {
      Navigator.pop(context, value);
      return;
    }

    Navigate.push(context, EspecialidadesPage(
      areatype: value.nome,
      readOnly: readOnly,
    ));
  }

  void _onSearchTap() async {
    final item = await showSearch(
      context: context,
      delegate: EspecialidadeDataSearch(),
    );

    if (item is! Map<String, Especialidade> || !mounted) return;

    Navigate.push(context, EspecialidadePage(especialidade: item.values.first));
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}

class EspecialidadeDataSearch extends SearchDelegate<Map<String, Especialidade>> {

  final bool showOnEmpty;
  final bool multiSelect;
  final List<String>? selecteds;

  final _provider = EspecialidadesProvider.i;

  EspecialidadeDataSearch({
    this.showOnEmpty = false,
    this.multiSelect = false,
    this.selecteds,
  }) {
    if (selecteds != null) _provider.setSelecteds(selecteds!);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
      if (multiSelect)
        ElevatedButton(
          onPressed: () {
            final Map<String, Especialidade> esps = {};
            _provider.data.forEach((key, value) {
              if (value.selected) {
                esps[key] = value;
              }
            });
            _provider.unselectAll();
            close(context, esps);
          },
          child: const Text('Concluir'),
        ),

      const SizedBox(width: 10),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        _provider.unselectAll();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildItens();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty && !showOnEmpty) return Container();
    return _buildItens();
  }

  Widget _buildItens() {
    final searchResults = _provider.query(query);

    return StatefulBuilder(
      builder: (context, setState) {
        return ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final item = searchResults[index];
            return EspecialidadeTile(
              key: ValueKey(item),
              especialidade: item,
              onTap: (value) {
                if (multiSelect) {
                  item.selected = !item.selected;
                  setState(() {});
                } else {
                  close(context, {item.id: item});
                }
              },
              trailing: !multiSelect ? null : Checkbox(
                value: item.selected,
                onChanged: (value) {
                  item.selected = value!;
                  setState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }
}