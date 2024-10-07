import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

// @Deprecated('Use StateListPage')
// abstract class PageBaseList extends StatefulWidget {
//   /// Se 'true' ao clicar em um item da lista, esse item é retornado com pop()
//   final bool select;
//   final bool multselect;
//   const PageBaseList({
//     super.key,
//     this.select = false,
//     this.multselect = false,
//   });
//
//   @override
//   State<StatefulWidget> createState();
// }
// @Deprecated('Use StateListPage')
// abstract class PageBaseListState<S extends PageBaseList, I, P extends ProviderBase> extends State<S> {
//
//   static int currentData = DateTime.now().year;
//
//   bool get multselect => widget.multselect;
//   bool get select => widget.select;
//
//   Future? future;
//
//   String get title;
//   String? get custonTitle => null;
//   String? get addButtonCustonText => null;
//
//   bool get showDate => false;
//   bool get showSearch => false;
//   bool get showActionButton => true;
//   bool get canChangeLisMode => false;
//
//   late P provider;
//
//   final cPesquisa = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     provider = context.read<P>();
//     future = _init();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     provider = context.watch<P>();
//
//     String getTitie() {
//       if (select) return 'Selecionar $title';
//       if (custonTitle != null) return custonTitle!;
//
//       return 'Relação de ${title}s';
//     }
//
//     final pageWidth = MediaQuery.of(context).size.width;
//     final crossAxisCount = pageWidth ~/ 150;
//
//     return RefreshIndicator(
//       onRefresh: _onRefresh,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(getTitie()),
//         ),
//         body: Column(
//           children: [
//             if (showSearch)
//               Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: cPesquisa,
//                         decoration: InputDecoration(
//                           labelText: 'PESQUISAR',
//                           hintText: 'Nome ou cargo',
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           constraints: const BoxConstraints(
//                             maxHeight: 35,
//                           ),
//                         ),
//                         onChanged: _onPesquisaChanged,
//                       ),
//                     ),
//
//                     if (canChangeLisMode && !multselect)
//                       IconButton(
//                         tooltip: 'Visualização',
//                         onPressed: _onModeListTap,
//                         icon: Icon(VariaveisGlobais.listMode ? Icons.list : Icons.grid_view),
//                       ),
//                   ],
//                 ),
//               ),
//
//             if (showDate)
//               AnoCorrenteDropDown(
//                 value: currentData,
//                 items: provider.anosList,
//                 onChanged: _onDataChanged,
//               ),
//
//             Expanded(
//               child: FutureBuilder(
//                 future: future,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState != ConnectionState.done) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   onBuilder();
//
//                   if (VariaveisGlobais.listMode || !canChangeLisMode || multselect) {
//                     return ListView.separated(
//                       itemCount: items.length,
//                       padding: const EdgeInsets.fromLTRB(5, 0, 5, 70),
//                       itemBuilder: (_, i) => itemBuilder(items[i]),
//                       separatorBuilder: (_, i) => const SizedBox(height: 5),
//                     );
//                   }
//
//                   return GridView.builder(
//                     itemCount: items.length,
//                     padding: const EdgeInsets.fromLTRB(5, 0, 5, 70),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: crossAxisCount,
//                       crossAxisSpacing: 2,
//                       mainAxisSpacing: 2,
//                       childAspectRatio: 1/1.5,
//                     ),
//                     itemBuilder: (_, i) => itemBuilder(items[i]),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: actionButton(),
//       ),
//     );
//   }
//
//   List<I> get items;
//
//   Widget itemBuilder(I value);
//
//   Widget? actionButton() {
//     if (multselect) {
//       return FloatingActionButton.extended(
//         onPressed: returnMultSelect,
//         label: const Text('Ok'),
//       );
//     }
//
//     if (!showActionButton) return null;
//     if (context.watch<FirebaseProvider>().readOnly) return null;
//
//     return FloatingActionButton.extended(
//       onPressed: onAddTap,
//       label: Text(addButtonCustonText ?? 'Add $title'),
//     );
//   }
//
//
//   Future<void> _init() async {
//     await Future.delayed(const Duration(milliseconds: 150));
//     await provider.load(currentData);
//   }
//
//   Future<void> _onRefresh() async {
//     if (InternetProvider.i.disconnected) {
//       return InternetProvider.showMsgNoConnect();
//     }
//
//     try {
//       await provider.refresh(currentData);
//     } catch(e) {
//       Log.snack(e.toString(), isError: true);
//     }
//   }
//
//   void returnMultSelect() {
//     throw 'returnMultSelect Não implementado';
//   }
//
//   void onBuilder() {}
//
//   void onItemTap(I membro) {}
//
//   void onAddTap();
//
//   void _onDataChanged(int? value) {
//     if (currentData != value) {
//       currentData = value!;
//       future = context.read<P>().refresh(currentData);
//       setState(() {});
//     }
//   }
//
//   void _onPesquisaChanged(String value) {
//     setState(() {});
//   }
//
//   void _onModeListTap() {
//     VariaveisGlobais.listMode = !VariaveisGlobais.listMode;
//     pref.setBool(PrefKey.listMode, VariaveisGlobais.listMode);
//     setState(() {});
//   }
//
// }

abstract class StateListPage<S extends StatefulWidget> extends State<S> {

  Future? future;

  String get title;
  String? get custonTitle => null;

  bool get readOnly => FirebaseProvider.i.readOnly;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    if (InternetProvider.i.disconnected) {
      loaded = true;
      setState(() {});
      return;
    }
    fufureVoid().then((e) {
      loaded = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String getTitie() {
      return custonTitle ?? 'Relação de ${title}s';
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTitie()),
        ),
        body: Column(
          children: [
            upBuilder(),
            Expanded(
              child: builder(),
            ),
          ],
        ),
        floatingActionButton: actionButton(),
      ),
    );
  }

  Widget builder();

  Widget upBuilder() => Container();

  Widget? actionButton() => null;


  Future<void> fufureVoid();

  Future<bool> onRefresh() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return false;
    }
    return true;
  }

}