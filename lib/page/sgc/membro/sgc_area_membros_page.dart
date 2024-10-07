import 'package:flutter/material.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

class SgcAreaMembrosPage extends StatefulWidget {
  const SgcAreaMembrosPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcAreaMembrosPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Área dos Membros'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          ListTile(
            onTap: _onMembrosTap,
            leading: const Icon(Icons.group),
            title: const Text('Ver Membros'),
            subtitle: const Text('Cadastrar, Atualizar'),
          ),

          ListTile(
            onTap: _onImportMembroTap,
            leading: const Icon(Icons.import_export),
            title: const Text('Importar Membros'),
            subtitle: const Text('Importar do SGC'),
          ),
        ],
      ),
    );
  }

  void _onMembrosTap() {
    Navigate.push(context, const SgcMembrosPage());
  }

  void _onImportMembroTap() async {
    // Navigate.push(context, const ImportarMembrosPage());
  }

}