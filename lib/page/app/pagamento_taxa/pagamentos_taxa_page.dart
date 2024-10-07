import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../page/page.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';

// @Deprecated('Use PagamentosPage2')
// class PagamentosTaxaPage extends PageBaseList {
//   const PagamentosTaxaPage({super.key});
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// // ignore: deprecated_member_use_from_same_package
// class _State extends PageBaseListState<PagamentosTaxaPage, Membro, PagamentosTaxaProvider> {
//
//   @override
//   String get title => 'Pagamento';
//
//   @override
//   bool get showDate => true;
//
//   @override
//   bool get showSearch => true;
//
//   @override
//   bool get showActionButton => false;
//
//   @override
//   List<Membro> get items {
//     final prov = context.watch<MembrosProvider>();
//     var list = prov.list;
//     if (cPesquisa.text.isEmpty) {
//       list = prov.list;
//     } else {
//       list = prov.query(cPesquisa.text);
//     }
//     list.sort((a, b) => a.nomeUsuario.toLowerCase().compareTo(b.nomeUsuario.toLowerCase()));
//     return list;
//   }
//
//   @override
//   Widget itemBuilder(Membro value) {
//     return MembroTile(
//       membro: value,
//       pagamentos: provider.getByUid(value.id),
//       onTap: onItemTap,
//     );
//   }
//
//   @override
//   Widget? actionButton() {
//     return FloatingActionButton.extended(
//       onPressed: _onFazerPagamentoTap,
//       label: const Text('Fazer Pagamento'),
//     );
//   }
//
//   @override
//   void onItemTap(Membro membro) {
//     Navigate.push(context, PagamentosTaxaMembroPage(membro: membro));
//   }
//
//   @override
//   void onAddTap() async {
// // ignore: deprecated_member_use_from_same_package
//     final res = await Navigate.push(context, const MembrosPage(select: true));
//     if (res is! Membro) return;
//
//     // ignore: use_build_context_synchronously
//     Navigate.push(context, PagamentoTaxaPage(model2: res, model1: Pagamento()));
//   }
//
//
//   void _onFazerPagamentoTap() {
//     const styleTitle = TextStyle(fontSize: 14);
//     const styleBody = TextStyle(fontSize: 16);
//     DialogBox(
//       context: context,
//       title: 'Informações de Pagamento',
//       negativeButtonText: 'Fechar',
//       content: [
//         Card(
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Nome da conta:', style: styleTitle,),
//                 Text(ClubeProvider.i.clube.pixNomePessoa, style: styleBody,),
//               ],
//             ),
//           ),
//         ),
//         Card(
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Chave Pix:', style: styleTitle,),
//                 Text(ClubeProvider.i.clube.pixChave, style: styleBody,),
//               ],
//             ),
//           ),
//         ),
//
//         const Text('Realize o pagamento e envie o comprovante ao tesoureiro',
//           textAlign: TextAlign.center,
//         ),
//
//         const SizedBox(height: 10),
//
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: _onCopyPixTap,
//             child: const Text('Copiar Chave Pix'),
//           ),
//         )
//       ],
//     ).cancel();
//   }
//
//   void _onCopyPixTap() {
//     Navigator.pop(context);
//
//     Log.snack('Pix copiado');
//     Util.copyText(ClubeProvider.i.clube.pixChave);
//   }
//
// }

class PagamentosPage2 extends StatefulWidget {
  const PagamentosPage2({super.key});

  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends StateListPage<PagamentosPage2> {

  static int currentData = DateTime.now().year;

  PagamentosTaxaProvider provider = PagamentosTaxaProvider.i;

  final cPesquisa = TextEditingController();

  @override
  String get title => 'Pagamento';

  List<Membro> get items {
    final prov = context.watch<MembrosProvider>();
    var list = prov.list;
    if (cPesquisa.text.isEmpty) {
      list = prov.list;
    } else {
      list = prov.query(cPesquisa.text);
    }
    list.sort((a, b) => a.nomeUsuario.toLowerCase().compareTo(b.nomeUsuario.toLowerCase()));
    return list;
  }

  @override
  Widget builder() {
    provider = context.watch<PagamentosTaxaProvider>();
    return ListView.separated(
      itemCount: items.length,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 70),
      itemBuilder: (_, i) => itemBuilder(items[i]),
      separatorBuilder: (_, i) => const SizedBox(height: 5),
    );
  }

  @override
  Widget upBuilder() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

        AnoCorrenteDropDown(
          value: currentData,
          items: provider.anosList,
          onChanged: _onDataChanged,
        ),
      ],
    );
  }

  @override
  Widget? actionButton() {
    if (!loaded) return const CircularProgressIndicator();

    return FloatingActionButton.extended(
      onPressed: _onFazerPagamentoTap,
      label: const Text('Fazer Pagamento'),
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
      pagamentos: provider.getByUid(value.id),
      onTap: onItemTap,
    );
  }

  void onItemTap(Membro membro) {
    Navigate.push(context, PagamentosTaxaMembroPage(
      membro: membro,
      anoPagamento: currentData,
    ));
  }

  void onAddTap() async {
    final res = await Navigate.push(context, const MembrosPage2(select: true));
    if (res is! Membro) return;

    // ignore: use_build_context_synchronously
    Navigate.push(context, PagamentoPage2(membro: res, pagamento: Pagamento()));
  }

  void _onDataChanged(int? value) {
    if (currentData != value) {
      currentData = value!;
      future = context.read<PagamentosTaxaProvider>().refresh(currentData);
      setState(() {});
    }
  }

  void _onPesquisaChanged(String value) {
    setState(() {});
  }


  void _onFazerPagamentoTap() {
    const styleTitle = TextStyle(fontSize: 14);
    const styleBody = TextStyle(fontSize: 16);
    DialogBox(
      context: context,
      title: 'Informações de Pagamento',
      negativeButtonText: 'Fechar',
      content: [
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nome da conta:', style: styleTitle,),
                Text(ClubeProvider.i.clube.pixNomePessoa, style: styleBody,),
              ],
            ),
          ),
        ),
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chave Pix:', style: styleTitle,),
                Text(ClubeProvider.i.clube.pixChave, style: styleBody,),
              ],
            ),
          ),
        ),

        const Text('Realize o pagamento e envie o comprovante ao tesoureiro',
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onCopyPixTap,
            child: const Text('Copiar Chave Pix'),
          ),
        )
      ],
    ).cancel();
  }

  void _onCopyPixTap() {
    Navigator.pop(context);

    Log.snack('Pix copiado');
    Util.copyText(ClubeProvider.i.clube.pixChave);
  }

}