import 'package:flutter/material.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

class TesourariaPage extends StatefulWidget {
  const TesourariaPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<TesourariaPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Tesouraria'),
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
            title: 'Dispensa',
            subtitle: 'A pagar (Saidas)',
            icon: Icons.money_off,
            onTap: () => _onTap(false),
          ),  // Dispensa
          SgcMenuItem(
            onTap: () => _onTap(true),
            icon: Icons.attach_money_sharp,
            subtitle: 'A receber (Entradas)',
            title: 'Receita',
          ),  // Receita
        ],
      ),
    );
  }

  void _onTap(bool value) {
    Navigate.push(context, TesourariaListaPage(isReceita: value));
  }
}