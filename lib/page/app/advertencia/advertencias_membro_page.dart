import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class AdvertenciasMembroPage extends StatefulWidget {
  final Membro membro;
  const AdvertenciasMembroPage({
    super.key,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AdvertenciasMembroPage> {

  Membro get membro => widget.membro;

  @override
  Widget build(BuildContext context) {
    List<Advertencia> advertencias = context.watch<AdvertenciasProvider>().getByUid(membro.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(membro.nomeUsuario),
      ),
      body: ListView.builder(
        itemCount: advertencias.length,
        padding: const EdgeInsets.only(bottom: 70),
        itemBuilder: (context, i) {
          final advertencia = advertencias[i];

          return AdvertenciaTile(
            advertencia: advertencia,
            onTap: _onAdvertenciaTap,
          );
        },
      ),
    );
  }

  void _onAdvertenciaTap(Advertencia advertencia) {
    Navigate.push(context, AdvertenciaPage2(
      advertencia: advertencia.copy(),
      membro: membro,
    ));
  }

}