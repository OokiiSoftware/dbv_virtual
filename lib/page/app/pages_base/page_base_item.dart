import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

// @Deprecated('Use StateItem')
// abstract class PageBaseItem extends StatefulWidget {
//   final ItemModel model1;
//   final ItemModel? model2;
//   final bool readOnly;
//   const PageBaseItem({
//     super.key,
//     required this.model1,
//     this.model2,
//     this.readOnly = false,
//   });
//
//   @override
//   State<StatefulWidget> createState();
// }
// @Deprecated('Use StateItem')
// abstract class PageBaseItemState<S extends PageBaseItem,
// M1 extends ItemModel, M2 extends ItemModel, P extends ProviderBase> extends State<S> {
//
//   M1 get model1 => widget.model1 as M1;
//   M2? get model2 => widget.model2 as M2?;
//   bool get readOnly => widget.readOnly;
//   bool get showWarningDate => false;
//   bool get showSaveButton => true;
//   bool get showDeleteButton => true;
//
//   late P provider;
//
//   bool get isNovo => model1.id.isEmpty;
//
//   final formKey = GlobalKey<FormState>();
//
//   bool _inProgress = false;
//
//   String get title;
//
//   @override
//   Widget build(BuildContext context) {
//     provider = context.read<P>();
//     bool meuPerfil = context.watch<FirebaseProvider>().user.id == model1.id;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${isNovo ? 'Adicionar' : ''} $title'),
//         actions: [
//           if (!isNovo && !readOnly && !meuPerfil && showDeleteButton)
//             IconButton(
//               onPressed: onRemoveTap,
//               tooltip: 'Remover $title',
//               icon: const Icon(Icons.delete_forever),
//             ),
//
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         child: Form(
//           key: formKey,
//           child: Column(
//             children: [
//               ...formContent,
//               if (!readOnly && showSaveButton)...[
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: onSaveTap,
//                     child: const Text('Salvar'),
//                   ),
//                 ),
//
//                 if (showWarningDate)
//                   const AvisoDataNaoPodeSerAltera(),
//
//                 const SizedBox(height: 20),
//               ],
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
//     );
//   }
//
//   List<Widget> get formContent;
//
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
//     provider.add(model1, model2?.id).then((value) {
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
//   Future<bool> onSave() async => true;
//
//   void onRemove() {}
//
//   void onRemoveTap() async {
//     if (InternetProvider.i.disconnected) {
//       InternetProvider.showMsgNoConnect();
//       return;
//     }
//
//     if (!await Popup(context).delete()) return;
//
//     onRemove();
//
//     setInProgress(true);
//
//     provider.remove(model1, model2?.id).then((value) {
//       Navigator.pop(context);
//       Log.snack('Dados removidos');
//     }).catchError((e) {
//       Log.snack(e.toString(), isError: true);
//       setInProgress(false);
//     });
//   }
//
//   void setInProgress(bool b) {
//     _inProgress = b;
//     _setState();
//   }
//
//   void _setState() {
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
// }

abstract class StateItem<S extends StatefulWidget> extends State<S> {

  final formKey = GlobalKey<FormState>();

  bool get readOnly => FirebaseProvider.i.readOnly;

  bool inProgress = false;

  String get title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...appBarButtons(),

          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 20),
        child: Form(
          key: formKey,
          child: Column(
            children: formContent,
          ),
        ),
      ),
      floatingActionButton: actionButton(),
    );
  }

  Widget? actionButton() {
    if (inProgress) {
      return const CircularProgressIndicator();
    }

    return null;
  }

  List<Widget> appBarButtons() => [];

  List<Widget> get formContent;

  void onSaveTap();

  void onRemoveTap();

  void setInProgress(bool b) {
    inProgress = b;
    _setState();
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }

}