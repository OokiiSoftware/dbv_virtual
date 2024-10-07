import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

// class PagamentoTaxaPage extends PageBaseItem {
//   const PagamentoTaxaPage({
//     super.key,
//     required super.model1,
//     required super.model2,
//     super.readOnly,
//   });
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// class _State extends PageBaseItemState<PagamentoTaxaPage, Pagamento, Membro, PagamentosTaxaProvider> {
//
//   @override
//   String get title => 'Pagamento';
//
//   @override
//   bool get isNovo => model1.valor == 0;
//
//   @override
//   bool get showWarningDate => true;
//
//   late MoneyMaskedTextController taxaMensaoController = MoneyMaskedTextController(
//     initialValue: model1.valor,
//   );
//
//   @override
//   List<Widget> get formContent {
//     // final hoje = DateTime.now();
//     // var initialDate = hoje;
//     // if (!isNovo) {
//     //   initialDate = DateTime.fromMillisecondsSinceEpoch(model1.data);
//     // }
//
//     return [
//       MembroTile(
//         membro: model2!,
//         enabled: false,
//       ),
//
//       const SizedBox(height: 15),
//
//       Text('Pagamento de ${model1.mes}',
//         style: const TextStyle(
//           fontSize: 20,
//         ),
//       ),  // mes
//
//       TextFormField(
//         initialValue: model1.observacao,
//         readOnly: readOnly,
//         keyboardType: TextInputType.text,
//         decoration: const InputDecoration(
//           labelText: 'Observaçao',
//         ),
//         onSaved: (value) => model1.observacao = value!,
//       ),  // observacao
//
//       TextFormField(
//         controller: taxaMensaoController,
//         readOnly: readOnly,
//         keyboardType: TextInputType.number,
//         decoration: const InputDecoration(
//           labelText: 'Valor',
//           prefixText: 'R\$ '
//         ),
//         onSaved: (value) => model1.valor = taxaMensaoController.numberValue,
//       ),  // valor
//
//       const SizedBox(height: 10),
//
//       /// todo
//       // AbsorbPointer(
//       //   absorbing: !isNovo || readOnly,
//       //   child: CalendarDatePicker(
//       //     initialDate: initialDate,
//       //     firstDate: DateTime(hoje.year),
//       //     lastDate: hoje,
//       //     onDateChanged: (DateTime value) {
//       //       model1.data = value.millisecondsSinceEpoch;
//       //     },
//       //   ),
//       // ),
//     ];
//   }
//
//
//   @override
//   void onSaveTap() async {
//     if (InternetProvider.i.disconnected) {
//       InternetProvider.showMsgNoConnect();
//       return;
//     }
//
//     final form = formKey.currentState!;
//     if (!form.validate()) return;
//     form.save();
//
//     if (!await onSave()) return;
//
//     setInProgress(true);
//
//     provider.addPagamento(model1, model2!.id).then((value) {
//       Navigator.pop(context);
//       Log.snack('Dados salvos');
//     }).catchError((e) {
//       Log.snack('Erro ao salvar os dados', isError: true, actionClick: () {
//         Popup(context).errorDetalhes(e);
//       });
//       setInProgress(false);
//     });
//   }
//
//   @override
//   void onRemoveTap() async {
//     if (!await Popup(context).delete()) return;
//
//     setInProgress(true);
//
//     provider.removePagamento(model1, model2!.id).then((value) {
//       Navigator.pop(context);
//       Log.snack('Dados removidos');
//     }).catchError((e) {
//       Log.snack(e.toString(), isError: true);
//       setInProgress(false);
//     });
//   }
// }

class PagamentoPage2 extends StatefulWidget {
  final Pagamento pagamento;
  final Membro membro;
  final bool readOnly;
  const PagamentoPage2({
    super.key,
    required this.pagamento,
    required this.membro,
    this.readOnly = true,
  });

  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends StateItem<PagamentoPage2> {

  Pagamento get pagamento => widget.pagamento;
  Membro get membro => widget.membro;
  bool get readOnly => widget.readOnly;

  bool get isNovo => pagamento.valor == 0;
  bool get meuPerfil => membro.id == FirebaseProvider.i.user.id;

  PagamentosTaxaProvider provider = PagamentosTaxaProvider.i;

  late MoneyMaskedTextController taxaMensaoController = MoneyMaskedTextController(
    initialValue: pagamento.valor,
  );

  @override
  String get title => 'Pagamento';

  @override
  List<Widget> get formContent {
    provider = context.watch<PagamentosTaxaProvider>();
    return [
      MembroTile(
        key: ValueKey(membro),
        membro: membro,
        enabled: false,
      ),

      const SizedBox(height: 15),

      Text('Pagamento de ${pagamento.mes}',
        style: const TextStyle(
          fontSize: 20,
        ),
      ),  // mes

      TextFormField(
        initialValue: pagamento.observacao,
        readOnly: readOnly,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Observaçao',
        ),
        onSaved: (value) => pagamento.observacao = value!,
      ),  // observacao

      TextFormField(
        controller: taxaMensaoController,
        readOnly: readOnly,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
            labelText: 'Valor',
            prefixText: 'R\$ '
        ),
        onSaved: (value) => pagamento.valor = taxaMensaoController.numberValue,
      ),  // valor

      const SizedBox(height: 10),

      if (!readOnly)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSaveTap,
            child: const Text('Salvar'),
          ),
        ),
    ];
  }

  @override
  void onSaveTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    final form = formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    setInProgress(true);

    provider.addPagamento(pagamento, membro.id).then((value) {
      Navigator.pop(context);
      Log.snack('Dados salvos');
    }).catchError((e) {
      Log.snack('Erro ao salvar os dados', isError: true, actionClick: () {
        Popup(context).errorDetalhes(e);
      });
      setInProgress(false);
    });
  }

  @override
  void onRemoveTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    if (!await Popup(context).delete()) return;

    setInProgress(true);

    provider.removePagamento(pagamento, membro.id).then((value) {
      Navigator.pop(context);
      Log.snack('Dados removidos');
    }).catchError((e) {
      Log.snack(e.toString(), isError: true);
      setInProgress(false);
    });
  }

}