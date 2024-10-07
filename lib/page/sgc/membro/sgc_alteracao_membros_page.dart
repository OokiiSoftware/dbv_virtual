import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../service/firebase/firebase_database.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class SgcAlteracaoMembrosPage extends StatefulWidget {
  const SgcAlteracaoMembrosPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcAlteracaoMembrosPage> {

  final _log = const Log('AlteracaoMembrosPage');

  late EditMembrosProvider _editProvider = EditMembrosProvider.i;
  late SgcProvider _sgcProvider = SgcProvider.i;

  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    _sgcProvider = context.watch<SgcProvider>();
    final membrosProvider = context.watch<MembrosProvider>();
    _editProvider = context.watch<EditMembrosProvider>();

    final membrosOld = membrosProvider.data;
    final membrosNew = _editProvider.data;

    List<DadosImport> data = membrosNew.values.toList().map((e) => DadosImport(
      membrosOld[e.id], e)).toList();

    Widget dataColumnLabel(String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(text),
        ),
      );
    }

    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Solicitações'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, i) {
          final item = data[i];
          final nome = item.nome;
          final foto = item.membroNew.fotoTemp;
          final alteracoes = item.dadosAlterados;

          return Card(
            child: ExpansionTile(
              title: Text(nome),
              subtitle: const Text('Dados com alteração',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              expandedAlignment: Alignment.topLeft,
              children: [
                if (alteracoes.isNotEmpty)...[
                  SfDataGrid(
                    columnWidthMode: ColumnWidthMode.fitByCellValue,
                    columns: [
                      GridColumn(
                        columnName: 'dados',
                        label: dataColumnLabel('Key'),
                      ),
                      GridColumn(
                        columnName: 'atual',
                        label: dataColumnLabel('Atual'),
                      ),
                      GridColumn(
                        columnName: 'novo',
                        label: dataColumnLabel('Novo'),
                      ),
                    ],
                    source: _DataGridSource(alteracoes),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onRejectTap(item.membroNew),
                          child: const Text('Rejeitar dados'),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onConfirmTap(item.membroNew),
                          child: const Text('Confirmar dados'),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],

                if (foto != null)...[
                  FotoLayout(
                    key: ValueKey(item),
                    path: foto,
                    borderRadius: 0,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onNovaFotoTap(item, false),
                          child: const Text('Rejeitar Foto'),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onNovaFotoTap(item, true),
                          child: const Text('Aprovar Foto'),
                        ),
                      ),
                    ],
                  ),
                ],

              ],
            ),
          );
        },
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  void _onConfirmTap(Membro value) async {
    final res = await DialogBox(
      context: context,
      title: 'Confirmar',
      content: const [
        Text('Deseja salvar esses dados no SGC?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    try {
      final membro = _sgcProvider.membrosData[value.codUsuario];
      if (membro == null) return;

      final codAutor = FirebaseProvider.i.user.codUsuario;

      int codClube = ClubeProvider.i.clube.codigo;
      if (codClube == 0) {
        codClube = await SgcProvider.i.getCodClube();
        if (codClube == 0) throw 'clubeCod == null';

        ClubeProvider.i.setCodigo(codClube);
      }

      String? nomeTemp;
      String? cpfTemp;
      if (membro.nomeUsuario != value.nomeUsuario) {
        nomeTemp = membro.nomeUsuario;
      }
      if (membro.cpf != value.cpf) {
        cpfTemp = membro.cpf;
      }

      Map<String, dynamic> bodyDados = {
        'cod_clube': '$codClube',
        'dt_cadastro': Formats.dataHoraUs(DateTime.now()),
        'cod_autor': codAutor,
        'tel_usuario': '',
        'cod_idioma': '1',
        'seguro': '1',
        'acesso': 'S',
        'Submit': 'Salvar',
        if (nomeTemp != null)
          'nome_usuario1': nomeTemp,
        if (cpfTemp != null)
          'cpf1': cpfTemp,
        'MM_update': 'form1',
      };
      Map<String, dynamic> bodyFicha = {
        'cod_autor': codAutor,
        'Submit': 'Confirmar',
        'MM_update': 'form1',
      };
      await _sgcProvider.enviarMembro(value, bodyDados, ficha: value.fichaMedica, bodyFicha: bodyFicha);
      await MembrosProvider.i.add(value);
      await _editProvider.remove(value);

      Log.snack('Dados atualizados');
    } catch(e) {
      Log.snack('Erro ao realizar ação', isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
      _log.e('_onConfirmTap', e);
    }

    _setInProgress(false);
  }

  void _onRejectTap(Membro value) async {
    final res = await DialogBox(
      context: context,
      title: 'Rejeitar',
      content: const [
        Text('Deseja rejeitar as novas informações desse membro?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    if (await _deleteDados(value)) {
      Log.snack('Dados rejeitados');
    }

    _setInProgress(false);
  }

  void _onNovaFotoTap(DadosImport value, bool aprovar) async {
    /*final res = await DialogBox(
      context: context,
      contentPadding: EdgeInsets.zero,
      negativeButtonText: 'Rejeitar',
      positiveButtonText: 'Aceitar',
      content: [
        FotoLayout(
          path: url,
          borderRadius: 0,
        ),
      ],
    ).simNao();
    if (res.isNone) return;*/

    _setInProgress(true);

    try {
      final membro = value.membroNew;
      /// enviar ao SGC
      if (aprovar) {
        final dio = Dio();

        final dioRes = await dio.get(membro.fotoTemp!,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ),
        );

        final body = <String, String>{
          'cod_usuario': '${membro.codUsuario}',
          'dt_cadastro': Formats.dataUs(DateTime.now()),
          'Submit': 'Salvar',
        };

        await SgcProvider.i.enviarFoto(membro.codUsuario, await dioRes.data, body);
        await FastCachedImageConfig.deleteCachedImage(imageUrl: membro.foto);
      }

      await FirebaseProvider.i.deleteFile([
        ChildKeys.clubes,
        FirebaseProvider.i.clubeId,
        ChildKeys.images,
        '${membro.codUsuario}.jpg'
      ]);

      await FirebaseProvider.i.database
          .child(ChildKeys.clubes)
          .child(FirebaseProvider.i.clubeId)
          .child('membros_editados')
          .child(membro.id)
          .child('fotoTemp')
          .delete();

      membro.fotoTemp = null;

      if (value.dadosAlterados.isEmpty) {
        await _deleteDados(value.membroNew);
      }
      Log.snack('Ação efetuada');
    } catch(e) {
      _log.e('_onNovaFotoTap', e);
      Log.snack('Erro ao realizar operação', isError: true);
    }

    _setInProgress(false);
  }

  Future<bool> _deleteDados(Membro value) async {
    try {
      await _editProvider.remove(value);
      return true;
    } catch(e) {
      Log.snack('Erro ao realizar ação', isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
      _log.e('_deleteDados', e);
      return false;
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

class _DataGridSource extends DataGridSource {
  final List<List<dynamic>> dados;
  _DataGridSource(this.dados);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final cells = row.getCells();

    Widget container(DataGridCell cell) {
      bool isInt = cell.value is int;
      var text = cell.value?.toString() ?? '';

      return Container(
        padding: const EdgeInsets.all(8),
        alignment: isInt ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return DataGridRowAdapter(
      color: Colors.white,
      cells: [
        for(int i = 0; i < 3; i++)
          container(cells[i]),
      ],
    );
  }

  @override
  List<DataGridRow> get rows => dados.map((e) {
    var atual = e[1].toString();
    var novo = e[2].toString();
    if (atual.isEmpty || atual == 'null') atual = '      ';
    if (novo.isEmpty || atual == 'null') novo = '      ';

    return DataGridRow(
      cells: [
        DataGridCell(
          columnName: 'dados',
          value: e[0],
        ),
        DataGridCell(
          columnName: 'atual',
          value: atual,
        ),
        DataGridCell(
          columnName: 'novo',
          value: novo,
        ),
      ],
    );
  }).toList();

}

class DadosImport {

  int get codigo => values['cod_usuario'];
  String get nome => values['nome_usuario'];

  final Membro? membroOld;
  final Membro membroNew;

  List<List<dynamic>> get dadosAlterados {
    return membroOld?.verificarAlteracao(values) ?? [];
  }

  Map<String, dynamic> get values => membroNew.toJson();

  DadosImport(this.membroOld, this.membroNew);

}