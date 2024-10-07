import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

class TesourariaListaPage extends StatefulWidget {
  final bool isReceita;
  const TesourariaListaPage({
    super.key,
    required this.isReceita,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<TesourariaListaPage> {

  final _log = const Log('TesourariaListaPage');

  static final DateTime _now = DateTime.now();
  static final _inicio = DateTime(_now.year, 1, 1);
  static final _fim = DateTime(_now.year, 12, 31);

  static final _cInicio = MaskedTextController(
    mask: Masks.date,
    text: Formats.data(_inicio),
  );
  static final _cFim = MaskedTextController(
    mask: Masks.date,
    text: Formats.data(_fim),
  );

  bool _inSelection = false;

  bool get isReceita => widget.isReceita;

  final Map<String, PagamentoSgc> _pagamentos = {};
  final List<PagamentoSgc> _pagamentosList = [];

  int _rowsPerPage = 20;
  int _currentPage = 1;
  int _sortIndex = 4;//static

  bool _inProgress = false;
  Future? _future;

  static Map<String, String>? _filterBody;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    _updateList();
    return RefreshIndicator(
      onRefresh: _init,
      child: Scaffold(
        appBar: SgcAppBar(
          title: Text(isReceita ? 'Receitas' : 'Dispensas'),
        ),
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final selectedsCount = _pagamentosList.where((e) => e.selected).length;
            bool allSelected = selectedsCount == _pagamentosList.length;

            Widget dataColumnLabel(String text) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(text),
                ),
              );
            }

            final dataSource = _DataGridSource(_pagamentosList.toList());

            double pageCount = (dataSource.rows.length / _rowsPerPage).ceil().toDouble();
            if (pageCount == 0) pageCount = 1;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black38, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilterChip(
                            label: Text(_inSelection ? 'Selecionando ($selectedsCount)' : 'Selecionar'),
                            showCheckmark: true,
                            selected: _inSelection,
                            selectedColor: Colors.orangeAccent,
                            onSelected: _switchSelection,
                          ),

                          const SizedBox(width: 5),

                          ElevatedButton.icon(
                            onPressed: _onPagamentoTap,
                            icon: const Icon(Icons.add),
                            label: const Text('Novo'),
                          ),  // novo
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (_inSelection)...[
                        Row(
                          children: [
                            Expanded(
                              child: ActionChip(
                                onPressed: _onPagoTap,
                                backgroundColor: Colors.greenAccent,
                                avatar: const Icon(Icons.check),
                                label: const Text('Marcar como Pago'),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ActionChip(
                                onPressed: _onDeleteTap,
                                backgroundColor: Colors.redAccent,
                                avatar: const Icon(Icons.clear),
                                label: const Text('Excluir Selecionados'),
                              ),
                            ),
                          ],
                        ),

                        CheckboxListTile(
                          title: Text(allSelected ? 'Desmarcar tudo' : 'Selecionar tudo'),
                          value: allSelected,
                          onChanged: _setSelected,
                        ),

                      ] else...[
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('Período'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _onDateMinTap,
                                child: Text(_cInicio.text),
                              ),
                            ),

                            const Text(' a '),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: _onDateMaxTap,
                                child: Text(_cFim.text),
                              ),
                            ),
                          ],
                        ),  // período

                        /*Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            const Text('Ordem por'),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                _sortAsc = !_sortAsc;
                                _setState();
                              },
                              icon: Icon(_sortAsc ? Icons.arrow_downward : Icons.arrow_upward),
                              label: Text(_sortAsc ? 'Asc' : 'Dsc'),
                            ),
                          ],
                        ),
                      ),*/  // asc, dsc

                        /*Center(
                        child: SegmentedButton<String>(
                          segments: _SortMethods.values.map(((e) => ButtonSegment(
                              value: e,
                              label: Text(e)
                          ))).toList(),
                          selected: {_sortValue},
                          showSelectedIcon: false,
                          onSelectionChanged: (value) {
                            _sortValue = value.first;
                            _setState();
                          },
                        ),
                      ),*/  // menu sort

                      ]
                    ],
                  ),
                ),  // topbar

                Expanded(
                  child: SfDataGrid(
                    allowFiltering: true,
                    rowsPerPage: _rowsPerPage,
                    columnWidthMode: ColumnWidthMode.fitByCellValue,
                    // selectionMode: _inSelection ? SelectionMode.multiple : SelectionMode.none,
                    columns: [
                      GridColumn(
                        visible: false,
                        columnName: 'id',
                        label: dataColumnLabel('id'),
                      ),
                      GridColumn(
                        visible: false,
                        columnName: 'selected',
                        label: dataColumnLabel('selected'),
                      ),
                      GridColumn(
                        columnName: 'status',
                        columnWidthMode: ColumnWidthMode.fitByColumnName,
                        label: dataColumnLabel('Status'),
                      ),
                      GridColumn(
                        allowFiltering: false,
                        columnName: 'descricao',
                        label: dataColumnLabel('Descrição'),
                      ),
                      GridColumn(
                        columnName: 'nomeMembro',
                        label: dataColumnLabel('Membro'),
                      ),
                      GridColumn(
                        allowFiltering: false,
                        columnName: 'valor',
                        label: dataColumnLabel('Valor'),
                      ),
                      GridColumn(
                        allowFiltering: false,
                        columnName: 'dtVencimento',
                        columnWidthMode: ColumnWidthMode.fitByColumnName,
                        label: dataColumnLabel('Vencimento'),
                      ),
                      GridColumn(
                        allowFiltering: false,
                        columnName: 'dtPagamento',
                        columnWidthMode: ColumnWidthMode.fitByColumnName,
                        label: dataColumnLabel('Pagamento'),
                      ),
                    ],
                    source: dataSource,
                    onCellTap: (details) {
                      final index = details.rowColumnIndex.rowIndex -1 + (_rowsPerPage * _currentPage);

                      if (index < 0 || index < (_rowsPerPage * _currentPage)) {
                        final cIndex = details.rowColumnIndex.columnIndex -2; // -2 para remover as colunas ocultas
                        _sortByColumIndex(cIndex);
                        _setState();
                        return;
                      }

                      final id = dataSource.effectiveRows[index].getCells()[0].value;

                      _onPagamentoTap(_pagamentos[id]);
                    },
                  ),
                ),  // datagrid

                Padding(
                  padding: const EdgeInsets.only(right: 50),
                  child: SfDataPager(
                    delegate: dataSource,
                    availableRowsPerPage: const <int>[20, 50, 100, 200],
                    pageCount: pageCount,
                    onPageNavigationEnd: (index) {
                      _currentPage = index;
                    },
                    onRowsPerPageChanged: _onRowsPerPageChanged,
                  ),
                ),  // datapage


                /*ListView.separated(
                  itemCount: pagamentos.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, i) => const Divider(),
                  itemBuilder: (context, i) {
                    final item = pagamentos[i];
                    final valor = Formats.formatarValorDecimal(item.valor, prefix: 'R\$ ');
                    String title = item.nomeMembro;
                    String desc = '$valor - ${item.descricao}';

                    if (title.isEmpty) {
                      title = item.descricao;
                      desc = valor;
                    }

                    Widget trailing;
                    if (_inSelection) {
                      trailing = Checkbox(
                        value: _selecteds.contains(item),
                        onChanged: (value) {
                          if (value!) {
                            _selecteds.add(item);
                          } else {
                            _selecteds.remove(item);
                          }
                          _setState();
                        },
                      );
                    } else {
                      trailing = Text(item.status);
                    }

                    return ListTile(
                      onTap: () => _onPagamentoTap(item),
                      title: Text(title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(desc),
                          Text(item.dtVencimento,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: trailing,
                    );
                  },
                ),*/
              ],
            );
          },
        ),
        floatingActionButton: _inProgress ? const CircularProgressIndicator() : null
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   crossAxisAlignment: CrossAxisAlignment.end,
        //   children: [
        //     FloatingActionButton.extended(
        //       heroTag: 'IUUYUGJHKJ',
        //       onPressed: _switchSelection,
        //       label: Text(_inSelection ? 'Cancelar' : 'Habilitar\nSeleção'),
        //     ),
        //
        //     const SizedBox(width: 5),
        //
        //     if (_inSelection)...[
        //       Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           FloatingActionButton.extended(
        //             heroTag: 'PKÇMHLUIHB',
        //             onPressed: _onPagoTap,
        //             label: const Text('Pago'),
        //           ),
        //
        //           const SizedBox(height: 5),
        //
        //           FloatingActionButton.extended(
        //             heroTag: 'GOIJLHYG',
        //             onPressed: _onDeleteTap,
        //             label: const Text('Excluir'),
        //           ),
        //         ],
        //       ),
        //     ] else...[
        //       FloatingActionButton.extended(
        //         heroTag: 'HUYTFTFCHVB',
        //         onPressed: _onPagamentoTap,
        //         label: const Text('Novo'),
        //       ),
        //     ],
        //   ],
        // ),
      ),
    );
  }

  Future<void> _init() async {
    final items = await SgcProvider.i.getContas(isReceita, body: _filterBody);
    _pagamentos.clear();
    _pagamentos.addAll(items);
    _updateList();
    _setState();
  }

  void _onPagamentoTap([PagamentoSgc? value]) async {
    if (_inSelection && value != null) {
      value.selected = !value.selected;
      _setState();
      return;
    }

    final res = await Navigate.push(context, TesourariaContaPage(
      isReceita: isReceita,
      pagamento: value?.copy() ?? PagamentoSgc(),
    ));
    if (res is! bool) return;

    if (res) {
      _setInProgress(true);
      await _init();
      _setInProgress(false);
    } else {
      _pagamentos.remove(value?.id);
      _setState();
    }

    _updateList();
  }

  void _onPagoTap() async {
    _actionAux(false);
  }

  void _onDeleteTap() async {
    if (! await Popup(context).delete()) return;

    _actionAux(true);
  }

  void _actionAux(bool delete) async {
    for (var value in _pagamentos.values) {
      if (value.selected) {
        value.dtPagto = Formats.data(DateTime.now());
      }
    }
    final codigos = _pagamentos.values.where((e) => e.selected).map((e) => e.codPagtoConta).toList();

    if(codigos.isEmpty) {
      Log.snack('Selecione uma ou mais contas', isError: true);
      return;
    }

    _setInProgress(true);

    try {
      await SgcProvider.i.setContasPagas(codigos, isReceita, delete);

      if (delete) {
        _pagamentos.removeWhere((k, e) => e.selected);
      }

      _updateList();
      _inSelection = false;
      Log.snack(delete ? 'Dados removidos' : 'Dados salvos');
    } catch(e) {
      Log.snack('Erro ao realizar operação', isError: true);
      _log.e('_onPagoTap', e);
    }

    _setInProgress(false);
  }

  void _switchSelection(bool value) {
    _inSelection = value;
    if (!value) {
      _setSelected(false);
    }
    _setState();
  }


  void _onDateMinTap() {
    _onDateTap(_cInicio, max: _cFim.text);
  }

  void _onDateMaxTap() {
    _onDateTap(_cFim, min: _cInicio.text, max: Formats.data(_fim));
  }

  void _onDateTap(MaskedTextController controller, {String? min, String? max}) async {
    final res = await Popup(context).dateTime(controller.text, min: min, max: max);
    if (res == null) return;

    controller.text = Formats.data(res);

    _filterBody = {
      'inicio': _cInicio.text,
      'fim': _cFim.text,
      'Submit': 'Filtrar dados',
      'conta': 'cp.cod_conta is not null',
      'membros': 'cp.cod_pagto_conta is not null',
      'status': 'cp.cod_pagto_conta is not null',
    };

    _setInProgress(true);
    await _init();
    _setInProgress(false);
  }

  void _updateList() {
    _pagamentosList.clear();
    _pagamentosList.addAll(_pagamentos.values.toList());
    _sortByColumIndex(_sortIndex);
  }

  void _sortByColumIndex(int index) {
    _sortIndex = index;
    int sort(PagamentoSgc a, PagamentoSgc b) {
      int byDate(String a, String b) {
        final ini = Formats.stringToDateTime(a);
        final fim = Formats.stringToDateTime(b);
        if (ini == null || fim == null) return 0;
        return ini.compareTo(fim);
      }

      switch(index) {
        case 0:
          return a.status.compareTo(b.status);
        case 1:
          return a.descricao.compareTo(b.descricao);
        case 2:
          return a.nomeMembro.compareTo(b.nomeMembro);
        case 3:
          return a.valor.compareTo(b.valor);
        case 4:
          return byDate(a.dtVencimento, b.dtVencimento);
        case 5:
          return byDate(a.dtPagto, b.dtPagto);
        default: return 0;
      }
    }

    _pagamentosList.sort(sort);
  }

  void _onRowsPerPageChanged(int? value) {
    _rowsPerPage = value ?? 10;
    _setState();
  }

  void _setSelected(bool? value) {
    for (var item in _pagamentosList) {
      item.selected = value!;
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

class _DataGridSource extends DataGridSource {
  final List<PagamentoSgc> dados;
  _DataGridSource(this.dados);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final cels = row.getCells();

    Alignment alignment(DataGridCell cell) {
      switch(cell.columnName) {
        case 'status':
        case 'dtVencimento':
        case 'dtPagamento':
          return Alignment.center;
        default: return Alignment.centerLeft;
      }
    }
    Color? color() {
      if (cels[1].value == 'true') {
        return Colors.grey;
      }

      switch(cels[2].value) {
        case 'Pago': return Colors.yellowAccent;
        case 'Não pago': return Colors.greenAccent;
        case 'Vencido': return Colors.redAccent;
      }
      return null;
    }

    return DataGridRowAdapter(
      color: color(),
      cells: [
        for(var item in cels)
          Align(
            alignment: alignment(item),
            child: Text(item.value),
          ),
      ],
    );
  }

  @override
  List<DataGridRow> get rows => dados.map((e) {
    return DataGridRow(
      cells: [
        DataGridCell(
          columnName: 'id',
          value: e.id,
        ),
        DataGridCell(
          columnName: 'selected',
          value: '${e.selected}',
        ),
        DataGridCell(
          columnName: 'status',
          value: e.status,
        ),
        DataGridCell(
          columnName: 'descricao',
          value: e.descricao,
        ),
        DataGridCell(
          columnName: 'nomeMembro',
          value: e.nomeMembro,
        ),
        DataGridCell(
          columnName: 'valor',
          value: Formats.formatarValorDecimal(e.valor, prefix: 'R\$ '),
        ),
        DataGridCell(
          columnName: 'dtVencimento',
          value: e.dtVencimento,
        ),
        DataGridCell(
          columnName: 'dtPagamento',
          value: e.dtPagto,
        ),
      ],
    );
  }).toList();

}