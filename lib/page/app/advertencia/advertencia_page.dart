import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../page/page.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';

// @Deprecated('Use AdvertenciaPage2')
// class AdvertenciaPage extends PageBaseItem {
//   const AdvertenciaPage({
//     super.key,
//     required super.model1,
//     required super.model2,
//     super.readOnly
//   });
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// // ignore: deprecated_member_use_from_same_package
// class _State extends PageBaseItemState<AdvertenciaPage, Advertencia, Membro, AdvertenciasProvider> {
//
//   @override
//   String get title => 'Advertência';
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
//         initialValue: model1.descricao,
//         readOnly: readOnly,
//         keyboardType: TextInputType.text,
//         decoration: const InputDecoration(
//           labelText: 'Descrição',
//         ),
//         validator: Validators.obrigatorio,
//         onSaved: (value) => model1.descricao = value!,
//       ),  // Descricao
//
//       TextFormField(
//         initialValue: model1.punicao,
//         readOnly: readOnly,
//         keyboardType: TextInputType.text,
//         decoration: const InputDecoration(
//           labelText: 'Punição',
//         ),
//         onSaved: (value) => model1.punicao = value!,
//       ),  // Punição
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
//     if (isNovo) {
//       model1.id = randomString();
//     }
//
//     if (model1.punicao.isEmpty) {
//       model1.punicao = 'Sem punição';
//     }
//
//     if (model1.data == 0) {
//       model1.data = DateTime.now().millisecondsSinceEpoch;
//     }
//
//     return true;
//   }
//
// }

class AdvertenciaPage2 extends StatefulWidget {
  final Advertencia advertencia;
  final Membro membro;
  const AdvertenciaPage2({
    super.key,
    required this.advertencia,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends StateItem<AdvertenciaPage2> {

  Advertencia get advertencia => widget.advertencia;
  Membro get membro => widget.membro;

  bool get isNovo => advertencia.id.isEmpty;
  bool get meuPerfil => membro.id == FirebaseProvider.i.user.id;

  AdvertenciasProvider provider = AdvertenciasProvider.i;

  @override
  String get title => 'Advertência';

  @override
  List<Widget> get formContent {
    provider = context.watch<AdvertenciasProvider>();
    final hoje = DateTime.now();
    var initialDate = hoje;
    if (!isNovo) {
      initialDate = DateTime.fromMillisecondsSinceEpoch(advertencia.data);
    }

    return [
      MembroTile(
        key: ValueKey(membro),
        membro: membro,
        enabled: false,
      ),

      const SizedBox(height: 5),

      TextFormField(
        initialValue: advertencia.descricao,
        readOnly: readOnly || !isNovo,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Descrição',
        ),
        validator: Validators.obrigatorio,
        onSaved: (value) => advertencia.descricao = value!,
      ),  // Descricao

      TextFormField(
        initialValue: advertencia.punicao,
        readOnly: readOnly || !isNovo,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Punição',
        ),
        onSaved: (value) => advertencia.punicao = value!,
      ),  // Punição

      AbsorbPointer(
        absorbing: !isNovo || readOnly,
        child: CalendarDatePicker(
          initialDate: initialDate,
          firstDate: DateTime(hoje.year),
          lastDate: hoje,
          onDateChanged: (DateTime value) {
            advertencia.data = value.millisecondsSinceEpoch;
          },
        ),
      ),

      if (isNovo)...[
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

    if (isNovo) {
      advertencia.id = randomString();
    }

    if (advertencia.punicao.isEmpty) {
      advertencia.punicao = 'Sem punição';
    }

    if (advertencia.data == 0) {
      advertencia.data = DateTime.now().millisecondsSinceEpoch;
    }

    setInProgress(true);

    provider.add(advertencia, membro.id).then((value) {
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

    provider.remove(advertencia, membro.id).then((value) {
      Navigator.pop(context);
      Log.snack('Dados removidos');
    }).catchError((e) {
      Log.snack(e.toString(), isError: true);
      setInProgress(false);
    });
  }

}