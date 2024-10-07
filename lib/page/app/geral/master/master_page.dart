import 'package:flutter/material.dart';
import '../../../../util/util.dart';
import '../../../page.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<DebugPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: _onChaveAcessoTap,
            title: const Text('Criar chave de acesso'),
            subtitle: const Text('Para adicionar novo clube'),
            leading: const Icon(Icons.key),
          ),

          ListTile(
            onTap: _onClientesTap,
            title: const Text('Gerenciar clientes'),
            leading: const Icon(Icons.group),
          ),

          ListTile(
            onTap: _onVersionTap,
            title: const Text('Gerenciar versionamento do app'),
            leading: const Icon(Icons.swap_vert_circle_sharp),
          ),

          ListTile(
            onTap: _onImportarEspecialidadesTap,
            title: const Text('Importar Especialidades'),
            leading: const Icon(Icons.local_fire_department),
          ),
        ],
      ),
    );
  }

  void _onChaveAcessoTap() {
    // Navigate.push(context, const VersionamentoPage());
  }

  void _onClientesTap() {
    // Navigate.push(context, const VersionamentoPage());
  }

  void _onVersionTap() {
    Navigate.push(context, const VersionamentoPage());
  }

  void _onImportarEspecialidadesTap() {
    Navigate.push(context, const ImportEspecialidadesPage());
  }

}