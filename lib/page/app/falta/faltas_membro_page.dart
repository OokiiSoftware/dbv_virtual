import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../res/res.dart';
import '../../../util/navigate.dart';
import '../../page.dart';

class FaltasMembroPage extends StatefulWidget {
  final Membro membro;
  const FaltasMembroPage({
    super.key,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<FaltasMembroPage> {

  Membro get membro => widget.membro;

  @override
  Widget build(BuildContext context) {
    List<Falta> faltas = context.watch<FaltasProvider>().getByUid(membro.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(membro.nomeUsuario),
      ),
      body: ListView.separated(
        itemCount: faltas.length,
        padding: const EdgeInsets.only(bottom: 70),
        itemBuilder: (context, i) {
          final falta = faltas[i];

          return FaltaTile(
            falta: falta,
            onTap: _onFaltaTap,
          );
        },
        separatorBuilder: (_, i) => const SizedBox(height: 5),
      ),
    );
  }
  
  void _onFaltaTap(Falta falta) {
    Navigate.push(context, FaltaPage2(
      falta: falta.copy(),
      membro: membro,
    ));
  }
}