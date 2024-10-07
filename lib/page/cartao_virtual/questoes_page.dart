import 'package:flutter/material.dart';
import '../../model/model.dart';
import '../../res/res.dart';
import '../../util/util.dart';
import '../page.dart';

class QuestoesPage extends StatefulWidget {
  final Membro membro;
  final Atividade atividade;
  const QuestoesPage({
    super.key,
    required this.atividade,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<QuestoesPage> {

  Atividade get atividade => widget.atividade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(atividade.name),
      ),
      body: ListView.builder(
        itemCount: atividade.questoes.length,
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 80),
        itemBuilder: (context, i) {
          final item = atividade.questoes[i];

          return QuestaoTile(
            questao: item,
            onEditTap: onItemEditTap,
            onOpenPdfTap: _onOpenPdfTap,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: atividade.hashCode,
        onPressed: null,
        label: Text('${atividade.percent.toStringAsFixed(1)}%'),
      ),
    );
  }

  void onItemEditTap(Questao value) async {
    await Navigate.push(context, QuestaoPage(questao: value, membro: widget.membro));
    setState(() {});
  }

  void _onOpenPdfTap(String url) {
    Navigate.push(context, PdfViewPage(
      title: 'Arquivo',
      pdfUrl: url,
    ));
  }
}