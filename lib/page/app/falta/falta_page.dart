import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

// class FaltaPage extends PageBaseItem {
//   const FaltaPage({
//     super.key,
//     required super.model1,
//     required super.model2,
//     super.readOnly,
//   });
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// class _State extends PageBaseItemState<FaltaPage, Falta, Membro, FaltasProvider> {
//
//   @override
//   String get title => 'Falta';
//
//   @override
//   bool get showWarningDate => true;
//
//   @override
//   List<Widget> get formContent {
//     final hoje = DateTime.now();
//     var initialDate = hoje;
//     if (!isNovo) {
//       initialDate = DateTime.fromMillisecondsSinceEpoch(model1.data);
//     }
//
//     return [
//       MembroTile(
//         membro: model2!,
//         enabled: false,
//       ),
//
//       const SizedBox(height: 5),
//
//       TextFormField(
//         initialValue: model1.justificativa,
//         readOnly: readOnly,
//         keyboardType: TextInputType.text,
//         decoration: const InputDecoration(
//           labelText: 'Justificativa',
//         ),
//         onSaved: (value) => model1.justificativa = value!,
//       ),
//
//       AbsorbPointer(
//         absorbing: !isNovo || readOnly,
//         child: CalendarDatePicker(
//           initialDate: initialDate,
//           firstDate: DateTime(hoje.year),
//           lastDate: hoje,
//           onDateChanged: (DateTime value) {
//             model1.data = value.millisecondsSinceEpoch;
//           },
//         ),
//       ),
//     ];
//   }
//
//   @override
//   Future<bool> onSave() async {
//     if (model1.data == 0) {
//       model1.data = DateTime.now().millisecondsSinceEpoch;
//     }
//
//     return true;
//   }
//
// }

class FaltaPage2 extends StatefulWidget {
  final Falta falta;
  final Membro membro;
  const FaltaPage2({
    super.key,
    required this.falta,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends StateItem<FaltaPage2> {

  Falta get falta => widget.falta;
  Membro get membro => widget.membro;

  bool get isNovo => falta.id.isEmpty;
  bool get meuPerfil => membro.id == FirebaseProvider.i.user.id;

  FaltasProvider provider = FaltasProvider.i;

  @override
  String get title => 'Falta';

  @override
  List<Widget> get formContent {
    provider = context.watch<FaltasProvider>();
    final hoje = DateTime.now();
    var initialDate = hoje;
    if (!isNovo) {
      initialDate = DateTime.fromMillisecondsSinceEpoch(falta.data);
    }

    return [
      MembroTile(
        key: ValueKey(membro),
        membro: membro,
        enabled: false,
      ),

      const SizedBox(height: 5),

      TextFormField(
        initialValue: falta.justificativa,
        readOnly: readOnly,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Justificativa',
        ),
        onSaved: (value) => falta.justificativa = value!,
      ),

      AbsorbPointer(
        absorbing: !isNovo || readOnly,
        child: CalendarDatePicker(
          initialDate: initialDate,
          firstDate: DateTime(hoje.year),
          lastDate: hoje,
          onDateChanged: (DateTime value) {
            falta.data = value.millisecondsSinceEpoch;
          },
        ),
      ),

      if (!readOnly)...[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSaveTap,
            child: const Text('Salvar'),
          ),
        ),

        const AvisoDataNaoPodeSerAltera(),
      ],
    ];
  }

  @override
  List<Widget> appBarButtons() {
    return [
      if (!isNovo && !readOnly && !meuPerfil)
        IconButton(
          onPressed: onRemoveTap,
          tooltip: 'Remover $title',
          icon: const Icon(Icons.delete_forever),
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

    if (falta.data == 0) {
      falta.data = DateTime.now().millisecondsSinceEpoch;
    }

    setInProgress(true);

    provider.add(falta, membro.id).then((value) {
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

    provider.remove(falta, membro.id).then((value) {
      Navigator.pop(context);
      Log.snack('Dados removidos');
    }).catchError((e) {
      Log.snack(e.toString(), isError: true);
      setInProgress(false);
    });
  }

}