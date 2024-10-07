import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import '../../model/model.dart';
import '../../res/res.dart';
import '../../util/util.dart';
import '../page.dart';

// @Deprecated('Use ClassePage2')
// class ClassePage extends StatefulWidget {
//   final Membro membro;
//   final Classe classe;
//   const ClassePage({
//     super.key,
//     required this.classe,
//     required this.membro,
//   });
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// @Deprecated('Use ClassePage2')
// class _State extends State<ClassePage> {
//
//   Membro get membro => widget.membro;
//   Classe get classe => widget.classe;
//
//   String? _erro;
//   Future? _future;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _init();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _onRefresh,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(classe.name),
//         ),
//         body: FutureBuilder(
//           future: _future,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState != ConnectionState.done) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             return _body();
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _body() {
//     if (_erro != null) return Center(child: Text(_erro!));
//
//     final prof = context.watch<CvProvider>().getProfile(membro.codUsuario);
//     final atividades = prof?.classes[classe.id]?.atividades;
//
//     return ListView.builder(
//       itemCount: atividades?.length ?? 0,
//       padding: const EdgeInsets.only(bottom: 20),
//       itemBuilder: (context, i) {
//         final item = atividades![i];
//
//         return Card(
//           child: Column(
//             children: [
//               ListTile(
//                 onTap: () => _onAtividadeTap(item),
//                 title: Text(item.name),
//                 subtitle: Text('Questões: ${item.respondidosCount} / ${item.questoesCount}'),
//                 trailing: Text('${item.percent.toStringAsFixed(2)}%'),
//               ),
//               LinearProgressIndicator(
//                 value: item.percent / 100,
//                 color: Tema.i.primaryColor,
//                 backgroundColor: Colors.transparent,
//                 minHeight: 1.5,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _init() async {
//     await _onRefresh(false);
//   }
//
//   Future<void> _onRefresh([bool forceRefresh = true]) async {
//     try {
//       await CvProvider.i.loadClasses(membro.codUsuario, classe, forceRefresh: forceRefresh);
//     } catch(e) {
//       if (e.toString().contains('Acesso inválido')) {
//         _erro = 'Não foi possível obter os dados.';
//         setState(() {});
//         return;
//       }
//       Log.snack(e.toString(), isError: true);
//     }
//   }
//
//   void _onAtividadeTap(Atividade value) {
//     Navigate.push(context, QuestoesPage(
//       atividade: value,
//       membro: membro,
//     ));
//   }
//
// }

class ClassePage2 extends StatefulWidget {
  final Membro membro;
  final Classe classe;
  const ClassePage2({
    super.key,
    required this.classe,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends StateListPage<ClassePage2> {

  Membro get membro => widget.membro;
  Classe get classe => widget.classe;

  @override
  String get title => classe.name;

  @override
  String? get custonTitle => title;

  @override
  Widget builder() {
    final prof = context.watch<CvProvider>().getProfile(membro.codUsuario);
    final atividades = prof?.classes[classe.id]?.atividades;

    return ListView.builder(
      itemCount: atividades?.length ?? 0,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, i) {
        final item = atividades![i];

        return Card(
          child: Column(
            children: [
              ListTile(
                onTap: () => _onAtividadeTap(item),
                title: Text(item.name),
                subtitle: Text('Questões: ${item.respondidosCount} / ${item.questoesCount}'),
                trailing: Text('${item.percent.toStringAsFixed(2)}%'),
              ),
              LinearProgressIndicator(
                value: item.percent / 100,
                color: Tema.i.primaryColor,
                backgroundColor: Colors.transparent,
                minHeight: 1.5,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget? actionButton() {
    if (!loaded) return const CircularProgressIndicator();

    return null;
  }

  @override
  Future<void> fufureVoid() async {
    await CvProvider.i.loadClasses(membro.codUsuario, classe);
  }

  @override
  Future<bool> onRefresh() async {
    if (!await super.onRefresh()) return false;

    try {
      await CvProvider.i.loadClasses(membro.codUsuario, classe, forceRefresh: true);
    } catch(e) {
      Log.snack(e.toString(), isError: true);
    }
    return true;
  }


  void _onAtividadeTap(Atividade value) {
    Navigate.push(context, QuestoesPage(
      atividade: value,
      membro: membro,
    ));
  }

}