import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class HinoPage extends StatefulWidget {
  final String hino;
  const HinoPage({
    super.key,
    this.hino = '',
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<HinoPage> {

  late final _controller = TextEditingController(text: widget.hino);

  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hino do clube'),
      ),
      body: Column(
        children: [
          Expanded(
            child: TextFormField(
              maxLines: 50,
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Digite aqui o hino do seu clube'
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSaveTap,
              child: const Text('Salvar'),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  void _onSaveTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    final text = _controller.text;
    if (text.isEmpty && widget.hino.isNotEmpty) {
      final res = await DialogBox(
        context: context,
        content: const [
          Text('O novo texto está vazio, deseja mesmo salvar as alterações?'),
        ],
      ).simNao();
      if (!res.isPositive) return;
    }

    _setInProgress(true);
    try {
      await ClubeProvider.i.salvarHino(text);
      if (mounted) {
        Navigator.pop(context, text);
      }
      Log.snack('Dados salvos');
    } catch(e) {
      Log.snack('Erro ao salvar os dados', isError: true, actionClick: !mounted ? null :() {
        Popup(context).errorDetalhes(e);
      });
    }
    _setInProgress(false);
  }

  void _setInProgress(bool b) {
    _inProgress = b;
    if (mounted) {
      setState(() {});
    }
  }
}