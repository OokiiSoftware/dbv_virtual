import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../page/page.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class TesourariaContaPage extends StatefulWidget {
  final bool isReceita;
  final PagamentoSgc pagamento;
  const TesourariaContaPage({
    super.key,
    required this.isReceita,
    required this.pagamento,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<TesourariaContaPage> {
  final _log = const Log('TesourariaContaPage');

  bool get isReceita => widget.isReceita;
  late PagamentoSgc pagamento = widget.pagamento;

  bool get isNovo => pagamento.codPagtoConta == 0;

  final _membros = <Membro>[];

  late final dtVencimentoController = MaskedTextController(
    mask: Masks.date,
    text: pagamento.dtVencimento,
  );
  late final dtPagamentoController = MaskedTextController(
    mask: Masks.date,
    text: pagamento.dtPagto,
  );
  late final valorController = MoneyMaskedTextController(
    initialValue: pagamento.valor,
  );

  final _formKey = GlobalKey<FormState>();

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
        title: Text('${isNovo ? 'Nova ' : ''}${isReceita ? 'Receita' : 'Dispensa'}'),
        actions: [
          if (!isNovo)
            IconButton(
              tooltip: 'Remover',
              onPressed: _onRemoveTap,
              icon: const Icon(Icons.delete_forever),
            ),

          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          Widget? membroWidget;
          final membro = MembrosProvider.i.data['_${pagamento.codMembro}'];
          if (membro != null) {
            membroWidget = Padding(
              padding: const EdgeInsets.all(5),
              child: MembroTile(
                key: ValueKey(membro),
                membro: membro,
              ),
            );
          } else if (pagamento.nomeMembro.isNotEmpty) {
            membroWidget = Padding(
              padding: const EdgeInsets.all(5),
              child: MembroTile(
                key: ValueKey(membro),
                membro: Membro(
                  nomeUsuario: pagamento.nomeMembro,
                ),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              children: [
                if (membroWidget != null)
                  membroWidget
                else
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onAddMembroTap,
                      child: Text('Selecionar membros (${_membros.length})'),
                    ),
                  ),

                DropdownButtonFormField(
                  value: pagamento.codConta,
                  hint: const Text('Selecione'),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Conta',
                  ),
                  items: Arrays.tipoConta.keys.map((key) => DropdownMenuItem(
                    value: key,
                    child: Text(Arrays.tipoConta[key]!),
                  )).toList(),
                  onChanged: (int? value) => pagamento.codConta = value!,
                  validator: Validators.dropDownIntObrigatorio,
                  onSaved: (value) => pagamento.codConta = value!,
                ),  // tipo conta

                TextFormField(
                  controller: dtVencimentoController,
                  decoration: InputDecoration(
                    labelText: 'Data de vencimento',
                    suffixIcon: IconButton(
                      onPressed: () => _onDataTap(dtVencimentoController),
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  validator: Validators.dataObrigatorio,
                  onSaved: (value) => pagamento.dtVencimento = value!,
                ),  // dt vencimento
                TextFormField(
                  controller: dtPagamentoController,
                  decoration: InputDecoration(
                    labelText: 'Data de pagamento',
                    suffixIcon: IconButton(
                      onPressed: () => _onDataTap(dtPagamentoController),
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  validator: Validators.data,
                  onSaved: (value) => pagamento.dtPagto = value!,
                ),  // dt pagamento
                TextFormField(
                  initialValue: pagamento.descricao,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                  ),
                  validator: Validators.obrigatorio,
                  onSaved: (value) => pagamento.descricao = value!,
                ),  // descrição
                TextFormField(
                  controller: valorController,
                  decoration: const InputDecoration(
                      labelText: 'Valor',
                      prefixText: 'R\$ '
                  ),
                  validator: (value) {
                    if (valorController.numberValue == 0) {
                      return 'Informe o valor';
                    }

                    return null;
                  },
                  onSaved: (value) => pagamento.valor = valorController.numberValue,
                ),  // valor
                TextFormField(
                  maxLines: 3,
                  initialValue: pagamento.obs,
                  decoration: const InputDecoration(
                    labelText: 'Observação',
                  ),
                  onSaved: (value) => pagamento.obs = value!,
                ),  // obs

                Container(
                  height: 50,
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: _onSaveTap,
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Future<void> _init() async {
    if (isNovo) return;

    pagamento = await SgcProvider.i.getConta(pagamento);
  }

  void _onSaveTap() async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    // if (_membros.isEmpty && pagamento.codMembro == null) {
    //   Log.snack('Selecone os membros', isError: true);
    //   return;
    // }

    pagamento.dtCadastro = Formats.dataUs(DateTime.now());
    pagamento.codUsuario = FirebaseProvider.i.user.codUsuario;
    pagamento.codClube = ClubeProvider.i.clube.codigo;
    pagamento.codTipoPagto = isReceita ? 2 : 1;

    List<String> body = [];

    _setInProgress(true);
    try {
      await SgcProvider.i.enviarConta(pagamento, isReceita, _membros, body);

      if (mounted) {
        Navigator.pop(context, true);
        Log.snack('Dados salvos');
      }
    } catch(e) {
      Log.snack('Erro ao realizar operação', isError: true);
      _log.e('_onSaveTap', 'isReceita', isReceita, e);
    }
    _setInProgress(false);
  }

  void _onRemoveTap() async {
    if (!await Popup(context).delete()) return;

    _setInProgress(true);
    try {
      await SgcProvider.i.removeConta(pagamento.codPagtoConta);

      if (mounted) {
        Navigator.pop(context, false);
        Log.snack('Dados removidos');
      }
    } catch(e) {
      Log.snack('Erro ao realizar ação', isError: true);
      _log.e('_onRemoveTap', e);
    }
    _setInProgress(false);
  }

  void _onAddMembroTap() async {
    final res = await Navigate.push(context, const MembrosPage2(multselect: true));
    if (res is! List<Membro>) return;

    _membros.clear();
    _membros.addAll(res);
    _setState();
  }

  void _onDataTap(MaskedTextController controller) async {
    final ano = DateTime.now().year + 5;
    final res = await Popup(context).dateTime(controller.text, max: '31/12/$ano');
    if (res == null) return;

    controller.text = Formats.data(res);
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