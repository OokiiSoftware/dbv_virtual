import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

// @Deprecated('Use FaltasPage2')
// class FaltasPage extends PageBaseList {
//   const FaltasPage({super.key});
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// // ignore: deprecated_member_use_from_same_package
// class _State extends PageBaseListState<FaltasPage, Membro, FaltasProvider> {
//
//   @override
//   String get title => 'Falta';
//
//   @override
//   List<Membro> get items {
//     final list = context.watch<MembrosProvider>().list;
//     list.removeWhere((e) => !provider.data.containsKey(e.id));
//     list.sort((a, b) => a.nomeUsuario.toLowerCase().compareTo(b.nomeUsuario.toLowerCase()));
//     return list;
//   }
//
//   @override
//   bool get showDate => true;
//
//   @override
//   Widget itemBuilder(Membro value) {
//     return MembroTile(
//       key: ValueKey(value),
//       membro: value,
//       faltas: provider.data[value.id]!.length,
//       onTap: onItemTap,
//     );
//   }
//
//   @override
//   void onItemTap(Membro membro) {
//     Navigate.push(context, FaltasMembroPage(membro: membro));
//   }
//
//   @override
//   void onAddTap() async {
//     // ignore: deprecated_member_use_from_same_package
//     final res = await Navigate.push(context, const MembrosPage(select: true));
//     if (res is! Membro) return;
//
//     // ignore: use_build_context_synchronously
//     Navigate.push(context, FaltaPage(model2: res, model1: Falta()));
//   }
//
// }

class FaltasPage2 extends StatefulWidget {
  const FaltasPage2({super.key});

  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends StateListPage<FaltasPage2> {

  static int currentData = DateTime.now().year;

  FaltasProvider provider = FaltasProvider.i;

  @override
  String get title => 'Falta';

  List<Membro> get items {
    final list = context.watch<MembrosProvider>().list;
    list.removeWhere((e) => !provider.data.containsKey(e.id));
    list.sort((a, b) => a.nomeUsuario.toLowerCase().compareTo(b.nomeUsuario.toLowerCase()));
    return list;
  }

  @override
  Widget builder() {
    provider = context.watch<FaltasProvider>();
    return ListView.separated(
      itemCount: items.length,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 70),
      itemBuilder: (_, i) => itemBuilder(items[i]),
      separatorBuilder: (_, i) => const SizedBox(height: 5),
    );
  }

  @override
  Widget upBuilder() {
    return AnoCorrenteDropDown(
      value: currentData,
      items: provider.anosList,
      onChanged: _onDataChanged,
    );
  }

  @override
  Widget? actionButton() {
    if (!loaded) return const CircularProgressIndicator();

    if (readOnly) return null;

    return FloatingActionButton.extended(
      onPressed: onAddTap,
      label: Text('Add $title'),
    );
  }

  @override
  Future<void> fufureVoid() async {
    await provider.loadOnline(currentData);
  }


  Widget itemBuilder(Membro value) {
    return MembroTile(
      key: ValueKey(value),
      membro: value,
      faltas: provider.data[value.id]!.length,
      onTap: onItemTap,
    );
  }

  void onItemTap(Membro membro) {
    Navigate.push(context, FaltasMembroPage(membro: membro));
  }

  void onAddTap() async {
    final res = await Navigate.push(context, const MembrosPage2(select: true));
    if (res is! Membro) return;

    // ignore: use_build_context_synchronously
    Navigate.push(context, FaltaPage2(
      membro: res,
      falta: Falta(),
    ));
  }

  void _onDataChanged(int? value) {
    if (currentData != value) {
      currentData = value!;
      future = context.read<FaltasProvider>().refresh(currentData);
      setState(() {});
    }
  }

}