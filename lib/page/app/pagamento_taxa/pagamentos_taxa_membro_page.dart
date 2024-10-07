import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/model.dart';
import '../../../provider/provider.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

class PagamentosTaxaMembroPage extends StatefulWidget {
  final Membro membro;
  final int anoPagamento;
  const PagamentosTaxaMembroPage({
    super.key,
    required this.membro,
    required this.anoPagamento,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<PagamentosTaxaMembroPage> {

  Membro get membro => widget.membro;
  int get anoPagamento => widget.anoPagamento;

  @override
  Widget build(BuildContext context) {
    final clube = context.watch<ClubeProvider>().clube;
    final pagamentos = context.watch<PagamentosTaxaProvider>().getByUid(membro.id);
    pagamentos.items.values.toList().sort((a, b) => a?.id.compareTo(b?.id ?? '') ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(membro.nomeUsuario),
      ),
      body: ListView.separated(
        itemCount: 12,
        padding: const EdgeInsets.only(bottom: 70),
        itemBuilder: (context, i) {
          final item = pagamentos.items['_${i +1}'] ?? Pagamento(
            id: i +1,
            ano: anoPagamento,
          );

          return PagamentoTile(
            pagamento: item,
            valor: clube.taxaMensal,
            onTap: _onitemTap,
          );
        },
        separatorBuilder: (_, i) => const Divider(),
      ),
    );
  }

  void _onitemTap(Pagamento value) {
    Navigate.push(context, PagamentoPage2(
      pagamento: value.copy(),
      membro: membro,
      readOnly: FirebaseProvider.i.readOnly,
    ));
  }
}