import 'package:flutter/material.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

class SeguroMainPage extends StatefulWidget {
  const SeguroMainPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SeguroMainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Seguro de vida'),
      ),
      body: GridView(
        padding: const EdgeInsets.all(7),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          childAspectRatio: 1,
        ),
        children: [
          SgcMenuItem(
            title: 'Gráficos',
            subtitle: 'Informações da\nficha médica',
            icon: Icons.bar_chart,
            onTap: _onGraficosTap,
          ),
          SgcMenuItem(
            title: 'Incluir vidas',
            subtitle: 'Incluir membros\nno seguro',
            icon: Icons.health_and_safety,
            onTap: _onIncluirTap,
          ),
          SgcMenuItem(
            title: 'Transferir Seguro',
            subtitle: 'Transferir de um\nmembro para outro',
            icon: Icons.repeat,
            onTap: _onTransferirTap,
          ),
        ],
      ),
    );
  }

  void _onGraficosTap() {
    Navigate.push(context, const SeguroGraficosPage());
  }

  void _onIncluirTap() {
    Navigate.push(context, const IncluirVidaPage());
  }

  void _onTransferirTap() {
    Navigate.push(context, const SegurosPage());
  }

}