import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

// @Deprecated('Use MembrosPage2')
// class MembrosPage extends PageBaseList {
//   const MembrosPage({
//     super.key,
//     super.select,
//     super.multselect,
//   });
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// // ignore: deprecated_member_use_from_same_package
// class _State extends PageBaseListState<MembrosPage, Membro, MembrosProvider> {
//
//   @override
//   String get title => 'Membro';
//
//   @override
//   bool get showSearch => true;
//
//   @override
//   bool get canChangeLisMode => true;
//
//   @override
//   bool get showActionButton => false;
//
//   @override
//   List<Membro> get items {
//     List<Membro> list;
//     if (cPesquisa.text.isEmpty) {
//       list = provider.list;
//     } else {
//       list = provider.query(cPesquisa.text);
//     }
//     list.sort((a, b) => a.nomeUsuario.toLowerCase().compareTo(b.nomeUsuario.toLowerCase()));
//
//     return list;
//   }
//
//   @override
//   Widget itemBuilder(Membro value) {
//     if (VariaveisGlobais.listMode || multselect) {
//       return MembroTile(
//         key: ValueKey(value),
//         membro: value,
//         onTap: multselect ? (value) => _onMembroSelectedChanged(value, !value.selected) : onItemTap,
//         trailing: multselect ? Checkbox(
//           value: value.selected,
//           onChanged: (v) => _onMembroSelectedChanged(value, v),
//         ) : null,
//       );
//     }
//     return MembroTileGrid(
//       key: ValueKey(value),
//       membro: value,
//       onTap: onItemTap,
//     );
//   }
//
//   @override
//   void onItemTap(Membro membro) {
//     if (select) {
//       Navigator.pop(context, membro);
//       return;
//     }
//
//     Navigate.push(context, MembroPage(
//       model1: membro.copy(),
//       readOnly: FirebaseProvider.i.readOnly,
//     ));
//   }
//
//   @override
//   void onAddTap() {
//
//   }
//
//   @override
//   void returnMultSelect() {
//     Navigator.pop(context, items.where((e) => e.selected).toList());
//   }
//
//   void _onMembroSelectedChanged(Membro membro, bool? value) {
//     membro.selected = value!;
//     setState(() {});
//   }
//
// }

class MembrosPage2 extends StatefulWidget {
  /// Se 'true' ao clicar em um item da lista, esse item é retornado com pop()
  final bool select;
  final bool multselect;
  const MembrosPage2({
    super.key,
    this.select = false,
    this.multselect = false,
  });

  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends StateListPage<MembrosPage2> {

  bool get multselect => widget.multselect;
  bool get select => widget.select;

  MembrosProvider provider = MembrosProvider.i;

  final cPesquisa = TextEditingController();

  @override
  String get title => 'Membro';

  List<Membro> get items {
    List<Membro> list;
    if (cPesquisa.text.isEmpty) {
      list = provider.list;
    } else {
      list = provider.query(cPesquisa.text);
    }
    list.sort((a, b) => a.nomeUsuario.toLowerCase().compareTo(b.nomeUsuario.toLowerCase()));

    return list;
  }

  @override
  Widget builder() {
    provider = context.watch<MembrosProvider>();
    if (VariaveisGlobais.listMode || multselect) {
      return ListView.separated(
        itemCount: items.length,
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 70),
        itemBuilder: (_, i) => itemBuilder(items[i]),
        separatorBuilder: (_, i) => const SizedBox(height: 5),
      );
    }

    final pageWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = pageWidth ~/ 150;

    return GridView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 70),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1/1.5,
      ),
      itemBuilder: (_, i) => itemBuilder(items[i]),
    );
  }

  @override
  Widget upBuilder() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: cPesquisa,
              decoration: InputDecoration(
                labelText: 'PESQUISAR',
                hintText: 'Nome ou cargo',
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                constraints: const BoxConstraints(
                  maxHeight: 35,
                ),
              ),
              onChanged: _onPesquisaChanged,
            ),
          ),

          if (!multselect)
            IconButton(
              tooltip: 'Visualização',
              onPressed: _onModeListTap,
              icon: Icon(VariaveisGlobais.listMode ? Icons.list : Icons.grid_view),
            ),
        ],
      ),
    );
  }

  @override
  Future<void> fufureVoid() async {
    await provider.loadOnline();
  }


  Widget itemBuilder(Membro value) {
    if (VariaveisGlobais.listMode || multselect) {
      return MembroTile(
        key: ValueKey(value),
        membro: value,
        onTap: multselect ? (value) => _onMembroSelectedChanged(value, !value.selected) : onItemTap,
        trailing: multselect ? Checkbox(
          value: value.selected,
          onChanged: (v) => _onMembroSelectedChanged(value, v),
        ) : null,
      );
    }
    return MembroTileGrid(
      key: ValueKey(value),
      membro: value,
      onTap: onItemTap,
    );
  }

  @override
  Widget? actionButton() {
    if (!loaded) return const CircularProgressIndicator();

    if (multselect) {
      return FloatingActionButton.extended(
        onPressed: _returnMultSelect,
        label: const Text('Ok'),
      );
    }

    return null;
  }


  void onItemTap(Membro membro) {
    if (select) {
      Navigator.pop(context, membro);
      return;
    }

    Navigate.push(context, MembroPage2(
      membro: membro.copy(),
      readOnly: FirebaseProvider.i.readOnly,
    ));
  }

  void _onMembroSelectedChanged(Membro membro, bool? value) {
    membro.selected = value!;
    setState(() {});
  }


  void _returnMultSelect() {
    Navigator.pop(context, items.where((e) => e.selected).toList());
  }

  void _onPesquisaChanged(String value) {
    setState(() {});
  }

  void _onModeListTap() {
    VariaveisGlobais.listMode = !VariaveisGlobais.listMode;
    pref.setBool(PrefKey.listMode, VariaveisGlobais.listMode);
    setState(() {});
  }

}