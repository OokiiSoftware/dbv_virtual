import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/provider.dart';
import '../../../../model/model.dart';
import '../../../../res/res.dart';

class EspecialidadePage extends StatefulWidget {
  final bool readOnly;
  final Especialidade especialidade;
  const EspecialidadePage({
    super.key,
    this.readOnly = true,
    required this.especialidade,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<EspecialidadePage> {

  EspecialidadesProvider _provider = EspecialidadesProvider.i;

  Especialidade get especialidade => widget.especialidade;
  bool get readOnly => widget.readOnly;

  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _init(false);
  }

  @override
  Widget build(BuildContext context) {
    _provider = context.watch<EspecialidadesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(especialidade.nome),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20
            ),
            children: [
              Center(
                child: FotoLayout(
                  path: especialidade.image,
                  borderRadius: 50,
                  width: 150,
                  fit: BoxFit.fill,
                ),
              ),  // foto

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    Text(especialidade.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(especialidade.area),
                    Text(especialidade.idName),
                  ],
                ),
              ),  // title

              const SizedBox(height: 10),

              _espText(),
            ],
          );
        },
      ),
    );
  }

  Widget _espText() {
    final linhas = especialidade.text.split('\n');
    List<Widget> childs = [];

    String currentLinha = '';
    Map<String, List<String>> requisitos = {};

    for (var linha in linhas) {
      if (linha.isEmpty) continue;
      bool startNumero = int.tryParse(linha[0]) != null;

      if (startNumero) {
        requisitos[linha] = [linha];
        currentLinha = linha;
      } else {
        requisitos[currentLinha]?.add(linha);
      }
    }

    for (var linha in requisitos.values) {
      childs.add(Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Text(linha.join('\n')),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: childs,
    );
  }

  Future<void> _init([bool forceLoad = true]) async {
    await Future.delayed(const Duration(milliseconds: 150));

    await _provider.getById(especialidade.id);
  }

}